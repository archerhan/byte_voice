# ByteVoice macOS V1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the macOS desktop ByteVoice app — a pure offline speech-to-text note-taking tool with real-time recording transcription, file import transcription, timeline-based note editing, and local SQLite storage.

**Architecture:** Four-layer architecture: Audio Layer (record + ffmpeg) → Engine Layer (sherpa_onnx VAD+ASR) → Service Layer (state machine, import, export) → UI Layer (Flutter/Riverpod, macOS single-window layout). Data flows through drift/SQLite via Repository interfaces.

**Tech Stack:** Flutter 3.x + Riverpod + drift + sherpa_onnx (Dart) + record + ffmpeg_kit_flutter_new + flutter_local_notifications + desktop_drop + file_selector

**Priority:** macOS first. No TTS, no speaker diarization, no cloud.

---

## File Structure

### New files to create:

```
byte_voice/lib/
├── main.dart                          # Entry point (replace existing)
├── app.dart                           # MaterialApp + ProviderScope + router
├── app_theme.dart                     # Dark theme (macOS native feel)
│
├── models/
│   ├── note.dart                      # Note model (freezed-style plain class)
│   ├── segment.dart                   # Segment model
│   └── note_status.dart               # NoteStatus enum
│
├── database/
│   ├── app_database.dart              # Drift AppDatabase
│   ├── app_database.g.dart            # Drift generated (auto)
│   ├── tables/
│   │   ├── notes_table.dart           # Notes table definition
│   │   └── segments_table.dart        # Segments table definition
│   └── repositories/
│       ├── notes_repository.dart      # NotesRepository interface + impl
│       ├── segments_repository.dart   # SegmentsRepository interface + impl
│       └── settings_repository.dart   # SettingsRepository (key-value)
│
├── services/
│   ├── transcription_service.dart     # Recording state machine
│   ├── audio_import_service.dart      # File import pipeline
│   ├── model_download_service.dart    # Model download + checksum
│   ├── export_service.dart            # TXT / MD / SRT export
│   └── notification_service.dart      # Local notification wrapper
│
├── providers/
│   ├── notes_provider.dart            # Notes list state
│   ├── transcription_provider.dart    # Transcription state + stream
│   ├── settings_provider.dart         # Settings state
│   └── model_provider.dart            # Model download/load state
│
├── ui/
│   ├── main_window.dart               # macOS window: sidebar + content + toolbar
│   ├── sidebar/
│   │   ├── sidebar_panel.dart         # Sidebar container
│   │   └── note_list_item.dart        # Note list row widget
│   ├── content/
│   │   ├── content_area.dart          # Content switcher by state
│   │   ├── note_detail.dart           # Note detail with segment timeline
│   │   ├── segment_item.dart          # Single segment row (time + text)
│   │   ├── transcript_stream.dart     # Live transcription stream view
│   │   ├── import_progress.dart       # File import progress view
│   │   └── empty_state.dart           # Empty state guide
│   ├── toolbar/
│   │   └── bottom_toolbar.dart        # Recording + import controls
│   ├── settings/
│   │   └── settings_window.dart       # Settings floating window
│   └── widgets/
│       ├── recording_indicator.dart   # Red dot + timer
│       ├── model_status_badge.dart    # SenseVoice ✓ status
│       └── app_title_bar.dart         # Custom macOS title bar
│
└── utils/
    ├── audio_utils.dart               # PCM helpers, format checks
    ├── time_utils.dart                # Duration → "00:12" formatting
    └── file_utils.dart                # App support dir, temp dirs
```

### Existing files to modify:
- `byte_voice/pubspec.yaml` — add dependencies
- `byte_voice/lib/main.dart` — replace with app bootstrap
- `byte_voice/macos/Runner/MainFlutterWindow.swift` — window title/size
- `byte_voice/macos/Runner/Info.plist` — mic permission

---

## Phase 0: Project Setup

### Task 0.1: Update pubspec.yaml with dependencies

