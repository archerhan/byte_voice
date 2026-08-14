// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotesTableTable extends NotesTable
    with TableInfo<$NotesTableTable, NotesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioFilePathMeta = const VerificationMeta(
    'audioFilePath',
  );
  @override
  late final GeneratedColumn<String> audioFilePath = GeneratedColumn<String>(
    'audio_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keepAudioMeta = const VerificationMeta(
    'keepAudio',
  );
  @override
  late final GeneratedColumn<bool> keepAudio = GeneratedColumn<bool>(
    'keep_audio',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("keep_audio" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentProgressMeta = const VerificationMeta(
    'currentProgress',
  );
  @override
  late final GeneratedColumn<double> currentProgress = GeneratedColumn<double>(
    'current_progress',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    createdAt,
    updatedAt,
    durationMs,
    audioFilePath,
    keepAudio,
    source,
    status,
    currentProgress,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('audio_file_path')) {
      context.handle(
        _audioFilePathMeta,
        audioFilePath.isAcceptableOrUnknown(
          data['audio_file_path']!,
          _audioFilePathMeta,
        ),
      );
    }
    if (data.containsKey('keep_audio')) {
      context.handle(
        _keepAudioMeta,
        keepAudio.isAcceptableOrUnknown(data['keep_audio']!, _keepAudioMeta),
      );
    } else if (isInserting) {
      context.missing(_keepAudioMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('current_progress')) {
      context.handle(
        _currentProgressMeta,
        currentProgress.isAcceptableOrUnknown(
          data['current_progress']!,
          _currentProgressMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      audioFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_file_path'],
      ),
      keepAudio: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}keep_audio'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      currentProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_progress'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $NotesTableTable createAlias(String alias) {
    return $NotesTableTable(attachedDatabase, alias);
  }
}

class NotesTableData extends DataClass implements Insertable<NotesTableData> {
  /// 笔记唯一标识（UUID，主键）
  final String id;

  /// 笔记标题
  final String title;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime updatedAt;

  /// 音频总时长（毫秒）
  final int durationMs;

  /// 永久音频文件路径
  final String? audioFilePath;

  /// 是否保留音频文件
  final bool keepAudio;

  /// 笔记来源：recording / import
  final String source;

  /// 转写状态：transcribing / completed / failed
  final String status;

  /// 转写进度（0.0~1.0）
  final double? currentProgress;

  /// 排序位置（用于拖拽排序）
  final int position;
  const NotesTableData({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.durationMs,
    this.audioFilePath,
    required this.keepAudio,
    required this.source,
    required this.status,
    this.currentProgress,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || audioFilePath != null) {
      map['audio_file_path'] = Variable<String>(audioFilePath);
    }
    map['keep_audio'] = Variable<bool>(keepAudio);
    map['source'] = Variable<String>(source);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || currentProgress != null) {
      map['current_progress'] = Variable<double>(currentProgress);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  NotesTableCompanion toCompanion(bool nullToAbsent) {
    return NotesTableCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      durationMs: Value(durationMs),
      audioFilePath: audioFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioFilePath),
      keepAudio: Value(keepAudio),
      source: Value(source),
      status: Value(status),
      currentProgress: currentProgress == null && nullToAbsent
          ? const Value.absent()
          : Value(currentProgress),
      position: Value(position),
    );
  }

  factory NotesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotesTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      audioFilePath: serializer.fromJson<String?>(json['audioFilePath']),
      keepAudio: serializer.fromJson<bool>(json['keepAudio']),
      source: serializer.fromJson<String>(json['source']),
      status: serializer.fromJson<String>(json['status']),
      currentProgress: serializer.fromJson<double?>(json['currentProgress']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'audioFilePath': serializer.toJson<String?>(audioFilePath),
      'keepAudio': serializer.toJson<bool>(keepAudio),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(status),
      'currentProgress': serializer.toJson<double?>(currentProgress),
      'position': serializer.toJson<int>(position),
    };
  }

  NotesTableData copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? durationMs,
    Value<String?> audioFilePath = const Value.absent(),
    bool? keepAudio,
    String? source,
    String? status,
    Value<double?> currentProgress = const Value.absent(),
    int? position,
  }) => NotesTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    durationMs: durationMs ?? this.durationMs,
    audioFilePath: audioFilePath.present
        ? audioFilePath.value
        : this.audioFilePath,
    keepAudio: keepAudio ?? this.keepAudio,
    source: source ?? this.source,
    status: status ?? this.status,
    currentProgress: currentProgress.present
        ? currentProgress.value
        : this.currentProgress,
    position: position ?? this.position,
  );
  NotesTableData copyWithCompanion(NotesTableCompanion data) {
    return NotesTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      audioFilePath: data.audioFilePath.present
          ? data.audioFilePath.value
          : this.audioFilePath,
      keepAudio: data.keepAudio.present ? data.keepAudio.value : this.keepAudio,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      currentProgress: data.currentProgress.present
          ? data.currentProgress.value
          : this.currentProgress,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotesTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('keepAudio: $keepAudio, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('currentProgress: $currentProgress, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    createdAt,
    updatedAt,
    durationMs,
    audioFilePath,
    keepAudio,
    source,
    status,
    currentProgress,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotesTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.durationMs == this.durationMs &&
          other.audioFilePath == this.audioFilePath &&
          other.keepAudio == this.keepAudio &&
          other.source == this.source &&
          other.status == this.status &&
          other.currentProgress == this.currentProgress &&
          other.position == this.position);
}

