// lib/features/profile/cards/profile_sessions_card.dart
import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/ui/widgets/stat_donut.dart';
import 'package:cyberdriver/core/utils/date_time_service.dart';
import 'package:cyberdriver/features/profile/data/session_api.dart';
import 'package:cyberdriver/shared/formatters/run_stats_format.dart';
import 'package:cyberdriver/shared/models/session_dto.dart';
import 'package:flutter/material.dart';

class ProfileSessionsCard extends CardBase {
  const ProfileSessionsCard({super.key});

  @override
  Widget buildContent(BuildContext context) => const _ProfileSessionsContent();
}

class _ProfileSessionsContent extends StatefulWidget {
  const _ProfileSessionsContent();

  @override
  State<_ProfileSessionsContent> createState() => _ProfileSessionsContentState();
}

class _ProfileSessionsContentState extends State<_ProfileSessionsContent> {
  static const int _step = 5;
  int _visibleCount = 1;

  late final SessionApi _api;
  AuthService? _auth;
  bool _authReady = false;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  int _maxPage = 1;
  final List<SessionDto> _items = [];

  @override
  void initState() {
    super.initState();
    _api = SessionApi(createApiClient(AppConfig.dev));
    _initAuth();
  }

  Future<void> _initAuth() async {
    final auth = await AuthService.getInstance();
    await auth.loadSession();
    if (!mounted) return;
    setState(() {
      _auth = auth;
      _authReady = true;
    });
    _loadNextPage();
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    final needMoreData = _visibleCount + _step > _items.length;
    if (needMoreData && _currentPage < _maxPage) {
      _loadNextPage(loadMore: true);
      return;
    }
    final next = (_visibleCount + _step).clamp(1, _items.length);
    if (next == _visibleCount) return;
    setState(() => _visibleCount = next);
  }

  Future<void> _loadNextPage({bool loadMore = false}) async {
    if (_isLoadingInitial || _isLoadingMore) return;
    if (_currentPage >= _maxPage && _currentPage != 0) return;

    final auth = _auth;
    if (auth == null || auth.session == null) return;

    setState(() {
      _error = null;
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoadingInitial = true;
      }
    });

    final nextPage = _currentPage == 0 ? 1 : _currentPage + 1;
    try {
      final res = await _api.getSessionsWithAuth(auth, page: nextPage);
      if (!mounted) return;
      setState(() {
        _currentPage = res.currentPage;
        _maxPage = res.maxPage;
        _items.addAll(res.data);
        if (_visibleCount < 1 && _items.isNotEmpty) {
          _visibleCount = 1;
        }
        if (loadMore) {
          _visibleCount = (_visibleCount + _step).clamp(1, _items.length);
        }
        _isLoadingInitial = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Ошибка загрузки сессий: $e';
        _isLoadingInitial = false;
        _isLoadingMore = false;
      });
    }
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

    if (_isLoadingInitial && _items.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CyberDotsLoader(width: 120, height: 44)),
      );
    }

    if (_error != null && _items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Kicker('[ПОСЛЕДНЯ СЕССИЯ]', color: Colors.white70),
          const SizedBox(height: 10),
          Text(
            _error!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.redAccent),
          ),
        ],
      );
    }

    final sessions = _items.take(_visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('[ПОСЛЕДНЯ СЕССИЯ]', color: Colors.white70),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          Text(
            'Сессий пока нет',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.6)),
          )
        else
          for (var i = 0; i < sessions.length; i++) ...[
            _SessionItem(session: sessions[i]),
            if (i != sessions.length - 1) const SizedBox(height: 10),
          ],
        const SizedBox(height: 12),
        _LoadMoreButton(onTap: _loadMore),
        if (_isLoadingMore) ...[
          const SizedBox(height: 12),
          const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ],
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: Colors.white.withValues(alpha: 0.55),
    );

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.expand_more,
                size: 18,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text('Загрузить ещё', style: style),
              const SizedBox(width: 6),
              Icon(
                Icons.expand_more,
                size: 18,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  const _SessionItem({required this.session});

  final SessionDto session;

  String _formatDuration(int minutes) {
    final h = RunStatsFormat.durationHours(minutes);
    final m = RunStatsFormat.durationMinutes(minutes);
    return '$hч $mм';
  }

  @override
  Widget build(BuildContext context) {
    final metaStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: Colors.white.withValues(alpha: 0.58),
    );
    final titleStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.2,
      color: Colors.white.withValues(alpha: 0.92),
    );
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: Colors.white.withValues(alpha: 0.6),
    );
    final valueStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
      color: Colors.white.withValues(alpha: 0.92),
    );

    final createdLocal = DateTimeService.toLocal(session.createdAt);
    final dateText = DateTimeService.formatDayMonth(createdLocal);
    final timeText = DateTimeService.formatTime(createdLocal);
    final distanceKm = RunStatsFormat.distanceKmValue(session.distanceMeters);
    final durationText = _formatDuration(session.durationMinutes);
    final speedText = session.averageSpeed.toStringAsFixed(1);

    final metaItems = <Widget>[
      if (dateText.isNotEmpty)
        _MetaItem(
          icon: Icons.calendar_today_rounded,
          label: dateText,
          style: metaStyle,
        ),
      if (timeText.isNotEmpty)
        _MetaItem(
          icon: Icons.schedule_rounded,
          label: timeText,
          style: metaStyle,
        ),
    ];

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(session.car?.name ?? '—', style: titleStyle),
        const SizedBox(height: 4),
        Text(
          session.track?.name ?? '—',
          style: titleStyle.copyWith(
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: metaItems,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _StatLine(
              label: 'ДИСТАНЦИЯ',
              value: '$distanceKm км',
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
            _StatLine(
              label: 'ВРЕМЯ',
              value: durationText,
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
            _StatLine(
              label: 'СРЕДНЯЯ',
              value: '$speedText км/ч',
              labelStyle: labelStyle,
              valueStyle: valueStyle,
            ),
          ],
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 560;
          final donut = StatDonut(
            label: 'АККУРАТНОСТЬ',
            value: session.carefuness,
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                details,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(width: 100, child: donut),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: details),
              const SizedBox(width: 12),
              SizedBox(width: 100, child: donut),
            ],
          );
        },
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.style,
  });

  final IconData icon;
  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: style.color),
        const SizedBox(width: 6),
        Text(label, style: style),
      ],
    );
  }
}