**Files:**
- Modify: `byte_voice/pubspec.yaml`

- [ ] **Step 1: Replace pubspec.yaml with required dependencies**

```yaml
name: byte_voice
description: "Offline speech-to-text note-taking app."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.12.2

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  drift: ^2.25.1
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.5
  path: ^1.9.1
  record: ^5.2.0
  ffmpeg_kit_flutter_new_min_gpl: ^6.0.3
  desktop_drop: ^0.5.0
  file_selector: ^1.0.3
  window_manager: ^0.4.3
  bitsdojo_window: ^0.1.6
  flutter_local_notifications: ^18.0.1
  sherpa_onnx: ^1.10.24
  uuid: ^4.5.1
  http: ^1.3.0
  share_plus: ^10.1.4
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  drift_dev: ^2.25.2
  build_runner: ^2.4.14
  riverpod_generator: ^2.6.3
  mockito: ^5.4.5

flutter:
  uses-material-design: true
```

- [ ] **Step 2: Run flutter pub get**

Run: `cd byte_voice && flutter pub get`

### Task 0.2: macOS platform configuration

**Files:**
- Modify: `byte_voice/macos/Runner/MainFlutterWindow.swift`
- Modify: `byte_voice/macos/Runner/Info.plist`

- [ ] **Step 1: Update window title and minimum size**

```swift
import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = NSRect(x: 0, y: 0, width: 960, height: 640)
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.title = "ByteVoice"
    self.minSize = NSSize(width: 800, height: 500)
    super.awakeFromNib()
  }
}
```

- [ ] **Step 2: Add microphone usage description**

```xml
<key>NSMicrophoneUsageDescription</key>
<string>ByteVoice needs microphone access to record and transcribe speech.</string>
```

- [ ] **Step 3: Create directory structure**

Run: `cd byte_voice/lib && mkdir -p models database/tables database/repositories services providers ui/sidebar ui/content ui/toolbar ui/settings ui/widgets utils`

---

## Phase 1: Data Layer

### Task 1.1: Note model and NoteStatus enum

**Files:**
- Create: `byte_voice/lib/models/note_status.dart`
- Create: `byte_voice/lib/models/note.dart`

- [ ] **Step 1: Create NoteStatus enum**

```dart
enum NoteStatus { transcribing, completed, failed }
enum NoteSource { recording, import }
```

- [ ] **Step 2: Create Note model**

```dart
class Note {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  final int durationMs;
  final String? audioFilePath;
  final bool keepAudio;
  final NoteSource source;
  NoteStatus status;
  double? currentProgress;
  
  Note({...});
  Note copyWith({...});
}
```

### Task 1.2: Segment model

**Files:**
- Create: `byte_voice/lib/models/segment.dart`

```dart
class Segment {
  final String id;
  final String noteId;
  final int startMs;
  final int endMs;
  String text;
  final double? confidence;
  final int sortIndex;
  
  Segment({...});
  Segment copyWith({String? text}) => Segment(id: id, noteId: noteId, ...);
}
```

### Task 1.3: Drift database tables

**Files:**
- Create: `byte_voice/lib/database/tables/notes_table.dart`
- Create: `byte_voice/lib/database/tables/segments_table.dart`
- Create: `byte_voice/lib/database/app_database.dart`

- [ ] **Step 1: Create drift table definitions**

```dart
// notes_table.dart
class NotesTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get durationMs => integer()();
  TextColumn? get audioFilePath => text().nullable()();
  BoolColumn get keepAudio => boolean()();
  TextColumn get source => text()();
  TextColumn get status => text()();
  RealColumn? get currentProgress => real().nullable()();
  @override Set<Column> get primaryKey => {id};
}

// segments_table.dart
class SegmentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text()();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();
  TextColumn get text => text()();
  RealColumn? get confidence => real().nullable()();
  IntColumn get sortIndex => integer()();
  @override Set<Column> get primaryKey => {id};
  @override List<String> get customConstraints => [
    'FOREIGN KEY (noteId) REFERENCES notes(id) ON DELETE CASCADE',
  ];
}
```

