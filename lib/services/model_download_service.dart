import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../logger.dart';
import 'package:archive/archive.dart';

const String kManifestUrl =
    'https://pub-b0c6081c1ebc4590a4caa677664f819f.r2.dev/models/manifest.json';

enum ModelDownloadState { notDownloaded, downloading, processing, downloaded, error }

// ============================================================
// Manifest 数据模型
// ============================================================

/// Manifest 中定义的单个模型
class ManifestModel {
  final String key; // manifest 中的键名，如 "vad", "asr-nonstreaming"
  final String name;
  final String
  type; // 模型架构类型：silero / sense_voice / zipformer / vits / ct_transformer
  final String version;
  final String url;
  final Map<String, String>
  files; // {"model":"model.onnx", "tokens":"tokens.txt"}
  final double sizeMb;
  final String? md5;

  bool get isArchive => url.endsWith('.tar.bz2');

  const ManifestModel({
    required this.key,
    required this.name,
    required this.type,
    required this.version,
    required this.url,
    required this.files,
    required this.sizeMb,
    this.md5,
  });

  factory ManifestModel.fromJson(String key, Map<String, dynamic> json) =>
      ManifestModel(
        key: key,
        name: json['name'] as String,
        type: json['type'] as String,
        version: json['version'] as String,
        url: json['url'] as String,
        files: Map<String, String>.from(json['files'] as Map),
        sizeMb: (json['size_mb'] as num).toDouble(),
        md5: json['md5'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'version': version,
    'url': url,
    'md5': md5 ?? '',
    'size_mb': sizeMb,
    'files': files,
  };
}

/// Manifest 配置
class Manifest {
  final String manifestVersion;
  final String updateDate;
  final Map<String, ManifestModel> models;

  List<ManifestModel> get modelList => models.values.toList(growable: false);
  ManifestModel? getModel(String key) => models[key];

  const Manifest({
    required this.manifestVersion,
    required this.updateDate,
    required this.models,
  });

  factory Manifest.fromJson(Map<String, dynamic> json) {
    final modelsJson = json['models'] as Map<String, dynamic>;
    final models = modelsJson.map(
      (key, value) => MapEntry(
        key,
        ManifestModel.fromJson(key, value as Map<String, dynamic>),
      ),
    );
    return Manifest(
      manifestVersion: json['manifest_version'] as String,
      updateDate: json['update_date'] as String,
      models: models,
    );
  }

  Map<String, dynamic> toJson() => {
    'manifest_version': manifestVersion,
    'update_date': updateDate,
    'models': models.map((key, model) => MapEntry(key, model.toJson())),
  };
}

/// 模型下载服务 — 通过远程 Manifest 管理语音模型的下载、更新和状态追踪
class ModelDownloadService {
  final _statesController =
      StreamController<Map<String, ModelDownloadState>>.broadcast();
  final _progressController = StreamController<Map<String, double>>.broadcast();
  final _errorController = StreamController<Map<String, String>>.broadcast();

  final Map<String, ModelDownloadState> _states = {};
  final Map<String, double> _progress = {};
  final Map<String, String> _errorMessages = {};

  Manifest? _manifest;

  /// 从 Manifest 获取模型列表
  List<ManifestModel> get models => _manifest?.modelList ?? [];

  /// Manifest 是否已加载
  bool get isManifestLoaded => _manifest != null;

  /// 当前 Manifest
  Manifest? get manifest => _manifest;

  Map<String, ModelDownloadState> get states => Map.unmodifiable(_states);
  Map<String, double> get progress => Map.unmodifiable(_progress);
  Map<String, String> get errorMessages => Map.unmodifiable(_errorMessages);

  String? _modelsPath;
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;
  String? get modelsPath => _modelsPath;

  Stream<Map<String, ModelDownloadState>> get statesStream =>
      _statesController.stream;
  Stream<Map<String, double>> get progressStream => _progressController.stream;
  Stream<Map<String, String>> get errorStream => _errorController.stream;

  bool _initialized = false;

  /// 获取模型文件存放目录
  Future<String> getModelsDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(appDir.path, 'models'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    appLog.d('[ModelDownload] 模型目录: ${dir.path}');
    return dir.path;
  }

  /// 初始化：加载本地 Manifest → 检查状态 → 拉取远程 Manifest → 版本比对 → 按需更新
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _modelsPath ??= await getModelsDir();

    // 1. 先加载本地 Manifest，快速回显 UI
    final localManifest = await _loadLocalManifest();
    if (localManifest != null) {
      _manifest = localManifest;
      await checkStates();
    }

