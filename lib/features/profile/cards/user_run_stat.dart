import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/core/ui/widgets/gradient_progress_bar.dart';
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
  late final UserRunStatsApi _api;
  late Future<UserRunStatsDto> _future;

  @override
  void initState() {
    super.initState();
    _api = UserRunStatsApi(createApiClient(AppConfig.dev));
    _future = _loadStats();
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  Future<UserRunStatsDto> _loadStats() async {
    final auth = await AuthService.getInstance();
    await auth.loadSession();
    return _api.getRunStatsWithAuth(auth);
  }

  void _retry() {
    setState(() => _future = _loadStats());
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
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<UserRunStatsDto>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CyberDotsLoader(width: 120, height: 44)),
          );
        }

        if (snap.hasError) {
          return SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Не удалось загрузить статистику',
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: .75),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _retry, child: const Text('Повторить')),
                ],
              ),
            ),
          );
        }

        final stats = snap.data;
        if (stats == null) {
          return SizedBox(
            width: double.infinity,
            child: Text(
              'Нет данных',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: .65),
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        final totalMeters = stats.totalMeters;
        final totalMinutes = stats.totalMinutes;
        final avgSpeedKmh = _calcAvgSpeed(totalMeters, totalMinutes);
        final favoriteCar = stats.favoriteCar;
        final favoriteTrack = stats.favoriteTrack;

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
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 10, 12, 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Охват'),
                          SizedBox(height: 10),
                          Row(
                            children: const [
                              Text('Машины',),
                              SizedBox(width: 8),
                              Expanded(child: GradientProgressBar(value: 50)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: const [
                              Text('Трассы'),
                              SizedBox(width: 8),
                              Expanded(child: GradientProgressBar(value: 50)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 10, 12, 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Cредние'),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text('На машине'),
                              Text('300 км • 1 час 20 минут'),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text('На трассе'),
                              Text('300 км • 1 час 20 минут'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
      },
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