- [ ] **Step 2: Create AppDatabase**

```dart
@DriftDatabase(tables: [NotesTable, SegmentsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'byte_voice.db'));
    return NativeDatabase(file);
  });
}
```

- [ ] **Step 3: Run build_runner**

Run: `cd byte_voice && dart run build_runner build`

---

## Phase 2: Services

### Task 2.1: Transcription service (state machine)

**Files:**
- Create: `byte_voice/lib/services/transcription_service.dart`

```dart
enum TranscriptionState { idle, recording, paused, done }

class TranscriptionService {
  final _stateController = StreamController<TranscriptionState>.broadcast();
  final _segmentController = StreamController<Map<String, dynamic>>.broadcast();
  
  TranscriptionState _state = TranscriptionState.idle;
  TranscriptionState get state => _state;
  Stream<TranscriptionState> get stateStream => _stateController.stream;
  Stream<Map<String, dynamic>> get segmentStream => _segmentController.stream;
  
  String? _currentNoteId;
  String? get currentNoteId => _currentNoteId;
  
  Future<void> startRecording() async { ... }
  Future<void> pauseRecording() async { ... }
  Future<void> resumeRecording() async { ... }
  Future<String> stopRecording() async { ... }
  void dispose() { ... }
}
```

### Task 2.2: Audio import service

**Files:**
- Create: `byte_voice/lib/services/audio_import_service.dart`

```dart
class AudioImportService {
  final _progressController = StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;
  bool _isImporting = false;
  bool get isImporting => _isImporting;
  
  Future<String> importFile(String filePath) async { ... }
  void cancel() { ... }
  void dispose() { ... }
}
```

### Task 2.3: Model download service

```dart
enum ModelDownloadState { notDownloaded, downloading, downloaded, error }

class ModelDownloadService {
  final _stateController = StreamController<ModelDownloadState>.broadcast();
  final _progressController = StreamController<double>.broadcast();
  
  Future<void> downloadModels() async { ... }
  String? get modelsPath => null;
  void dispose() { ... }
}
```

### Task 2.4: Export service

```dart
enum ExportFormat { txt, md, srt }

class ExportService {
  String export(Note note, List<Segment> segments, ExportFormat format) { ... }
  String _exportTxt(Note note, List<Segment> segments) { ... }
  String _exportMd(Note note, List<Segment> segments) { ... }
  String _exportSrt(Note note, List<Segment> segments) { ... }
}
```

### Task 2.5: Notification service

```dart
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async { ... }
  Future<void> showTranscriptionComplete(String noteId, String title) async { ... }
}
```

---

## Phase 3: macOS Desktop UI

### Task 3.1: App theme

**Files:**
- Create: `byte_voice/lib/app_theme.dart`

```dart
class AppTheme {
  static const bgColor = Color(0xFF10131B);
  static const surfaceColor = Color(0xFF1E1E1E);
  static const sidebarColor = Color(0xFF1C2027);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA1A1A1);
  static const textTertiary = Color(0xFF6E6E6E);
  static const accentBlue = Color(0xFF0A84FF);
  static const accentRed = Color(0xFFFF453A);
  static const accentGreen = Color(0xFF32D74B);
  static const borderColor = Color(0xFF333333);
  static const navActiveBg = Color(0xFF252527);
}
```

### Task 3.2: Main window, sidebar, content, toolbar, settings

- [ ] **Create: main_window.dart** — macOS single-window layout with NavigationSplitView-like sidebar + content + toolbar
- [ ] **Create: sidebar_panel.dart** — Sidebar with search, note list grouped by date
- [ ] **Create: note_list_item.dart** — Note row with title, date, status badge
- [ ] **Create: content_area.dart** — State-driven content switcher
- [ ] **Create: note_detail.dart** — Note detail with segment timeline
- [ ] **Create: segment_item.dart** — Segment row (timestamp + text)
- [ ] **Create: transcript_stream.dart** — Live transcription stream view
- [ ] **Create: import_progress.dart** — Import progress bar
- [ ] **Create: empty_state.dart** — Empty state guide
- [ ] **Create: bottom_toolbar.dart** — Recording/import controls
- [ ] **Create: settings_window.dart** — Settings floating window with tabs
- [ ] **Create: app.dart** — MaterialApp with ProviderScope
- [ ] **Create: utils/time_utils.dart** — Duration formatting helpers