    // 2. 拉取远程 Manifest
    final remoteManifest = await _fetchManifest();
    if (remoteManifest == null) {
      appLog.w('[ModelDownload] 远程 Manifest 获取失败，使用本地版本');
      return;
    }

    // 3. 版本比对
    if (localManifest == null ||
        _isVersionNewer(
          remoteManifest.manifestVersion,
          localManifest.manifestVersion,
        )) {
      appLog.i(
        '[ModelDownload] Manifest 版本变更: ${localManifest?.manifestVersion ?? "无"} → ${remoteManifest.manifestVersion}',
      );
      _manifest = remoteManifest;
      await _updateModels(remoteManifest, localManifest);
      await checkStates();
      await _saveManifest(remoteManifest);
    } else {
      _manifest = remoteManifest;
    }
  }

  /// 拉取远程 Manifest
  Future<Manifest?> _fetchManifest({int maxRetries = 2}) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        appLog.d(
          '[ModelDownload] 拉取远程 Manifest (第${attempt + 1}次): $kManifestUrl',
        );

        final httpClient = HttpClient()
          ..userAgent =
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
          ..connectionTimeout = const Duration(seconds: 15)
          ..idleTimeout = const Duration(minutes: 2);
        try {
          final request = await httpClient.getUrl(Uri.parse(kManifestUrl));
          // request.headers.set('Connection', 'close');
          request.headers.set('Accept', 'application/json');

          final response = await request.close().timeout(
            const Duration(seconds: 15),
          );
          if (response.statusCode == 200) {
            final body = await response.transform(utf8.decoder).join();
            return Manifest.fromJson(jsonDecode(body) as Map<String, dynamic>);
          }
          appLog.w('[ModelDownload] 远程 Manifest 返回 ${response.statusCode}');
          return null;
        } finally {
          httpClient.close(force: true);
        }
      } on TimeoutException {
        appLog.w('[ModelDownload]  Manifest 请求超时 (第${attempt + 1}次)');
      } catch (e) {
        appLog.w('[ModelDownload]  Manifest 请求失败 (第${attempt + 1}次): $e');
      }

      if (attempt < maxRetries) {
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    }
    appLog.e('[ModelDownload]  Manifest 请求最终失败');
    return null;
  }

  /// 加载本地 Manifest
  Future<Manifest?> _loadLocalManifest() async {
    final localPath = p.join(_modelsPath!, 'manifest.json');
    try {
      final file = File(localPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        return Manifest.fromJson(jsonDecode(content) as Map<String, dynamic>);
      }
    } catch (e) {
      appLog.e('[ModelDownload] 加载本地 Manifest 失败: $e');
    }
    return null;
  }

  /// 保存 Manifest 到本地
  Future<void> _saveManifest(Manifest m) async {
    final localPath = p.join(_modelsPath!, 'manifest.json');
    try {
      await File(
        localPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(m.toJson()));
      appLog.d('[ModelDownload] Manifest 已保存到本地');
    } catch (e) {
      appLog.e('[ModelDownload] 保存 Manifest 失败: $e');
    }
  }

  /// 版本号比对（semver）
  bool _isVersionNewer(String remote, String local) {
    final rParts = remote.split('.');
    final lParts = local.split('.');
    final len = rParts.length > lParts.length ? rParts.length : lParts.length;
    for (int i = 0; i < len; i++) {
      final r = i < rParts.length ? int.parse(rParts[i]) : 0;
      final l = i < lParts.length ? int.parse(lParts[i]) : 0;
      if (r != l) return r > l;
    }
    return false;
  }

  /// 按 Manifest 版本比对更新模型（先下载再移除旧文件）
  Future<void> _updateModels(Manifest remote, Manifest? local) async {
    if (_isDownloading) return;
    _isDownloading = true;

    final toDownload = <ManifestModel>[];
    for (final model in remote.modelList) {
      final localModel = local?.getModel(model.key);
      if (localModel != null && localModel.version == model.version) {
        appLog.d('[ModelDownload]  ${model.key} 版本一致(${model.version})，跳过');
        continue;
      }
      appLog.i(
        '[ModelDownload] ${model.key} 版本变更: ${localModel?.version ?? "无"} → ${model.version}',
      );
      toDownload.add(model);
    }
    await _forEachConcurrent(toDownload, 3, _performDownload);

    _isDownloading = false;
  }

  /// 校验单个模型文件完整性（根据 Manifest 中的 files 字段）
  Future<bool> isModelValid(ManifestModel model) async {
    _modelsPath ??= await getModelsDir();

    final modelDir = p.join(_modelsPath!, model.key);
    if (!await Directory(modelDir).exists()) return false;

    for (final filename in model.files.values) {
      if (!await File(p.join(modelDir, filename)).exists()) return false;
    }
    return true;
  }

  /// 删除模型文件目录
  Future<void> deleteModel(ManifestModel model) async {
    _modelsPath ??= await getModelsDir();
    final targetDir = p.join(_modelsPath!, model.key);
    appLog.d('[ModelDownload] 删除模型目录: $targetDir');
    final dir = Directory(targetDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    _states[model.key] = ModelDownloadState.notDownloaded;
    _progress[model.key] = 0.0;
    _errorMessages.remove(model.key);
    _emitStates();
    _emitProgress();
    _emitErrors();
    appLog.d('[ModelDownload] 模型已删除: ${model.key}');
  }

  /// 扫描磁盘，检查各模型下载状态
  Future<Map<String, ModelDownloadState>> checkStates() async {
    _modelsPath ??= await getModelsDir();
    appLog.d('[ModelDownload] 开始检查已下载的模型: $_modelsPath');

    for (final model in models) {
      final valid = await isModelValid(model);
      _states[model.key] = valid
          ? ModelDownloadState.downloaded
          : ModelDownloadState.notDownloaded;
      _progress[model.key] = valid ? 1.0 : 0.0;
    }
    _emitStates();
    _emitProgress();
    return Map.from(_states);
  }

  /// 用户手动下载所有尚未就绪的模型
  Future<void> downloadModels() async {
    if (_isDownloading) {
      appLog.d('[ModelDownload] 下载已在进行中，跳过');
      return;
    }
    _isDownloading = true;
    appLog.d('[ModelDownload] 开始下载模型');

    final toDownload = <ManifestModel>[];
    for (final model in models) {
      if (await isModelValid(model)) {
        _states[model.key] = ModelDownloadState.downloaded;
        _progress[model.key] = 1.0;
        _emitStates();
        _emitProgress();
        continue;
      }
      toDownload.add(model);
    }
    await _forEachConcurrent(toDownload, 3, _performDownload);

    _isDownloading = false;
    appLog.d('[ModelDownload] 所有任务完成');
  }

  /// 重新下载单个模型
  Future<void> downloadModel(ManifestModel model) async {
    if (_isDownloading) {
      appLog.d('[ModelDownload] 下载已在进行中，跳过');
      return;
    }
    _isDownloading = true;
    appLog.d('[ModelDownload] 开始重新下载模型: ${model.key}');

    await _performDownload(model);

    _isDownloading = false;
    appLog.d('[ModelDownload] 单个模型下载完成: ${model.key}');
  }

  /// HTTP 流式下载到本地临时文件（含超时和自动重试）
  /// HTTP 流式下载到本地临时文件（支持断点续传、指数退避重试）
  Future<void> _httpDownloadFile(ManifestModel model, String destPath) async {
    const int maxRetries = 5; // 增加重试上限以应对 R2 的严格连接管理
    int baseDelayMs = 2000; // 基础延迟时间

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final file = File(destPath);
        int downloadedBytes = 0;
        bool isResuming = false;

        // 1. 检查是否存在未下载完的临时文件，准备断点续传
        if (await file.exists()) {
          downloadedBytes = await file.length();
          if (downloadedBytes > 0) {
            isResuming = true;
            appLog.d(
              '[ModelDownload]  检测到中断，尝试断点续传，从 $downloadedBytes 字节开始 (第${attempt + 1}次)',
            );
          }
        } else {
          appLog.d('[ModelDownload]  HTTP GET ${model.url} (第${attempt + 1}次)');
        }

        final httpClient = HttpClient()
          ..userAgent =
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
          ..connectionTimeout = const Duration(seconds: 30)
          ..idleTimeout = const Duration(minutes: 5);

        try {
          final request = await httpClient.getUrl(Uri.parse(model.url));

          // 【关键修复】不要设置 Connection: close，允许 Keep-Alive
          // 如果是断点续传，加入 Range 协议头
          if (isResuming) {
            request.headers.set('Range', 'bytes=$downloadedBytes-');
          }

          final response = await request.close();

          // 206 Partial Content 表示服务器支持断点续传并成功返回剩余部分
          // 200 OK 表示服务器不支持断点续传（或文件极小），从头开始返回了完整文件
          if (response.statusCode != 200 && response.statusCode != 206) {
            throw HttpException('HTTP Status ${response.statusCode}');
          }

          // 如果我们期望续传，但服务器返回了 200，说明 R2 忽略了 Range 头，我们需要清空本地文件重头写
          if (response.statusCode == 200 && isResuming) {
            appLog.w('[ModelDownload]  服务器不支持断点续传，重新从 0 开始下载');
            downloadedBytes = 0;
            isResuming = false;
            await file.writeAsBytes([]); // 清空遗留文件
          }

          final totalBytes = (response.contentLength > 0)
              ? downloadedBytes + response.contentLength
              : -1;

          if (totalBytes > 0 && attempt == 0) {
            appLog.d('[ModelDownload]  总文件大小: ${(totalBytes ~/ 1024)}KB');
          }

          // 如果是续传，使用 append 模式追加写入；否则使用 write 模式覆盖
          final sink = file.openWrite(
            mode: isResuming ? FileMode.append : FileMode.write,
          );

          var received = downloadedBytes;
          try {
            await for (final chunk in response.timeout(
              const Duration(minutes: 5),
            )) {
              sink.add(chunk);
              received += chunk.length;
              if (totalBytes > 0) {
                _progress[model.key] = received / totalBytes;
                _emitProgress();
              }
            }
          } finally {
            await sink.flush();
            await sink.close();
          }

          return; // 下载圆满完成
        } finally {
          httpClient.close(force: true);
        }
      } catch (e) {
        // 捕获 SocketException (errno 54), TimeoutException 等所有异常
        if (attempt < maxRetries) {
          // 指数退避：2s -> 4s -> 8s...
          final delay = Duration(milliseconds: baseDelayMs * (1 << attempt));
          appLog.w('[ModelDownload]  ${model.key} 下载中断: $e');
          appLog.w(
            '[ModelDownload]  将在 ${delay.inSeconds} 秒后重试第${attempt + 2}次...',
          );
          await Future.delayed(delay);

          // 【关键修复】在此处不再 delete() 临时文件！保留它以便下一次循环进行断点续传
          continue;
        }

        // 如果重试次数耗尽，彻底清理临时文件并抛出错误
        appLog.e('[ModelDownload]  ${model.key} 达到最大重试次数，下载失败。');
        if (await File(destPath).exists()) await File(destPath).delete();
        rethrow;
      }
    }
  }

  /// 下载并部署单个模型（先下载到临时位置 → 删除旧文件 → 部署到目标目录）
  Future<void> _downloadModel(ManifestModel model) async {
    final tmpDir = await getTemporaryDirectory();
    if (!await tmpDir.exists()) await tmpDir.create(recursive: true);

    final tmpDownload = p.join(tmpDir.path, 'byte_voice_${model.key}.download');
    final tmpExtract = p.join(tmpDir.path, 'byte_voice_${model.key}_extracted');

    try {
      // --- 1. HTTP 流式下载到临时文件 ---
      appLog.d('[ModelDownload]  HTTP GET ${model.url}');
      await _httpDownloadFile(model, tmpDownload);
      _progress[model.key] = 1.0;
      _states[model.key] = ModelDownloadState.processing;
      _emitProgress();
      _emitStates();

      if (model.isArchive) {
        // --- 2. 解压归档到临时目录 ---
        appLog.d('[ModelDownload]  解压归档到临时目录');
        final extractDir = Directory(tmpExtract);
        if (await extractDir.exists()) {
          await extractDir.delete(recursive: true);
        }
        await extractDir.create(recursive: true);

        await _extractTarBz2(tmpDownload, tmpExtract);

        // --- 3. 删除旧模型文件 ---
        final targetDir = p.join(_modelsPath!, model.key);
        final target = Directory(targetDir);
        if (await target.exists()) {
          await target.delete(recursive: true);
        }
        await target.create(recursive: true);

        // --- 4. 从临时提取目录移动到目标目录 ---
        await for (final entity in extractDir.list()) {
          await entity.rename(p.join(targetDir, p.basename(entity.path)));
        }
        appLog.d('[ModelDownload]  部署完成: $targetDir');
      } else {
        // --- 单文件（如 .onnx）直接部署 ---
        final targetDir = p.join(_modelsPath!, model.key);
        final targetDirObj = Directory(targetDir);
        if (await targetDirObj.exists()) {
          await targetDirObj.delete(recursive: true);
        }
        await targetDirObj.create(recursive: true);

        final filename = model.files.values.first;
        final targetPath = p.join(targetDir, filename);
        await File(tmpDownload).copy(targetPath);
        appLog.d('[ModelDownload]  文件已部署: $targetPath');
      }
    } catch (e) {
      rethrow;
    } finally {
      // 清理临时文件
      for (final path in [tmpDownload, tmpExtract]) {
        final f = File(path);
        if (await f.exists()) await f.delete();
        final d = Directory(path);
        if (await d.exists()) await d.delete(recursive: true);
      }
    }
  }

  /// 在后台 Isolate 中解压 tar.bz2（避免卡主线程）
  Future<void> _extractTarBz2(String archivePath, String outputDir) async {
    appLog.d('[ModelDownload]  后台 Isolate 解压 bzip2 + tar...');
    final count = await Isolate.run(() => _extractAndDeploySync(archivePath, outputDir));
    appLog.d('[ModelDownload]  解压完成，共 $count 个文件');
  }

  void _emitStates() => _statesController.add(Map.from(_states));
  void _emitProgress() => _progressController.add(Map.from(_progress));
  void _emitErrors() => _errorController.add(Map.from(_errorMessages));

  /// 对列表中的每个元素执行异步操作，最多同时运行 [concurrency] 个。
  Future<void> _forEachConcurrent<T>(
    Iterable<T> items,
    int concurrency,
    Future<void> Function(T item) action,
  ) async {
    final pending = <_TrackedTask>[];
    for (final item in items) {
      if (pending.length >= concurrency) {
        await Future.any(pending.map((t) => t.future));
        pending.removeWhere((t) => t.isDone);
      }
      pending.add(_TrackedTask(action(item)));
    }
    await Future.wait(pending.map((t) => t.future));
  }

  /// 下载单个模型并更新状态（供并发辅助方法调用）
  Future<void> _performDownload(ManifestModel model) async {
    appLog.d('[ModelDownload]  开始下载 ${model.key}');
    _states[model.key] = ModelDownloadState.downloading;
    _progress[model.key] = 0.0;
    _errorMessages.remove(model.key);
    _emitStates();
    _emitProgress();
    _emitErrors();

    try {
      await _downloadModel(model);
      _states[model.key] = ModelDownloadState.downloaded;
      _progress[model.key] = 1.0;
      appLog.d('[ModelDownload]  ${model.key} 下载完成');
    } catch (e) {
      appLog.w('[ModelDownload]  ${model.key} 下载失败: $e');
      _states[model.key] = ModelDownloadState.error;
      _progress[model.key] = 0.0;
      _errorMessages[model.key] = e.toString();
    }
    _emitStates();
    _emitProgress();
    _emitErrors();
  }

  /// 在后台 Isolate 中同步检查模型文件
  static Map<String, bool> checkModelsSync(
    String modelsDir,
    String manifestJson,
  ) {
    final manifest = Manifest.fromJson(
      jsonDecode(manifestJson) as Map<String, dynamic>,
    );
    final results = <String, bool>{};
    for (final model in manifest.modelList) {
      final modelDir = p.join(modelsDir, model.key);
      if (!Directory(modelDir).existsSync()) {
        results[model.key] = false;
        continue;
      }
      bool allExist = true;
      for (final filename in model.files.values) {
        if (!File(p.join(modelDir, filename)).existsSync()) {
          allExist = false;
          break;
        }
      }
      results[model.key] = allExist;
    }
    return results;
  }

  /// 从异步/Isolate 检查结果更新状态
  void updateStatesFromCheck(Map<String, bool> results) {
    for (final entry in results.entries) {
      _states[entry.key] = entry.value
          ? ModelDownloadState.downloaded
          : ModelDownloadState.notDownloaded;
      _progress[entry.key] = entry.value ? 1.0 : 0.0;
    }
    _emitStates();
    _emitProgress();
  }

  void dispose() {
    _statesController.close();
    _progressController.close();
    _errorController.close();
  }
}

/// 包装一个 Future，追踪其是否已完成。
class _TrackedTask {
  bool _done = false;
  final Future<void> future;
  bool get isDone => _done;

  _TrackedTask(this.future) {
    future.then((_) => _done = true, onError: (_) => _done = true);
  }
}

/// 在独立 Isolate 中同步解压 tar.bz2 并写入文件
/// 必须是顶层函数（Isolate.run 要求）
int _extractAndDeploySync(String archivePath, String outputDir) {
  final file = File(archivePath);
  final bytes = file.readAsBytesSync();

  final tarBytes = BZip2Decoder().decodeBytes(bytes);
  final archive = TarDecoder().decodeBytes(tarBytes);

  int fileCount = 0;
  for (final entry in archive) {
    if (entry.isFile) {
      String relativePath = entry.name;
      final slash = relativePath.indexOf('/');
      if (slash >= 0) {
        relativePath = relativePath.substring(slash + 1);
      }
      if (relativePath.isEmpty) continue;

      final outputPath = p.join(outputDir, relativePath);
      File(outputPath).createSync(recursive: true);
      File(outputPath).writeAsBytesSync(entry.content as List<int>);
      fileCount++;
    }
  }
  return fileCount;
}
