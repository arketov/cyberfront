import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:flutter/material.dart';

class UserRunStat extends StatefulWidget {
  const UserRunStat({super.key});

  @override
  State<UserRunStat> createState() => _UserRunStatState();
}

class _UserRunStatState extends State<UserRunStat> {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
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

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Kicker('[ЭТО АГРЕГАЦИЯ]', color: Colors.white70),
          const Row(
            children: [
              Text('БЛОК А'),
              Column(children: [
                Text('МИНИ КАРТОЧКА МАШИНЫ'),
                Text('МИНИ КАРТОЧКА ТРЕКА')
              ]),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            const Text('expanded placeholder'),
          ],
          SizedBox(height: _expanded ? 12 : 4),
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