---

## Phase 4: Repository Layer (Database I/O)

### Task 4.1: Notes repository

**Files:**
- Create: `byte_voice/lib/database/repositories/notes_repository.dart`

```dart
class NotesRepository {
  final AppDatabase _db;
  NotesRepository(this._db);
  
  Future<List<Note>> getAll({String? searchQuery}) async { ... }
  Future<Note?> getById(String id) async { ... }
  Future<Note> create(Note note) async { ... }
  Future<Note> update(Note note) async { ... }
  Future<void> delete(String id) async { ... }
}
```

### Task 4.2: Segments repository

```dart
class SegmentsRepository {
  final AppDatabase _db;
  SegmentsRepository(this._db);
  
  Future<List<Segment>> getByNoteId(String noteId) async { ... }
  Future<void> bulkInsert(String noteId, List<Segment> segments) async { ... }
  Future<void> updateText(String id, String text) async { ... }
  Future<void> deleteByNoteId(String noteId) async { ... }
}
```

### Task 4.3: Settings repository (SharedPreferences)

```dart
class SettingsRepository {
  static const _prefix = 'bytevoice_';
  Future<String?> get(String key) async { ... }
  Future<void> set(String key, String value) async { ... }
  Future<String> getOrDefault(String key, String defaultValue) async { ... }
}
```

---

## Phase 5: Riverpod Providers (State Wiring)

### Task 5.1: Core providers

- [ ] **Create: providers/notes_provider.dart** — NotesRepository, appDatabase, notes list FutureProvider
- [ ] **Create: providers/transcription_provider.dart** — TranscriptionService + state StreamProvider
- [ ] **Create: providers/settings_provider.dart** — Settings state
- [ ] **Create: providers/model_provider.dart** — Model download/load state

```dart
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
final notesRepositoryProvider = Provider<NotesRepository>((ref) { ... });
final notesProvider = FutureProvider<List<Note>>((ref) async { ... });
```

---

## Phase 6: Integration — Wire UI to Backend

### Task 6.1: Content area state switching

- [ ] **Step 1: Update content_area.dart** — watch transcription state and note selection
- [ ] **Step 2: Wire recording button to TranscriptionService**
- [ ] **Step 3: Wire import button to AudioImportService**
- [ ] **Step 4: Wire settings button to open SettingsWindow**
- [ ] **Step 5: Wire note list selection to show NoteDetail**

### Task 6.2: Export and search

- [ ] **Wire export button to ExportService**
- [ ] **Wire sidebar search to NotesRepository search**
- [ ] **Wire delete button to NotesRepository.delete**

---

## Self-Review

| Check | Result |
|-------|--------|
| Spec coverage | All PRD sections covered: data model, 4-layer architecture, state machine, settings, export, search, edge cases |
| Type consistency | NoteStatus enum, Segment model, Note model consistent across all files |
| Scope check | Focused on macOS V1. iOS/mobile features excluded. Phase boundaries clear. |

### Uncovered items (explicitly deferred):
- **sherpa_onnx engine integration** — planned as separate phase after UI scaffolding
- **Audio recording (mic) + playback** — stubs created
- **Background processing** — workmanager setup deferred to post-engine phase
- **FFmpeg file decoding** — import service stub created

---

## Execution Handoff

**Plan complete.** Two execution options:

1. **Subagent-Driven (recommended)** — dispatch a fresh subagent per task, review between tasks
2. **Inline Execution** — Execute tasks in batches with checkpoints for review

Which approach?
