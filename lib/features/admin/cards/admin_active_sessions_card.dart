import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/media/media_cache_service.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/ui/cards/collapsible_card_base.dart';
import 'package:cyberdriver/core/ui/widgets/app_notifications.dart';
import 'package:cyberdriver/core/ui/widgets/track_meta_pills.dart';
import 'package:cyberdriver/features/admin/data/admin_active_sessions_api.dart';
import 'package:cyberdriver/features/admin/data/admin_records_api.dart';
import 'package:cyberdriver/features/cars/data/cars_api.dart';
import 'package:cyberdriver/features/tracks/data/tracks_api.dart';
import 'package:cyberdriver/shared/models/car_dto.dart';
import 'package:cyberdriver/shared/models/track_dto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminActiveSessionsCard extends CollapsibleCardBase {
  const AdminActiveSessionsCard({super.key});

  @override
  String get kickerText => '[КОКПИТЫ]';

  @override
  Color? get kickerColor => Colors.white70;

  @override
  Widget buildExpandedContent(BuildContext context, bool expanded) =>
      _AdminActiveSessionsContent(active: expanded);
}

class _AdminActiveSessionsContent extends StatefulWidget {
  const _AdminActiveSessionsContent({required this.active});

  final bool active;

  @override
  State<_AdminActiveSessionsContent> createState() =>
      _AdminActiveSessionsContentState();
}

