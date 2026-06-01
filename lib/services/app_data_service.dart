import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/bird_record.dart';
import '../models/community_event.dart';
import '../models/community_post.dart';
import '../models/moderation_report.dart';

class AppDataService extends ChangeNotifier {
  final List<BirdRecord> _birdRecords = [];
  final List<CommunityEvent> _communityEvents = [];
  final List<CommunityPost> _communityPosts = [];
  final List<ModerationReport> _reports = [];

  File? _databaseFile;
  bool moderationFilterEnabled = true;
  String? _dailyBirdRecordId;
  String? _previousDailyBirdRecordId;
  String? _dailyBirdDateKey;

  List<BirdRecord> get birdRecords => List.unmodifiable(_birdRecords);
  List<CommunityEvent> get communityEvents =>
      List.unmodifiable(_communityEvents.where((event) => !event.hidden));
  List<CommunityPost> get communityPosts =>
      List.unmodifiable(_communityPosts.where((post) => !post.hidden));
  List<ModerationReport> get reports => List.unmodifiable(_reports);

  BirdRecord? get dailyBird {
    if (_birdRecords.isEmpty) return null;
    _selectDailyBirdIfNeeded();
    return _birdRecords.cast<BirdRecord?>().firstWhere(
      (record) => record?.id == _dailyBirdRecordId,
      orElse: () => _birdRecords.first,
    );
  }

  int get joinedEventsCount =>
      _communityEvents.where((event) => event.currentUserParticipated).length;

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _databaseFile = File(
      '${directory.path}${Platform.pathSeparator}avescl_db.json',
    );

    if (await _databaseFile!.exists()) {
      await _loadFromDisk();
      _selectDailyBirdIfNeeded();
      await _save();
      return;
    }

