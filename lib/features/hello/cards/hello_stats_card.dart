//lib/features/hello/cards/hello_stats_card.dart
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/features/hello/data/hello_stats_api.dart';
import 'package:cyberdriver/shared/models/cyber_stats_dto.dart';
import 'package:flutter/material.dart';
import '../../../core/ui/cards/card_base.dart';

class HelloStatsCard extends CardBase {
  const HelloStatsCard({super.key});

  @override
  bool get backgroundGradientEnabled => false;

  @override
  Color? backgroundColor(BuildContext context) => const Color(0xFFA9A9A9);

  @override
  Widget buildContent(BuildContext context) => const _HelloStatsCardContent();
}

class _HelloStatsCardContent extends StatefulWidget {
  const _HelloStatsCardContent();

  @override
  State<_HelloStatsCardContent> createState() => _HelloStatsCardContentState();
}

class _HelloStatsCardContentState extends State<_HelloStatsCardContent>
    with AutomaticKeepAliveClientMixin<_HelloStatsCardContent> {
  late final HelloStatsApi _api;
  late Future<CyberStatsDto> _future;

  @override
  void initState() {
    super.initState();
    _api = HelloStatsApi(createApiClient(AppConfig.dev));
    _future = _api.getCyberStats();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget stat(String value, String label) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<CyberStatsDto>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 52,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snap.hasError) {
          return Text(
            'Ошибка загрузки: ${snap.error}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black54),
          );
        }

        final stats = snap.data;
        if (stats == null) {
          return Text(
            'Нет данных',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black54),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Kicker('[СТАТИСТИКА]', color: Colors.black54),
            const SizedBox(height: 12),
            Row(
              children: [
                stat('4', 'КОКПИТА'),
                const SizedBox(width: 7),
                stat('${stats.tracksTotal}', 'ТРАСС'),
                const SizedBox(width: 7),
                stat('${stats.carsTotal}', 'АВТО'),
                const SizedBox(width: 7),
                stat('${stats.activeUsers}', 'ЮЗЕРОВ'),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