class _AdminActiveSessionsContentState
    extends State<_AdminActiveSessionsContent> with WidgetsBindingObserver {
  static const double _listHeight = 280;
  static const Duration _pollIdleInterval = Duration(minutes: 1);
  static const Duration _pollActiveInterval = Duration(seconds: 10);
  static const Duration _timerTickInterval = Duration(milliseconds: 100);
  static const String _sessionsCacheKey = 'admin_active_sessions_cache_v1';
  static const String _timerCacheKey = 'admin_active_sessions_timer_v1';

  late final AdminActiveSessionsApi _api;
  late final AdminRecordsApi _recordsApi;
  late final CarsApi _carsApi;
  late final TracksApi _tracksApi;

  AuthService? _auth;
  bool _authReady = false;
  SharedPreferences? _prefs;
  bool _prefsReady = false;
  Timer? _pollTimer;
  bool _loading = false;
  bool _savingRecord = false;
  String? _error;
  int _officeIndex = 0;
  _TimerMode _timerMode = _TimerMode.group;
  _TimerSnapshot _groupTimer = const _TimerSnapshot();
  _TimerSnapshot _enduranceTimer = const _TimerSnapshot();
  Timer? _timerTicker;

  final List<ActiveSessionDto> _sessions = [];
  final Map<String, int> _carIdByExternal = {};
  final Map<String, int> _trackIdByExternal = {};
  final Map<int, CarDto> _cars = {};
  final Map<int, TrackDto> _tracks = {};
  final Map<int, UserMiniDto> _users = {};

  @override
  void initState() {
    super.initState();
    _api = AdminActiveSessionsApi(createApiClient(AppConfig.dev));
    _recordsApi = AdminRecordsApi(createApiClient(AppConfig.dev));
    _carsApi = CarsApi(createApiClient(AppConfig.dev));
    _tracksApi = TracksApi(createApiClient(AppConfig.dev));
    WidgetsBinding.instance.addObserver(this);
    _initPrefs();
    _initAuth();
  }

  @override
  void didUpdateWidget(covariant _AdminActiveSessionsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _startPolling();
    } else if (!widget.active && oldWidget.active) {
      _stopPolling();
    }
  }

  @override
  void dispose() {
    _stopPolling();
    _stopTimerTicker();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _persistTimerState();
    }
  }

  Future<void> _initAuth() async {
    final auth = await AuthService.getInstance();
    await auth.loadSession();
    if (!mounted) return;
    setState(() {
      _auth = auth;
      _authReady = true;
    });
    if (widget.active) {
      _startPolling(forceRefresh: true);
    }
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _prefs = prefs;
    _prefsReady = true;
    _restoreTimerState();
    _loadSessionsCacheForOffice(_officeIndex);
  }

  void _startPolling({bool forceRefresh = false}) {
    if (_pollTimer != null) {
      if (forceRefresh) {
        _refresh();
      }
      return;
    }
    _refresh();
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _scheduleNext(Duration delay) {
    _pollTimer?.cancel();
    _pollTimer = Timer(delay, () {
      if (!mounted) return;
      _refresh();
    });
  }

  _TimerSnapshot get _activeTimer =>
      _timerMode == _TimerMode.group ? _groupTimer : _enduranceTimer;

  void _setTimerMode(_TimerMode mode) {
    if (_timerMode == mode) return;
    setState(() => _timerMode = mode);
    if (_activeTimer.state == _TimerState.running) {
      _startTimerTicker();
    } else {
      _stopTimerTicker();
    }
  }

  void _startTimer() {
    final timer = _activeTimer;
    if (timer.state == _TimerState.running) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = timer.copyWith(
      state: _TimerState.running,
      startAtMs: now,
    );
    _setActiveTimer(updated);
    _startTimerTicker();
    _persistTimerState();
  }

  void _pauseTimer() {
    final timer = _activeTimer;
    if (timer.state != _TimerState.running) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = timer.elapsedAt(now);
    _setActiveTimer(
      timer.copyWith(
        state: _TimerState.paused,
        elapsedMs: elapsedMs,
        startAtMs: 0,
      ),
    );
    _stopTimerTicker();
    _persistTimerState();
  }

  void _resetTimer() {
    _setActiveTimer(const _TimerSnapshot());
    _stopTimerTicker();
    _persistTimerState();
  }

  void _saveTimer() {
    _saveRecord();
  }

  void _startTimerTicker() {
    _timerTicker?.cancel();
    _timerTicker = Timer.periodic(_timerTickInterval, (_) {
      if (!mounted || _activeTimer.state != _TimerState.running) return;
      setState(() {});
    });
  }

  void _stopTimerTicker() {
    _timerTicker?.cancel();
    _timerTicker = null;
  }

  String _formatElapsed(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final centiseconds = duration.inMilliseconds.remainder(1000) ~/ 10;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(hours)}:${two(minutes)}:${two(seconds)}.${two(centiseconds)}';
  }

  _RecordDraft? _buildRecordDraft({int? nowMs}) {
    if (_sessions.isEmpty) return null;
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = _activeTimer.elapsedAt(now);
    if (elapsedMs <= 0) return null;

    final trackCounts = <int, int>{};
    for (final s in _sessions) {
      final trackId = _trackIdByExternal[s.externalTrackId];
      if (trackId == null || trackId <= 0) {
        return null;
      }
      trackCounts[trackId] = (trackCounts[trackId] ?? 0) + 1;
    }
    if (trackCounts.isEmpty) return null;

    var majorityTrackId = 0;
    var majorityCount = -1;
    trackCounts.forEach((trackId, count) {
      if (count > majorityCount) {
        majorityCount = count;
        majorityTrackId = trackId;
      }
    });
    if (majorityTrackId <= 0) return null;

    final participants = <AdminRecordParticipant>[];
    for (final s in _sessions) {
      final trackId = _trackIdByExternal[s.externalTrackId];
      if (trackId != majorityTrackId) continue;
      final carId = _carIdByExternal[s.externalCarId];
      if (carId == null || carId <= 0) {
        return null;
      }
      if (s.userId <= 0) {
        return null;
      }
      participants.add(AdminRecordParticipant(userId: s.userId, carId: carId));
    }
    if (participants.isEmpty) return null;

    final lapTimeSeconds = elapsedMs / 1000.0;
    final durationHours = (lapTimeSeconds / 3600).ceil().toDouble();
    return _RecordDraft(
      trackId: majorityTrackId,
      lapTimeSeconds: lapTimeSeconds,
      durationHours: durationHours,
      participants: participants,
    );
  }

  Future<void> _saveRecord() async {
    if (_savingRecord) return;
    final auth = _auth;
    if (auth == null || auth.session == null) {
      AppNotifications.error('Нет авторизации для сохранения рекорда');
      return;
    }

    final draft = _buildRecordDraft();
    if (draft == null) {
      AppNotifications.error('Данные ещё загружаются');
      return;
    }

    setState(() => _savingRecord = true);
    try {
      if (_timerMode == _TimerMode.group) {
        await _recordsApi.createGroupRecordWithAuth(
          auth: auth,
          trackId: draft.trackId,
          lapTimeSeconds: draft.lapTimeSeconds,
          minMassPowerRatio: 0,
          participants: draft.participants,
        );
      } else {
        await _recordsApi.createGroupDurationRecordWithAuth(
          auth: auth,
          trackId: draft.trackId,
          durationHours: draft.durationHours,
          lapTimeSeconds: draft.lapTimeSeconds,
          className: 'duration',
          trackDuration: 0,
          participants: draft.participants,
        );
      }
      if (!mounted) return;
      AppNotifications.show('Рекорд сохранён');
      _resetTimer();
    } catch (e) {
      if (!mounted) return;
      AppNotifications.error('Ошибка сохранения рекорда');
    } finally {
      if (mounted) {
        setState(() => _savingRecord = false);
      }
    }
  }

  void _setActiveTimer(_TimerSnapshot snapshot) {
    setState(() {
      if (_timerMode == _TimerMode.group) {
        _groupTimer = snapshot;
      } else {
        _enduranceTimer = snapshot;
      }
    });
  }

  void _restoreTimerState() {
    if (!_prefsReady) return;
    final raw = _prefs?.getString(_timerCacheKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return;
      final groupJson = json['group'];
      final enduranceJson = json['endurance'];
      setState(() {
        _groupTimer = _TimerSnapshot.fromJson(groupJson);
        _enduranceTimer = _TimerSnapshot.fromJson(enduranceJson);
      });
      if (_activeTimer.state == _TimerState.running) {
        _startTimerTicker();
      }
    } catch (_) {}
  }

  void _persistTimerState() {
    if (!_prefsReady) return;
    final payload = <String, dynamic>{
      'group': _groupTimer.toJson(),
      'endurance': _enduranceTimer.toJson(),
    };
    _prefs?.setString(_timerCacheKey, jsonEncode(payload));
  }

  void _persistSessionsCache(String appToken, List<ActiveSessionDto> sessions) {
    if (!_prefsReady) return;
    final raw = _prefs?.getString(_sessionsCacheKey);
    Map<String, dynamic> payload = {};
    if (raw != null && raw.isNotEmpty) {
      try {
        final json = jsonDecode(raw);
        if (json is Map<String, dynamic>) payload = json;
      } catch (_) {}
    }
    payload[appToken] = sessions.map(_sessionToJson).toList();
    _prefs?.setString(_sessionsCacheKey, jsonEncode(payload));
  }

  void _loadSessionsCacheForOffice(int officeIndex) {
    if (!_prefsReady) return;
    final offices = AppConfig.dev.offices;
    if (offices.isEmpty) return;
    final safeIndex = officeIndex.clamp(0, offices.length - 1);
    final appToken = offices[safeIndex].appToken;
    final raw = _prefs?.getString(_sessionsCacheKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final json = jsonDecode(raw);
      if (json is! Map) return;
      final list = json[appToken];
      if (list is! List) return;
      final sessions = list
          .whereType<Map>()
          .map((e) => ActiveSessionDto.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();
      if (!mounted) return;
      setState(() {
        _sessions
          ..clear()
          ..addAll(sessions);
      });
      final auth = _auth;
      if (auth != null) {
        _ensureDetails(sessions);
      }
    } catch (_) {}
  }

  Map<String, dynamic> _sessionToJson(ActiveSessionDto s) => {
        'external_car_id': s.externalCarId,
        'external_track_id': s.externalTrackId,
        'assistant_token': s.assistantToken,
        'user_id': s.userId,
        'beat_at_utc': s.beatAtUtc,
      };

  Future<void> _refresh() async {
    if (_loading) return;
    final auth = _auth;
    if (auth == null) return;
    final offices = AppConfig.dev.offices;
    if (offices.isEmpty) return;
    final appToken = offices[_officeIndex.clamp(0, offices.length - 1)].appToken;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final sessions = await _api.getActiveSessionsWithAuth(auth, appToken);
      if (!mounted) return;
      setState(() {
        _sessions
          ..clear()
          ..addAll(sessions);
        _loading = false;
      });
      _persistSessionsCache(appToken, sessions);
      await _ensureDetails(sessions);
      _scheduleNext(
        _sessions.isNotEmpty ? _pollActiveInterval : _pollIdleInterval,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Ошибка загрузки сессий';
      });
      _scheduleNext(_pollIdleInterval);
    }
  }

  Future<void> _ensureDetails(List<ActiveSessionDto> sessions) async {
    final auth = _auth;
    if (auth == null) return;

    final futures = <Future<void>>[];
    for (final s in sessions) {
      if (s.externalCarId.isNotEmpty &&
          !_carIdByExternal.containsKey(s.externalCarId)) {
        futures.add(_resolveCar(auth, s.externalCarId));
      }
      if (s.externalTrackId.isNotEmpty &&
          !_trackIdByExternal.containsKey(s.externalTrackId)) {
        futures.add(_resolveTrack(auth, s.externalTrackId));
      }
      if (s.userId > 0 && !_users.containsKey(s.userId)) {
        futures.add(_loadUser(auth, s.userId));
      }
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
      if (mounted) setState(() {});
    }
  }

  Future<void> _resolveCar(AuthService auth, String externalId) async {
    try {
      final id = await _api.getCarIdByExternalWithAuth(auth, externalId);
      if (id <= 0) return;
      _carIdByExternal[externalId] = id;
      if (!_cars.containsKey(id)) {
        final car = await _carsApi.getCar(id);
        _cars[id] = car;
      }
    } catch (_) {}
  }

  Future<void> _resolveTrack(AuthService auth, String externalId) async {
    try {
      final id = await _api.getTrackIdByExternalWithAuth(auth, externalId);
      if (id <= 0) return;
      _trackIdByExternal[externalId] = id;
      if (!_tracks.containsKey(id)) {
        final track = await _tracksApi.getTrack(id);
        _tracks[id] = track;
      }
    } catch (_) {}
  }

  Future<void> _loadUser(AuthService auth, int userId) async {
    try {
      final user = await _api.getUserByIdWithAuth(auth, userId);
      _users[userId] = user;
    } catch (_) {}
  }

  void _selectOffice(int index) {
    if (_officeIndex == index) return;
    setState(() {
      _officeIndex = index;
      _sessions.clear();
      _carIdByExternal.clear();
      _trackIdByExternal.clear();
      _cars.clear();
      _tracks.clear();
      _users.clear();
      _error = null;
    });
    _loadSessionsCacheForOffice(index);
    _refresh();
  }

  String _carName(CarDto c) {
    final name = c.name.trim();
    if (name.isNotEmpty) return name;
    final brand = c.brand.trim();
    final model = c.model.trim();
    if (brand.isEmpty) return model;
    if (model.isEmpty) return brand;
    return '$brand $model';
  }

  @override
  Widget build(BuildContext context) {
    if (!_authReady) {
      return const SizedBox.shrink();
    }
    final auth = _auth;
    if (auth == null || auth.session == null) {
      return const SizedBox.shrink();
    }
    final offices = AppConfig.dev.offices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < offices.length; i++) ...[
                      MetaPill(
                        value: offices[i].name,
                        tone: i == _officeIndex
                            ? MetaPillTone.pink
                            : MetaPillTone.dark,
                        clickable: true,
                        onTap: () => _selectOffice(i),
                      ),
                      if (i != offices.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Обновить',
              onPressed: _loading ? null : _refresh,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _SessionsList(
          height: _listHeight,
          sessions: _sessions,
          isLoading: _loading,
          error: _error,
          cars: _cars,
          tracks: _tracks,
          users: _users,
          carIdByExternal: _carIdByExternal,
          trackIdByExternal: _trackIdByExternal,
          carName: _carName,
          onRetry: _refresh,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            MetaPill(
              value: 'ГРУППОВЫЕ',
              tone: _timerMode == _TimerMode.group
                  ? MetaPillTone.pink
                  : MetaPillTone.dark,
              clickable: true,
              onTap: () => _setTimerMode(_TimerMode.group),
            ),
            MetaPill(
              value: 'ВЫНОСЛИВОСТЬ',
              tone: _timerMode == _TimerMode.endurance
                  ? MetaPillTone.pink
                  : MetaPillTone.dark,
              clickable: true,
              onTap: () => _setTimerMode(_TimerMode.endurance),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Text(
            _formatElapsed(
              Duration(milliseconds: _activeTimer.elapsedAt(
                DateTime.now().millisecondsSinceEpoch,
              )),
            ),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_activeTimer.state == _TimerState.idle)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _savingRecord ? null : _startTimer,
              child: const Text('СТАРТ'),
            ),
          )
        else if (_activeTimer.state == _TimerState.running)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _savingRecord ? null : _pauseTimer,
              child: const Text('ПАУЗА'),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _savingRecord ? null : _resetTimer,
                    child: const Text('СБРОС'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _savingRecord ? null : _saveTimer,
                    child: _savingRecord
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('СОХРАНИТЬ'),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

enum _TimerMode { group, endurance }

enum _TimerState { idle, running, paused }

@immutable
class _TimerSnapshot {
  const _TimerSnapshot({
    this.state = _TimerState.idle,
    this.elapsedMs = 0,
    this.startAtMs = 0,
  });

  final _TimerState state;
  final int elapsedMs;
  final int startAtMs;

  int elapsedAt(int nowMs) {
    if (state != _TimerState.running) return elapsedMs;
    final delta = nowMs - startAtMs;
    if (delta <= 0) return elapsedMs;
    return elapsedMs + delta;
  }

  _TimerSnapshot copyWith({
    _TimerState? state,
    int? elapsedMs,
    int? startAtMs,
  }) {
    return _TimerSnapshot(
      state: state ?? this.state,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      startAtMs: startAtMs ?? this.startAtMs,
    );
  }

  Map<String, dynamic> toJson() => {
        'state': state.name,
        'elapsedMs': elapsedMs,
        'startAtMs': startAtMs,
      };

  static _TimerSnapshot fromJson(Object? raw) {
    if (raw is! Map) return const _TimerSnapshot();
    final map = Map<String, dynamic>.from(raw);
    final stateRaw = map['state']?.toString() ?? 'idle';
    final state = _TimerState.values.firstWhere(
      (s) => s.name == stateRaw,
      orElse: () => _TimerState.idle,
    );
    final elapsedMs = map['elapsedMs'];
    final startAtMs = map['startAtMs'];
    return _TimerSnapshot(
      state: state,
      elapsedMs: elapsedMs is int ? elapsedMs : 0,
      startAtMs: startAtMs is int ? startAtMs : 0,
    );
  }
}

class _RecordDraft {
  const _RecordDraft({
    required this.trackId,
    required this.lapTimeSeconds,
    required this.durationHours,
    required this.participants,
  });

  final int trackId;
  final double lapTimeSeconds;
  final double durationHours;
  final List<AdminRecordParticipant> participants;
}

class _SessionsList extends StatelessWidget {
  const _SessionsList({
    required this.height,
    required this.sessions,
    required this.isLoading,
    required this.error,
    required this.cars,
    required this.tracks,
    required this.users,
    required this.carIdByExternal,
    required this.trackIdByExternal,
    required this.carName,
    required this.onRetry,
  });

  final double height;
  final List<ActiveSessionDto> sessions;
  final bool isLoading;
  final String? error;
  final Map<int, CarDto> cars;
  final Map<int, TrackDto> tracks;
  final Map<int, UserMiniDto> users;
  final Map<String, int> carIdByExternal;
  final Map<String, int> trackIdByExternal;
  final String Function(CarDto) carName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isLoading && sessions.isEmpty && error == null) {
      return Container(
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (error != null && sessions.isEmpty) {
      return Container(
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error!,
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: .75),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (sessions.isEmpty) {
      return Container(
        height: 96,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Text(
          'Активных сессий нет',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: sessions.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final s = sessions[i];
          final user = users[s.userId];
          final carId = carIdByExternal[s.externalCarId];
          final trackId = trackIdByExternal[s.externalTrackId];
          final car = carId != null ? cars[carId] : null;
          final track = trackId != null ? tracks[trackId] : null;
          return _SessionRow(
            user: user,
            car: car,
            track: track,
            carName: carName,
          );
        },
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.user,
    required this.car,
    required this.track,
    required this.carName,
  });

  final UserMiniDto? user;
  final CarDto? car;
  final TrackDto? track;
  final String Function(CarDto) carName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final login = user?.login.trim() ?? 'user';
    final name = user?.name.trim() ?? '';
    final displayName = name.isEmpty ? login : name;
    final carTitle =
        car != null ? 'Машина: ${carName(car!)}' : 'Машина: —';
    final trackTitle = track?.name.trim().isNotEmpty == true
        ? 'Трек: ${track!.name}'
        : 'Трек: —';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cs.surface.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          _UserAvatar(imageHash: user?.imageHash ?? ''),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@$login',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                carTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                trackTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.imageHash});

  final String imageHash;

  @override
  Widget build(BuildContext context) {
    const size = 40.0;
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: const Icon(Icons.person, size: 20),
    );

    if (imageHash.isEmpty) return placeholder;

    return FutureBuilder<File>(
      future: MediaCacheService.instance.getImageFile(
        id: imageHash,
        cacheDuration: const Duration(days: 1),
        config: AppConfig.dev,
      ),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) {
          return placeholder;
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
