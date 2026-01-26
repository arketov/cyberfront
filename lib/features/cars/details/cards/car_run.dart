// lib/features/cars/details/cards/car_run.dart
import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/network/api_exception.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/features/cars/data/car_run_api.dart';
import 'package:cyberdriver/shared/formatters/run_stats_format.dart';
import 'package:cyberdriver/shared/models/user_car_run_dto.dart';
import 'package:flutter/material.dart';

class CarRunCard extends StatefulWidget {
  const CarRunCard({super.key, required this.carId});

  final int carId;

  @override
  State<CarRunCard> createState() => _CarRunCardState();
}

class _CarRunCardState extends State<CarRunCard> {
  late final CarRunApi _api;
  AuthService? _auth;
  Future<UserCarRunDto>? _future;
  bool _authReady = false;

  @override
  void initState() {
    super.initState();
    _api = CarRunApi(createApiClient(AppConfig.dev));
    _initAuth();
  }

  Future<void> _initAuth() async {
    final auth = await AuthService.getInstance();
    await auth.loadSession();
    if (!mounted) return;
    final userId = auth.session?.user.id ?? 0;
    setState(() {
      _auth = auth;
      _authReady = true;
      if (userId > 0) {
        _future = _api.getCarRunWithAuth(auth, userId, widget.carId);
      }
    });
  }

  void _retry() {
    final auth = _auth;
    final userId = auth?.session?.user.id ?? 0;
    if (auth == null || userId <= 0) return;
    setState(() {
      _future = _api.getCarRunWithAuth(auth, userId, widget.carId);
    });
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

    return _RunCardShell(
      future: _future,
      onRetry: _retry,
      formatDistance: (meters) => RunStatsFormat.distanceKmValue(meters),
      formatMinutes: (minutes) => minutes.toString(),
    );
  }
}

class _RunCardShell extends CardBase {
  const _RunCardShell({
    required this.future,
    required this.onRetry,
    required this.formatDistance,
    required this.formatMinutes,
  });

  final Future<UserCarRunDto>? future;
  final VoidCallback onRetry;
  final String Function(int meters) formatDistance;
  final String Function(int minutes) formatMinutes;

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (future == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<UserCarRunDto>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 86,
            child: Center(child: CyberDotsLoader(width: 120, height: 44)),
          );
        }

        if (snap.hasError) {
          final error = snap.error;
          if (error is ApiException && error.statusCode == 404) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Kicker('[ЭТО ТВОЙ ПРОБЕГ]', color: Colors.white70),
                SizedBox(height: 12),
                _RunStatsPlain(distanceText: '-', minutesText: '-'),
              ],
            );
          }
          return SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Kicker('[ЭТО ТВОЙ ПРОБЕГ]', color: Colors.white70),
                const SizedBox(height: 10),
                Text(
                  'Не удалось загрузить пробег',
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.75),
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

        final run = snap.data;
        if (run == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Kicker('[ЭТО ТВОЙ ПРОБЕГ]', color: Colors.white70),
            const SizedBox(height: 12),
            _RunStatsPlain(
              distanceText: formatDistance(run.meters),
              minutesText: formatMinutes(run.minutes),
            ),
          ],
        );
      },
    );
  }
}

class _RunStatsPlain extends StatelessWidget {
  const _RunStatsPlain({
    required this.distanceText,
    required this.minutesText,
  });

  final String distanceText;
  final String minutesText;

  @override
  Widget build(BuildContext context) {
    final statLabelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.7,
      color: Colors.white.withValues(alpha: 0.55),
    );
    final statValueStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
      color: Colors.white.withValues(alpha: 0.92),
    );
    final unitStyle = statValueStyle?.copyWith(
      color: Colors.white.withValues(alpha: 0.72),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 110,
              child: Text('ДИСТАНЦИЯ', style: statLabelStyle),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: distanceText, style: statValueStyle),
                    TextSpan(text: ' ', style: statValueStyle),
                    TextSpan(text: 'км', style: unitStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 110,
              child: Text('ВРЕМЯ', style: statLabelStyle),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: minutesText, style: statValueStyle),
                    TextSpan(text: ' ', style: statValueStyle),
                    TextSpan(text: 'мин', style: unitStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
