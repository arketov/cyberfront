import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:flutter/material.dart';

import 'card_base.dart';

abstract class CollapsibleCardBase extends StatefulWidget {
  const CollapsibleCardBase({super.key, this.initialExpanded = false});

  final bool initialExpanded;

  String get kickerText;
  Color? get kickerColor => null;
  Duration get toggleDuration => const Duration(milliseconds: 220);

  Widget buildExpandedContent(BuildContext context, bool expanded);

  @override
  State<CollapsibleCardBase> createState() => _CollapsibleCardBaseState();
}

class _CollapsibleCardBaseState extends State<CollapsibleCardBase> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final kickerColor = widget.kickerColor;
    final toggleDuration = widget.toggleDuration;
    final iconColor = (kickerColor ??
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55))
        .withValues(alpha: 0.9);

    return _CollapsibleCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Row(
              children: [
                Kicker(widget.kickerText, color: kickerColor),
                const Spacer(),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: toggleDuration,
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.expand_more,
                    size: 18,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: toggleDuration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _expanded ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: widget.buildExpandedContent(context, _expanded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsibleCardShell extends CardBase {
  const _CollapsibleCardShell({required this.child});

  final Widget child;

  @override
  Widget buildContent(BuildContext context) => child;
}