    _seedInitialData();
    _selectDailyBirdIfNeeded();
    await _save();
  }

  Future<BirdRecord> addBirdRecord({
    required String originalImagePath,
    required String commonName,
    required String scientificName,
    required String zone,
    required String certainty,
    required String notes,
    required BirdRecordStatus status,
  }) async {
    final savedPath = await _copyImageToAppFolder(originalImagePath);
    final record = BirdRecord(
      id: _newId('bird'),
      commonName: commonName.trim().isEmpty
          ? 'Ave sin clasificar'
          : commonName.trim(),
      scientificName: scientificName.trim().isEmpty
          ? 'Pendiente de identificar'
          : scientificName.trim(),
      zone: zone.trim().isEmpty ? 'Sin ubicacion' : zone.trim(),
      createdAt: DateTime.now(),
      certainty: certainty,
      imagePath: savedPath,
      notes: notes.trim(),
      status: status,
    );

    _birdRecords.insert(0, record);

    await _save();
    return record;
  }

  Future<void> deleteBirdRecord(String recordId) async {
    final index = _birdRecords.indexWhere((record) => record.id == recordId);
    if (index == -1) return;

    final record = _birdRecords.removeAt(index);
    final imagePath = record.imagePath;
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    for (var i = 0; i < _communityEvents.length; i++) {
      final event = _communityEvents[i];
      if (!event.submittedRecordIds.contains(recordId)) continue;

      final updatedSubmissions = event.submittedRecordIds
          .where((submittedId) => submittedId != recordId)
          .toList();
      _communityEvents[i] = event.copyWith(
        submittedRecordIds: updatedSubmissions,
        participants: max(0, event.participants - 1),
      );
    }

    if (_dailyBirdRecordId == recordId) {
      _dailyBirdRecordId = null;
      _dailyBirdDateKey = null;
    }
    if (_previousDailyBirdRecordId == recordId) {
      _previousDailyBirdRecordId = null;
    }

    await _save();
  }

  Future<void> addCommunityEvent({
    required String title,
    required String description,
    required String birdFocus,
    required int durationDays,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;

    _communityEvents.insert(
      0,
      CommunityEvent(
        id: _newId('event'),
        title: cleanTitle,
        description: description.trim().isEmpty
            ? 'Competencia fotografica de la comunidad AvesCL.'
            : description.trim(),
        birdFocus: birdFocus.trim().isEmpty ? 'Tema libre' : birdFocus.trim(),
        createdAt: DateTime.now(),
        endsAt: DateTime.now().add(Duration(days: durationDays)),
        likes: 0,
        participants: 0,
        hidden: false,
        likedByCurrentUser: false,
        submittedRecordIds: const [],
      ),
    );

    await _save();
  }

  Future<bool> likeEvent(String eventId) async {
    final index = _communityEvents.indexWhere((event) => event.id == eventId);
    if (index == -1 || _communityEvents[index].likedByCurrentUser) {
      return false;
    }

    _communityEvents[index] = _communityEvents[index].copyWith(
      likes: _communityEvents[index].likes + 1,
      likedByCurrentUser: true,
    );
    await _save();
    return true;
  }

  Future<bool> joinEvent(String eventId, String birdRecordId) async {
    final index = _communityEvents.indexWhere((event) => event.id == eventId);
    if (index == -1 || _communityEvents[index].currentUserParticipated) {
      return false;
    }

    final submittedRecordIds = [
      ..._communityEvents[index].submittedRecordIds,
      birdRecordId,
    ];

    _communityEvents[index] = _communityEvents[index].copyWith(
      participants: _communityEvents[index].participants + 1,
      submittedRecordIds: submittedRecordIds,
    );
    await _save();
    return true;
  }

  Future<void> createEventReport({
    required CommunityEvent event,
    required String reason,
    required String detail,
  }) async {
    final automaticFlag =
        moderationFilterEnabled && _looksRisky(reason, detail);
    _reports.insert(
      0,
      ModerationReport(
        id: _newId('report'),
        postId: event.id,
        reportedUser: event.title,
        reason: reason,
        detail: detail.trim(),
        reporter: 'Comunidad',
        createdAt: DateTime.now(),
        status: automaticFlag ? ReportStatus.blocked : ReportStatus.pending,
        automaticFlag: automaticFlag,
      ),
    );

    if (automaticFlag) {
      await updateEventVisibility(
        event.id,
        hidden: true,
        saveAfterChange: false,
      );
    }

    await _save();
  }

  Future<void> addCommunityPost(String description) async {
    final cleanDescription = description.trim();
    if (cleanDescription.isEmpty) return;

    _communityPosts.insert(
      0,
      CommunityPost(
        id: _newId('post'),
        author: 'Tu',
        description: cleanDescription,
        createdAt: DateTime.now(),
        imagePath: null,
        sourceRecordId: null,
        likes: 0,
        hidden: false,
      ),
    );

    await _save();
  }

  Future<void> likePost(String postId) async {
    final index = _communityPosts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    _communityPosts[index] = _communityPosts[index].copyWith(
      likes: _communityPosts[index].likes + 1,
    );
    await _save();
  }

  Future<void> createReport({
    required CommunityPost post,
    required String reason,
    required String detail,
  }) async {
    final automaticFlag =
        moderationFilterEnabled && _looksRisky(reason, detail);
    _reports.insert(
      0,
      ModerationReport(
        id: _newId('report'),
        postId: post.id,
        reportedUser: post.author,
        reason: reason,
        detail: detail.trim(),
        reporter: 'Comunidad',
        createdAt: DateTime.now(),
        status: automaticFlag ? ReportStatus.blocked : ReportStatus.pending,
        automaticFlag: automaticFlag,
      ),
    );

    if (automaticFlag) {
      await updatePostVisibility(post.id, hidden: true, saveAfterChange: false);
    }

    await _save();
  }

  Future<void> createManualReport({
    required String reportedUser,
    required String reason,
    required String detail,
  }) async {
    _reports.insert(
      0,
      ModerationReport(
        id: _newId('report'),
        postId: null,
        reportedUser: reportedUser.trim().isEmpty
            ? 'Usuario sin nombre'
            : reportedUser.trim(),
        reason: reason.trim().isEmpty ? 'Revision manual' : reason.trim(),
        detail: detail.trim(),
        reporter: 'Moderador',
        createdAt: DateTime.now(),
        status: ReportStatus.pending,
        automaticFlag: false,
      ),
    );
    await _save();
  }

  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    final index = _reports.indexWhere((report) => report.id == reportId);
    if (index == -1) return;

    _reports[index] = _reports[index].copyWith(status: status);

    final postId = _reports[index].postId;
    if (postId != null && status == ReportStatus.blocked) {
      await updatePostVisibility(postId, hidden: true, saveAfterChange: false);
      await updateEventVisibility(postId, hidden: true, saveAfterChange: false);
    }
    if (postId != null && status == ReportStatus.dismissed) {
      await updatePostVisibility(postId, hidden: false, saveAfterChange: false);
      await updateEventVisibility(
        postId,
        hidden: false,
        saveAfterChange: false,
      );
    }

    await _save();
  }

  Future<void> updatePostVisibility(
    String postId, {
    required bool hidden,
    bool saveAfterChange = true,
  }) async {
    final index = _communityPosts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    _communityPosts[index] = _communityPosts[index].copyWith(hidden: hidden);
    if (saveAfterChange) {
      await _save();
    }
  }

  Future<void> updateEventVisibility(
    String eventId, {
    required bool hidden,
    bool saveAfterChange = true,
  }) async {
    final index = _communityEvents.indexWhere((event) => event.id == eventId);
    if (index == -1) return;

    _communityEvents[index] = _communityEvents[index].copyWith(hidden: hidden);
    if (saveAfterChange) {
      await _save();
    }
  }

  Future<void> setModerationFilterEnabled(bool value) async {
    moderationFilterEnabled = value;
    await _save();
  }

  Future<String> _copyImageToAppFolder(String originalImagePath) async {
    final source = File(originalImagePath);
    if (!await source.exists()) return originalImagePath;

    final directory = await getApplicationDocumentsDirectory();
    final imagesDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}avescl_images',
    );
    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    final extension = originalImagePath.split('.').last;
    final target = File(
      '${imagesDirectory.path}${Platform.pathSeparator}${_newId('photo')}.$extension',
    );
    await source.copy(target.path);
    return target.path;
  }

  Future<void> _loadFromDisk() async {
    final raw = await _databaseFile!.readAsString();
    final json = jsonDecode(raw) as Map<String, dynamic>;

    moderationFilterEnabled = json['moderationFilterEnabled'] as bool? ?? true;
    _dailyBirdRecordId = json['dailyBirdRecordId'] as String?;
    _previousDailyBirdRecordId = json['previousDailyBirdRecordId'] as String?;
    _dailyBirdDateKey = json['dailyBirdDateKey'] as String?;
    _birdRecords
      ..clear()
      ..addAll(
        (json['birdRecords'] as List<dynamic>? ?? []).map(
          (item) => BirdRecord.fromJson(item as Map<String, dynamic>),
        ),
      );
    _communityPosts
      ..clear()
      ..addAll(
        (json['communityPosts'] as List<dynamic>? ?? []).map(
          (item) => CommunityPost.fromJson(item as Map<String, dynamic>),
        ),
      );
    _communityEvents
      ..clear()
      ..addAll(
        (json['communityEvents'] as List<dynamic>? ?? []).map(
          (item) => CommunityEvent.fromJson(item as Map<String, dynamic>),
        ),
      );
    if (_communityEvents.isEmpty) {
      _seedCommunityEvents();
    }
    _reports
      ..clear()
      ..addAll(
        (json['reports'] as List<dynamic>? ?? []).map(
          (item) => ModerationReport.fromJson(item as Map<String, dynamic>),
        ),
      );

    notifyListeners();
  }

  Future<void> _save() async {
    if (_databaseFile == null) return;

    final data = {
      'firebaseTarget': FirebaseCollectionNames.collections,
      'moderationFilterEnabled': moderationFilterEnabled,
      'dailyBirdRecordId': _dailyBirdRecordId,
      'previousDailyBirdRecordId': _previousDailyBirdRecordId,
      'dailyBirdDateKey': _dailyBirdDateKey,
      'birdRecords': _birdRecords.map((record) => record.toJson()).toList(),
      'communityEvents': _communityEvents
          .map((event) => event.toJson())
          .toList(),
      'communityPosts': _communityPosts.map((post) => post.toJson()).toList(),
      'reports': _reports.map((report) => report.toJson()).toList(),
    };

    await _databaseFile!.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
    notifyListeners();
  }

  void _seedInitialData() {
    _birdRecords.addAll([
      BirdRecord(
        id: _newId('bird'),
        commonName: 'Siete colores',
        scientificName: 'Tachuris rubrigastra',
        zone: 'Humedal',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        certainty: 'Alta',
        imagePath: null,
        notes: 'Registro inicial para mostrar la estructura de datos.',
        status: BirdRecordStatus.published,
      ),
      BirdRecord(
        id: _newId('bird'),
        commonName: 'Condor',
        scientificName: 'Vultur gryphus',
        zone: 'Cordillera',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        certainty: 'Alta',
        imagePath: null,
        notes: 'Avistamiento de ejemplo para la evaluacion intermedia.',
        status: BirdRecordStatus.published,
      ),
    ]);

    _seedCommunityEvents();

    _reports.add(
      ModerationReport(
        id: _newId('report'),
        postId: null,
        reportedUser: 'Bot_Spam',
        reason: 'Spam / publicidad',
        detail: 'Reporte de ejemplo para demostrar el flujo de moderacion.',
        reporter: 'Sistema',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: ReportStatus.resolved,
        automaticFlag: false,
      ),
    );
  }

  void _seedCommunityEvents() {
    _communityEvents.addAll([
      CommunityEvent(
        id: _newId('event'),
        title: 'Rapaces del Norte',
        description: 'Competencia semanal para reunir fotos de aves rapaces.',
        birdFocus: 'Aguilas, halcones y condores',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        endsAt: DateTime.now().add(const Duration(days: 6)),
        likes: 18,
        participants: 5,
        hidden: false,
        likedByCurrentUser: false,
        submittedRecordIds: const [],
      ),
      CommunityEvent(
        id: _newId('event'),
        title: 'Colores de Humedal',
        description: 'Evento de fotos enfocadas en aves de humedales urbanos.',
        birdFocus: 'Siete colores, taguas y garzas',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        endsAt: DateTime.now().add(const Duration(days: 4)),
        likes: 11,
        participants: 3,
        hidden: false,
        likedByCurrentUser: false,
        submittedRecordIds: const [],
      ),
    ]);
  }

  void _selectDailyBirdIfNeeded() {
    if (_birdRecords.isEmpty) return;

    final todayKey = _dateKey(DateTime.now());
    final selectedStillExists = _birdRecords.any(
      (record) => record.id == _dailyBirdRecordId,
    );
    if (_dailyBirdDateKey == todayKey &&
        _dailyBirdRecordId != null &&
        selectedStillExists) {
      return;
    }

    final candidates = _birdRecords
        .where((record) => record.id != _previousDailyBirdRecordId)
        .toList();
    final pool = candidates.isEmpty ? _birdRecords : candidates;
    final random = Random(todayKey.hashCode + _birdRecords.length);
    final selected = pool[random.nextInt(pool.length)];

    _previousDailyBirdRecordId = _dailyBirdRecordId;
    _dailyBirdRecordId = selected.id;
    _dailyBirdDateKey = todayKey;
  }

  String _dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  bool _looksRisky(String reason, String detail) {
    final text = '${reason.toLowerCase()} ${detail.toLowerCase()}';
    return text.contains('ofensivo') ||
        text.contains('spam') ||
        text.contains('publicidad') ||
        text.contains('irrelevante');
  }

  String _newId(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
  }
}

class FirebaseCollectionNames {
  static const Map<String, String> collections = {
    'birdRecords': 'bird_records',
    'communityEvents': 'community_events',
    'communityPosts': 'community_posts',
    'reports': 'moderation_reports',
  };
}
