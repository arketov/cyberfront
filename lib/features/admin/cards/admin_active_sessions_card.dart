import 'dart:async';
import 'dart:io';

import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/media/media_cache_service.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/ui/cards/collapsible_card_base.dart';
import 'package:cyberdriver/core/ui/widgets/track_meta_pills.dart';
import 'package:cyberdriver/features/admin/data/admin_active_sessions_api.dart';
import 'package:cyberdriver/features/cars/data/cars_api.dart';
import 'package:cyberdriver/features/tracks/data/tracks_api.dart';
import 'package:cyberdriver/shared/models/car_dto.dart';
import 'package:cyberdriver/shared/models/track_dto.dart';
import 'package:flutter/material.dart';

class AdminActiveSessionsCard extends CollapsibleCardBase {
  AdminActiveSessionsCard({super.key});

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
    extends State<_AdminActiveSessionsContent> {
  static const double _listHeight = 280;
  static const Duration _pollIdleInterval = Duration(minutes: 1);
  static const Duration _pollActiveInterval = Duration(seconds: 10);

  late final AdminActiveSessionsApi _api;
  late final CarsApi _carsApi;
  late final TracksApi _tracksApi;

  AuthService? _auth;
  bool _authReady = false;
  Timer? _pollTimer;
  bool _loading = false;
  String? _error;
  int _officeIndex = 0;

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
    _carsApi = CarsApi(createApiClient(AppConfig.dev));
    _tracksApi = TracksApi(createApiClient(AppConfig.dev));
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
    super.dispose();
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
      ],
    );
  }
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
        separatorBuilder: (_, __) => const SizedBox(height: 8),
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