class NotesTableCompanion extends UpdateCompanion<NotesTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> durationMs;
  final Value<String?> audioFilePath;
  final Value<bool> keepAudio;
  final Value<String> source;
  final Value<String> status;
  final Value<double?> currentProgress;
  final Value<int> position;
  final Value<int> rowid;
  const NotesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.audioFilePath = const Value.absent(),
    this.keepAudio = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.currentProgress = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesTableCompanion.insert({
    required String id,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int durationMs,
    this.audioFilePath = const Value.absent(),
    required bool keepAudio,
    required String source,
    required String status,
    this.currentProgress = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       durationMs = Value(durationMs),
       keepAudio = Value(keepAudio),
       source = Value(source),
       status = Value(status);
  static Insertable<NotesTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? durationMs,
    Expression<String>? audioFilePath,
    Expression<bool>? keepAudio,
    Expression<String>? source,
    Expression<String>? status,
    Expression<double>? currentProgress,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (audioFilePath != null) 'audio_file_path': audioFilePath,
      if (keepAudio != null) 'keep_audio': keepAudio,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (currentProgress != null) 'current_progress': currentProgress,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? durationMs,
    Value<String?>? audioFilePath,
    Value<bool>? keepAudio,
    Value<String>? source,
    Value<String>? status,
    Value<double?>? currentProgress,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return NotesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      durationMs: durationMs ?? this.durationMs,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      keepAudio: keepAudio ?? this.keepAudio,
      source: source ?? this.source,
      status: status ?? this.status,
      currentProgress: currentProgress ?? this.currentProgress,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (audioFilePath.present) {
      map['audio_file_path'] = Variable<String>(audioFilePath.value);
    }
    if (keepAudio.present) {
      map['keep_audio'] = Variable<bool>(keepAudio.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (currentProgress.present) {
      map['current_progress'] = Variable<double>(currentProgress.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('keepAudio: $keepAudio, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('currentProgress: $currentProgress, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SegmentsTableTable extends SegmentsTable
    with TableInfo<$SegmentsTableTable, SegmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SegmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    startMs,
    endMs,
    content,
    confidence,
    sortIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'segments_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SegmentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_sortIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SegmentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SegmentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $SegmentsTableTable createAlias(String alias) {
    return $SegmentsTableTable(attachedDatabase, alias);
  }
}

class SegmentsTableData extends DataClass
    implements Insertable<SegmentsTableData> {
  /// 片段唯一标识（UUID，主键）
  final String id;

  /// 所属笔记的 ID
  final String noteId;

  /// 片段在音频中的起始毫秒
  final int startMs;

  /// 片段在音频中的结束毫秒
  final int endMs;

  /// 识别文本内容
  final String content;

  /// ASR 置信度（0.0~1.0）
  final double? confidence;

  /// 片段排序序号
  final int sortIndex;
  const SegmentsTableData({
    required this.id,
    required this.noteId,
    required this.startMs,
    required this.endMs,
    required this.content,
    this.confidence,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note_id'] = Variable<String>(noteId);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  SegmentsTableCompanion toCompanion(bool nullToAbsent) {
    return SegmentsTableCompanion(
      id: Value(id),
      noteId: Value(noteId),
      startMs: Value(startMs),
      endMs: Value(endMs),
      content: Value(content),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      sortIndex: Value(sortIndex),
    );
  }

  factory SegmentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SegmentsTableData(
      id: serializer.fromJson<String>(json['id']),
      noteId: serializer.fromJson<String>(json['noteId']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      content: serializer.fromJson<String>(json['content']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'noteId': serializer.toJson<String>(noteId),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'content': serializer.toJson<String>(content),
      'confidence': serializer.toJson<double?>(confidence),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  SegmentsTableData copyWith({
    String? id,
    String? noteId,
    int? startMs,
    int? endMs,
    String? content,
    Value<double?> confidence = const Value.absent(),
    int? sortIndex,
  }) => SegmentsTableData(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
    content: content ?? this.content,
    confidence: confidence.present ? confidence.value : this.confidence,
    sortIndex: sortIndex ?? this.sortIndex,
  );
  SegmentsTableData copyWithCompanion(SegmentsTableCompanion data) {
    return SegmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      content: data.content.present ? data.content.value : this.content,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SegmentsTableData(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('content: $content, ')
          ..write('confidence: $confidence, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, noteId, startMs, endMs, content, confidence, sortIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SegmentsTableData &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.content == this.content &&
          other.confidence == this.confidence &&
          other.sortIndex == this.sortIndex);
}

class SegmentsTableCompanion extends UpdateCompanion<SegmentsTableData> {
  final Value<String> id;
  final Value<String> noteId;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<String> content;
  final Value<double?> confidence;
  final Value<int> sortIndex;
  final Value<int> rowid;
  const SegmentsTableCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.content = const Value.absent(),
    this.confidence = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SegmentsTableCompanion.insert({
    required String id,
    required String noteId,
    required int startMs,
    required int endMs,
    required String content,
    this.confidence = const Value.absent(),
    required int sortIndex,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       noteId = Value(noteId),
       startMs = Value(startMs),
       endMs = Value(endMs),
       content = Value(content),
       sortIndex = Value(sortIndex);
  static Insertable<SegmentsTableData> custom({
    Expression<String>? id,
    Expression<String>? noteId,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<String>? content,
    Expression<double>? confidence,
    Expression<int>? sortIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (content != null) 'content': content,
      if (confidence != null) 'confidence': confidence,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SegmentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? noteId,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<String>? content,
    Value<double?>? confidence,
    Value<int>? sortIndex,
    Value<int>? rowid,
  }) {
    return SegmentsTableCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      content: content ?? this.content,
      confidence: confidence ?? this.confidence,
      sortIndex: sortIndex ?? this.sortIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SegmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('content: $content, ')
          ..write('confidence: $confidence, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TtsHistoryTableTable extends TtsHistoryTable
    with TableInfo<$TtsHistoryTableTable, TtsHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TtsHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voiceIdMeta = const VerificationMeta(
    'voiceId',
  );
  @override
  late final GeneratedColumn<int> voiceId = GeneratedColumn<int>(
    'voice_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioFilePathMeta = const VerificationMeta(
    'audioFilePath',
  );
  @override
  late final GeneratedColumn<String> audioFilePath = GeneratedColumn<String>(
    'audio_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    voiceId,
    speed,
    audioFilePath,
    createdAt,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tts_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TtsHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('voice_id')) {
      context.handle(
        _voiceIdMeta,
        voiceId.isAcceptableOrUnknown(data['voice_id']!, _voiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_voiceIdMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    } else if (isInserting) {
      context.missing(_speedMeta);
    }
    if (data.containsKey('audio_file_path')) {
      context.handle(
        _audioFilePathMeta,
        audioFilePath.isAcceptableOrUnknown(
          data['audio_file_path']!,
          _audioFilePathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TtsHistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TtsHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      voiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}voice_id'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      )!,
      audioFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_file_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TtsHistoryTableTable createAlias(String alias) {
    return $TtsHistoryTableTable(attachedDatabase, alias);
  }
}

class TtsHistoryTableData extends DataClass
    implements Insertable<TtsHistoryTableData> {
  /// 唯一标识（UUID，主键）
  final String id;

  /// 合成的文本内容
  final String content;

  /// 音色 ID
  final int voiceId;

  /// 语速
  final double speed;

  /// 合成音频文件路径（可能为空，表示合成失败或尚未合成）
  final String? audioFilePath;

  /// 创建时间
  final DateTime createdAt;

  /// 排序位置（用于拖拽排序）
  final int position;
  const TtsHistoryTableData({
    required this.id,
    required this.content,
    required this.voiceId,
    required this.speed,
    this.audioFilePath,
    required this.createdAt,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    map['voice_id'] = Variable<int>(voiceId);
    map['speed'] = Variable<double>(speed);
    if (!nullToAbsent || audioFilePath != null) {
      map['audio_file_path'] = Variable<String>(audioFilePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['position'] = Variable<int>(position);
    return map;
  }

  TtsHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return TtsHistoryTableCompanion(
      id: Value(id),
      content: Value(content),
      voiceId: Value(voiceId),
      speed: Value(speed),
      audioFilePath: audioFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioFilePath),
      createdAt: Value(createdAt),
      position: Value(position),
    );
  }

  factory TtsHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TtsHistoryTableData(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      voiceId: serializer.fromJson<int>(json['voiceId']),
      speed: serializer.fromJson<double>(json['speed']),
      audioFilePath: serializer.fromJson<String?>(json['audioFilePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
      'voiceId': serializer.toJson<int>(voiceId),
      'speed': serializer.toJson<double>(speed),
      'audioFilePath': serializer.toJson<String?>(audioFilePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'position': serializer.toJson<int>(position),
    };
  }

  TtsHistoryTableData copyWith({
    String? id,
    String? content,
    int? voiceId,
    double? speed,
    Value<String?> audioFilePath = const Value.absent(),
    DateTime? createdAt,
    int? position,
  }) => TtsHistoryTableData(
    id: id ?? this.id,
    content: content ?? this.content,
    voiceId: voiceId ?? this.voiceId,
    speed: speed ?? this.speed,
    audioFilePath: audioFilePath.present
        ? audioFilePath.value
        : this.audioFilePath,
    createdAt: createdAt ?? this.createdAt,
    position: position ?? this.position,
  );
  TtsHistoryTableData copyWithCompanion(TtsHistoryTableCompanion data) {
    return TtsHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      voiceId: data.voiceId.present ? data.voiceId.value : this.voiceId,
      speed: data.speed.present ? data.speed.value : this.speed,
      audioFilePath: data.audioFilePath.present
          ? data.audioFilePath.value
          : this.audioFilePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TtsHistoryTableData(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('voiceId: $voiceId, ')
          ..write('speed: $speed, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    content,
    voiceId,
    speed,
    audioFilePath,
    createdAt,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TtsHistoryTableData &&
          other.id == this.id &&
          other.content == this.content &&
          other.voiceId == this.voiceId &&
          other.speed == this.speed &&
          other.audioFilePath == this.audioFilePath &&
          other.createdAt == this.createdAt &&
          other.position == this.position);
}

class TtsHistoryTableCompanion extends UpdateCompanion<TtsHistoryTableData> {
  final Value<String> id;
  final Value<String> content;
  final Value<int> voiceId;
  final Value<double> speed;
  final Value<String?> audioFilePath;
  final Value<DateTime> createdAt;
  final Value<int> position;
  final Value<int> rowid;
  const TtsHistoryTableCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.speed = const Value.absent(),
    this.audioFilePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TtsHistoryTableCompanion.insert({
    required String id,
    required String content,
    required int voiceId,
    required double speed,
    this.audioFilePath = const Value.absent(),
    required DateTime createdAt,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       content = Value(content),
       voiceId = Value(voiceId),
       speed = Value(speed),
       createdAt = Value(createdAt);
  static Insertable<TtsHistoryTableData> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<int>? voiceId,
    Expression<double>? speed,
    Expression<String>? audioFilePath,
    Expression<DateTime>? createdAt,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (voiceId != null) 'voice_id': voiceId,
      if (speed != null) 'speed': speed,
      if (audioFilePath != null) 'audio_file_path': audioFilePath,
      if (createdAt != null) 'created_at': createdAt,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TtsHistoryTableCompanion copyWith({
    Value<String>? id,
    Value<String>? content,
    Value<int>? voiceId,
    Value<double>? speed,
    Value<String?>? audioFilePath,
    Value<DateTime>? createdAt,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return TtsHistoryTableCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      voiceId: voiceId ?? this.voiceId,
      speed: speed ?? this.speed,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      createdAt: createdAt ?? this.createdAt,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (voiceId.present) {
      map['voice_id'] = Variable<int>(voiceId.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (audioFilePath.present) {
      map['audio_file_path'] = Variable<String>(audioFilePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TtsHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('voiceId: $voiceId, ')
          ..write('speed: $speed, ')
          ..write('audioFilePath: $audioFilePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NotesTableTable notesTable = $NotesTableTable(this);
  late final $SegmentsTableTable segmentsTable = $SegmentsTableTable(this);
  late final $TtsHistoryTableTable ttsHistoryTable = $TtsHistoryTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    notesTable,
    segmentsTable,
    ttsHistoryTable,
  ];
}

typedef $$NotesTableTableCreateCompanionBuilder =
    NotesTableCompanion Function({
      required String id,
      required String title,
      required DateTime createdAt,
      required DateTime updatedAt,
      required int durationMs,
      Value<String?> audioFilePath,
      required bool keepAudio,
      required String source,
      required String status,
      Value<double?> currentProgress,
      Value<int> position,
      Value<int> rowid,
    });
typedef $$NotesTableTableUpdateCompanionBuilder =
    NotesTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> durationMs,
      Value<String?> audioFilePath,
      Value<bool> keepAudio,
      Value<String> source,
      Value<String> status,
      Value<double?> currentProgress,
      Value<int> position,
      Value<int> rowid,
    });

class $$NotesTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotesTableTable> {
  $$NotesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get keepAudio => $composableBuilder(
    column: $table.keepAudio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentProgress => $composableBuilder(
    column: $table.currentProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTableTable> {
  $$NotesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get keepAudio => $composableBuilder(
    column: $table.keepAudio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentProgress => $composableBuilder(
    column: $table.currentProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTableTable> {
  $$NotesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get keepAudio =>
      $composableBuilder(column: $table.keepAudio, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get currentProgress => $composableBuilder(
    column: $table.currentProgress,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$NotesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTableTable,
          NotesTableData,
          $$NotesTableTableFilterComposer,
          $$NotesTableTableOrderingComposer,
          $$NotesTableTableAnnotationComposer,
          $$NotesTableTableCreateCompanionBuilder,
          $$NotesTableTableUpdateCompanionBuilder,
          (
            NotesTableData,
            BaseReferences<_$AppDatabase, $NotesTableTable, NotesTableData>,
          ),
          NotesTableData,
          PrefetchHooks Function()
        > {
  $$NotesTableTableTableManager(_$AppDatabase db, $NotesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String?> audioFilePath = const Value.absent(),
                Value<bool> keepAudio = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> currentProgress = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesTableCompanion(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                durationMs: durationMs,
                audioFilePath: audioFilePath,
                keepAudio: keepAudio,
                source: source,
                status: status,
                currentProgress: currentProgress,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required DateTime createdAt,
                required DateTime updatedAt,
                required int durationMs,
                Value<String?> audioFilePath = const Value.absent(),
                required bool keepAudio,
                required String source,
                required String status,
                Value<double?> currentProgress = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesTableCompanion.insert(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                durationMs: durationMs,
                audioFilePath: audioFilePath,
                keepAudio: keepAudio,
                source: source,
                status: status,
                currentProgress: currentProgress,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTableTable,
      NotesTableData,
      $$NotesTableTableFilterComposer,
      $$NotesTableTableOrderingComposer,
      $$NotesTableTableAnnotationComposer,
      $$NotesTableTableCreateCompanionBuilder,
      $$NotesTableTableUpdateCompanionBuilder,
      (
        NotesTableData,
        BaseReferences<_$AppDatabase, $NotesTableTable, NotesTableData>,
      ),
      NotesTableData,
      PrefetchHooks Function()
    >;
typedef $$SegmentsTableTableCreateCompanionBuilder =
    SegmentsTableCompanion Function({
      required String id,
      required String noteId,
      required int startMs,
      required int endMs,
      required String content,
      Value<double?> confidence,
      required int sortIndex,
      Value<int> rowid,
    });
typedef $$SegmentsTableTableUpdateCompanionBuilder =
    SegmentsTableCompanion Function({
      Value<String> id,
      Value<String> noteId,
      Value<int> startMs,
      Value<int> endMs,
      Value<String> content,
      Value<double?> confidence,
      Value<int> sortIndex,
      Value<int> rowid,
    });

class $$SegmentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SegmentsTableTable> {
  $$SegmentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SegmentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SegmentsTableTable> {
  $$SegmentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SegmentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SegmentsTableTable> {
  $$SegmentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);
}

class $$SegmentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SegmentsTableTable,
          SegmentsTableData,
          $$SegmentsTableTableFilterComposer,
          $$SegmentsTableTableOrderingComposer,
          $$SegmentsTableTableAnnotationComposer,
          $$SegmentsTableTableCreateCompanionBuilder,
          $$SegmentsTableTableUpdateCompanionBuilder,
          (
            SegmentsTableData,
            BaseReferences<
              _$AppDatabase,
              $SegmentsTableTable,
              SegmentsTableData
            >,
          ),
          SegmentsTableData,
          PrefetchHooks Function()
        > {
  $$SegmentsTableTableTableManager(_$AppDatabase db, $SegmentsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SegmentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SegmentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SegmentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SegmentsTableCompanion(
                id: id,
                noteId: noteId,
                startMs: startMs,
                endMs: endMs,
                content: content,
                confidence: confidence,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String noteId,
                required int startMs,
                required int endMs,
                required String content,
                Value<double?> confidence = const Value.absent(),
                required int sortIndex,
                Value<int> rowid = const Value.absent(),
              }) => SegmentsTableCompanion.insert(
                id: id,
                noteId: noteId,
                startMs: startMs,
                endMs: endMs,
                content: content,
                confidence: confidence,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SegmentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SegmentsTableTable,
      SegmentsTableData,
      $$SegmentsTableTableFilterComposer,
      $$SegmentsTableTableOrderingComposer,
      $$SegmentsTableTableAnnotationComposer,
      $$SegmentsTableTableCreateCompanionBuilder,
      $$SegmentsTableTableUpdateCompanionBuilder,
      (
        SegmentsTableData,
        BaseReferences<_$AppDatabase, $SegmentsTableTable, SegmentsTableData>,
      ),
      SegmentsTableData,
      PrefetchHooks Function()
    >;
typedef $$TtsHistoryTableTableCreateCompanionBuilder =
    TtsHistoryTableCompanion Function({
      required String id,
      required String content,
      required int voiceId,
      required double speed,
      Value<String?> audioFilePath,
      required DateTime createdAt,
      Value<int> position,
      Value<int> rowid,
    });
typedef $$TtsHistoryTableTableUpdateCompanionBuilder =
    TtsHistoryTableCompanion Function({
      Value<String> id,
      Value<String> content,
      Value<int> voiceId,
      Value<double> speed,
      Value<String?> audioFilePath,
      Value<DateTime> createdAt,
      Value<int> position,
      Value<int> rowid,
    });

class $$TtsHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $TtsHistoryTableTable> {
  $$TtsHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get voiceId => $composableBuilder(
    column: $table.voiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TtsHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TtsHistoryTableTable> {
  $$TtsHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voiceId => $composableBuilder(
    column: $table.voiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TtsHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TtsHistoryTableTable> {
  $$TtsHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get voiceId =>
      $composableBuilder(column: $table.voiceId, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<String> get audioFilePath => $composableBuilder(
    column: $table.audioFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$TtsHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TtsHistoryTableTable,
          TtsHistoryTableData,
          $$TtsHistoryTableTableFilterComposer,
          $$TtsHistoryTableTableOrderingComposer,
          $$TtsHistoryTableTableAnnotationComposer,
          $$TtsHistoryTableTableCreateCompanionBuilder,
          $$TtsHistoryTableTableUpdateCompanionBuilder,
          (
            TtsHistoryTableData,
            BaseReferences<
              _$AppDatabase,
              $TtsHistoryTableTable,
              TtsHistoryTableData
            >,
          ),
          TtsHistoryTableData,
          PrefetchHooks Function()
        > {
  $$TtsHistoryTableTableTableManager(
    _$AppDatabase db,
    $TtsHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TtsHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TtsHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TtsHistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> voiceId = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<String?> audioFilePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TtsHistoryTableCompanion(
                id: id,
                content: content,
                voiceId: voiceId,
                speed: speed,
                audioFilePath: audioFilePath,
                createdAt: createdAt,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String content,
                required int voiceId,
                required double speed,
                Value<String?> audioFilePath = const Value.absent(),
                required DateTime createdAt,
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TtsHistoryTableCompanion.insert(
                id: id,
                content: content,
                voiceId: voiceId,
                speed: speed,
                audioFilePath: audioFilePath,
                createdAt: createdAt,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TtsHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TtsHistoryTableTable,
      TtsHistoryTableData,
      $$TtsHistoryTableTableFilterComposer,
      $$TtsHistoryTableTableOrderingComposer,
      $$TtsHistoryTableTableAnnotationComposer,
      $$TtsHistoryTableTableCreateCompanionBuilder,
      $$TtsHistoryTableTableUpdateCompanionBuilder,
      (
        TtsHistoryTableData,
        BaseReferences<
          _$AppDatabase,
          $TtsHistoryTableTable,
          TtsHistoryTableData
        >,
      ),
      TtsHistoryTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NotesTableTableTableManager get notesTable =>
      $$NotesTableTableTableManager(_db, _db.notesTable);
  $$SegmentsTableTableTableManager get segmentsTable =>
      $$SegmentsTableTableTableManager(_db, _db.segmentsTable);
  $$TtsHistoryTableTableTableManager get ttsHistoryTable =>
      $$TtsHistoryTableTableTableManager(_db, _db.ttsHistoryTable);
}
