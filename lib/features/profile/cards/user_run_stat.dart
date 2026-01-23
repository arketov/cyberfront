import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/features/profile/cards/widgets/favorite_run_card.dart';
import 'package:cyberdriver/features/profile/cards/widgets/run_stats_block.dart';
import 'package:cyberdriver/features/profile/data/user_run_stats_api.dart';
import 'package:cyberdriver/shared/models/user_run_stats_dto.dart';
import 'package:flutter/material.dart';

class UserRunStat extends StatefulWidget {
  const UserRunStat({super.key});

  @override
  State<UserRunStat> createState() => _UserRunStatState();
}

class _UserRunStatState extends State<UserRunStat> {
  bool _expanded = false;
  bool _loading = true;
  UserRunStatsDto? _stats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = await AuthService.getInstance();
      await auth.loadSession();
      final api = UserRunStatsApi(createApiClient(AppConfig.dev));
      final stats = await api.getRunStatsWithAuth(auth);
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Ошибка статистики: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _UserRunStatCardShell(
      onTapCallback: _toggleExpanded,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final expandHintStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: Colors.white.withValues(alpha: 0.55),
    );
    final errorStyle = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(color: Colors.redAccent);

    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CyberDotsLoader(width: 120, height: 44)),
      );
    }
    if (_error != null) {
      return Text(_error!, style: errorStyle);
    }

    final stats = _stats;
    final totalMeters = stats?.totalMeters ?? 0;
    final totalMinutes = stats?.totalMinutes ?? 0;
    final avgSpeedKmh = _calcAvgSpeed(totalMeters, totalMinutes);
    final favoriteCar = stats?.favoriteCar;
    final favoriteTrack = stats?.favoriteTrack;
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Kicker('[ЭТО АГРЕГАЦИЯ]', color: Colors.white70),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final useSingleColumn = constraints.maxWidth < 600;
              final spacing = useSingleColumn ? 10.0 : 12.0;
              final blockAWidth = useSingleColumn
                  ? constraints.maxWidth
                  : (constraints.maxWidth - spacing) * 0.4;
              final rightWidth = useSingleColumn
                  ? constraints.maxWidth
                  : (constraints.maxWidth - spacing) * 0.6;

              final blockA = SizedBox(
                width: blockAWidth,
                child: RunStatsBlock(
                  distanceMeters: totalMeters,
                  durationMinutes: totalMinutes,
                  avgSpeedKmh: avgSpeedKmh,
                ),
              );

              final rightColumn = SizedBox(
                width: rightWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FavoriteRunCard(
                      distance: totalMeters,
                      duration: totalMinutes,
                      imageHash: favoriteCar?.imageHash ?? '',
                      title: favoriteCar?.name ?? '—',
                      label: 'Любимая машина',
                      onTap: favoriteCar != null && favoriteCar.id > 0
                          ? () => Navigator.of(context).pushNamed(
                                '/cars/${favoriteCar.id}',
                                arguments: favoriteCar,
                              )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    FavoriteRunCard(
                      distance: totalMeters,
                      duration: totalMinutes,
                      imageHash: favoriteTrack?.imageHash ?? '',
                      title: favoriteTrack?.name ?? '—',
                      label: 'Любимый трек',
                      fadeRadius: 1.2,
                      fadeStops: const [0.0, 0.7, 1.0],
                      onTap: favoriteTrack != null && favoriteTrack.id > 0
                          ? () => Navigator.of(context).pushNamed(
                                '/tracks/${favoriteTrack.id}',
                                arguments: favoriteTrack,
                              )
                          : null,
                    ),
                  ],
                ),
              );

              if (useSingleColumn) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    blockA,
                    SizedBox(height: spacing),
                    rightColumn,
                  ],
                );
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    blockA,
                    SizedBox(width: spacing),
                    rightColumn,
                  ],
                ),
              );
            },
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            const Text('expanded placeholder'),
          ],
          SizedBox(height: _expanded ? 12 : 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  _expanded ? 'Свернуть' : 'Подробнее',
                  style: expandHintStyle,
                ),
                const SizedBox(width: 6),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRunStatCardShell extends CardBase {
  const _UserRunStatCardShell({
    required this.child,
    required this.onTapCallback,
  });

  final Widget child;
  final VoidCallback onTapCallback;

  @override
  VoidCallback? onTap(BuildContext context) => onTapCallback;

  @override
  Widget buildContent(BuildContext context) => child;
}

double _calcAvgSpeed(int meters, int minutes) {
  if (meters <= 0 || minutes <= 0) return 0;
  final hours = minutes / 60.0;
  return (meters / 1000.0) / hours;
}
