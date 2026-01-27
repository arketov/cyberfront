import 'dart:async';

import 'package:flutter/material.dart';

import 'kicker.dart';

enum NotificationTone { neutral, negative }

final class AppNotifications {
  AppNotifications._();

  static final AppNotificationController _controller =
      AppNotificationController.instance;

  static AppNotificationController get controller => _controller;

  static void show(
    String message, {
    NotificationTone tone = NotificationTone.neutral,
    Duration duration = const Duration(seconds: 3),
  }) {
    _controller.show(message: message, tone: tone, duration: duration);
  }

  static void error(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(message, tone: NotificationTone.negative, duration: duration);
  }
}

final class AppNotificationController extends ChangeNotifier {
  AppNotificationController._();

  static final AppNotificationController instance =
      AppNotificationController._();

  final List<AppNotificationItem> _items = [];
  int _nextId = 0;

  List<AppNotificationItem> get items => List.unmodifiable(_items);

  void show({
    required String message,
    NotificationTone tone = NotificationTone.neutral,
    Duration duration = const Duration(seconds: 3),
  }) {
    final text = message.trim();
    if (text.isEmpty) return;

    final item = AppNotificationItem(
      id: _nextId++,
      message: text,
      tone: tone,
      visible: true,
    );
    _items.insert(0, item);
    notifyListeners();

    Timer(duration, () => dismiss(item.id));
  }

  void dismiss(int id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final item = _items[index];
    if (!item.visible) return;

    item.visible = false;
    notifyListeners();

    Timer(_exitDuration, () {
      _items.removeWhere((e) => e.id == id);
      notifyListeners();
    });
  }
}

class AppNotificationHost extends StatelessWidget {
  const AppNotificationHost({
    super.key,
    required this.controller,
  });

  final AppNotificationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.items;
        if (items.isEmpty) return const SizedBox.shrink();

        return IgnorePointer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in items) ...[
                _NotificationToast(item: item),
                if (item != items.last) const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class AppNotificationItem {
  AppNotificationItem({
    required this.id,
    required this.message,
    required this.tone,
    required this.visible,
  });

  final int id;
  final String message;
  final NotificationTone tone;
  bool visible;
}

const Duration _enterDuration = Duration(milliseconds: 220);
const Duration _exitDuration = Duration(milliseconds: 180);

class _NotificationToast extends StatelessWidget {
  const _NotificationToast({required this.item});

  final AppNotificationItem item;

  @override
  Widget build(BuildContext context) {
    final isNegative = item.tone == NotificationTone.negative;
    const accent = Color(0xFF0000FF);
    final stripeColor = isNegative
        ? const Color(0xFFFF5A5A)
        : Colors.white.withValues(alpha: 0.65);

    final container = Container(
      constraints: const BoxConstraints(minHeight: 44, maxWidth: 560),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: stripeColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Kicker('[ЭТО УВЕДОМЛЕНИЕ]'),
                const SizedBox(height: 6),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return AnimatedSlide(
      offset: item.visible ? const Offset(0, 0) : const Offset(0, -0.2),
      duration: item.visible ? _enterDuration : _exitDuration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: item.visible ? 1.0 : 0.0,
        duration: item.visible ? _enterDuration : _exitDuration,
        curve: Curves.easeOutCubic,
        child: container,
      ),
    );
  }
}
