import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:flutter/material.dart';

import 'card_base.dart';

abstract class CollapsibleCardBase extends CardBase {
  CollapsibleCardBase({super.key, this.initialExpanded = false})
      : _expanded = ValueNotifier<bool>(initialExpanded);

  final bool initialExpanded;
  final ValueNotifier<bool> _expanded;

  String get kickerText;
  Color? get kickerColor => null;
  Duration get toggleDuration => const Duration(milliseconds: 220);

  Widget buildExpandedContent(BuildContext context);

  @override
  VoidCallback? onTap(BuildContext context) => () {
        _expanded.value = !_expanded.value;
      };

  @override
  Widget buildContent(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _expanded,
      builder: (context, expanded, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Kicker(kickerText, color: kickerColor),
                const Spacer(),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0.0,
                  duration: toggleDuration,
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.expand_more,
                    size: 18,
                    color: (kickerColor ??
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55))
                        .withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: toggleDuration,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: expanded ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: buildExpandedContent(context),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
