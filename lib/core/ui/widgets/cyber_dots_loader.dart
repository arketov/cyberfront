// lib/core/ui/cyber_dots_loader.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// 3-точечный лоадер.
/// - width/height задают только контейнер (размер точки НЕ меняется)
/// - если висит дольше [showMessageAfter], показывается надпись снизу
/// - если задан [messageCyclePeriod], надпись меняется на случайную с этим периодом
class CyberDotsLoader extends StatefulWidget {
  const CyberDotsLoader({
    super.key,

    // container size (does NOT scale dots)
    this.width,
    this.height,

    // dots
    this.dotSize = 8,
    this.gap = 10,
    this.color,
    this.inactiveOpacity = 0.25,
    this.activeOpacity = 1.0,

    // animation
    this.period = const Duration(milliseconds: 1200),
    this.bounce = 4, // px up

    // message
    this.showMessageAfter = const Duration(seconds: 1),
    this.messageCyclePeriod = const Duration(seconds: 2), // null => static
    this.messages = _defaultMessages,
    this.messageStyle,
    this.messageMaxLines = 1,
    this.messageTextAlign = TextAlign.center,
    this.messageSpacing = 10,
    this.randomSeed,
  });

  final double? width;
  final double? height;

  final double dotSize;
  final double gap;
  final Color? color;
  final double inactiveOpacity;
  final double activeOpacity;

  final Duration period;
  final double bounce;

  final Duration showMessageAfter;

  /// Если null — сообщение будет статичным (один раз выбрано и всё).
  /// Если задано — будет меняться раз в этот период.
  final Duration? messageCyclePeriod;

  final List<String> messages;
  final TextStyle? messageStyle;
  final int messageMaxLines;
  final TextAlign messageTextAlign;
  final double messageSpacing;

  /// Чтобы рандом был воспроизводимым.
  final int? randomSeed;

  static const List<String> _defaultMessages = <String>[
    'Встречка!',
    'КиберСекунду…',
    'Проходим лисью нору..',
    'Тянем трассы…',
    'Опа чирик…',
    'Греем шины…',
    'Пит-стоп…',
  ];

  @override
  State<CyberDotsLoader> createState() => _CyberDotsLoaderState();
}

class _CyberDotsLoaderState extends State<CyberDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Random _rnd;

  Timer? _showTimer;
  Timer? _cycleTimer;

  bool _showMessage = false;
  String? _message;

  int _messagesHash = 0;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(vsync: this, duration: widget.period)..repeat();
    _rnd = Random(widget.randomSeed ?? DateTime.now().microsecondsSinceEpoch);
    _messagesHash = Object.hashAll(widget.messages);

    // Таймер запускаем ПОСЛЕ первого кадра, чтобы "1 секунда" была честной визуально.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _armShowTimer();
    });
  }

  @override
  void didUpdateWidget(covariant CyberDotsLoader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.period != widget.period) {
      _c
        ..duration = widget.period
        ..repeat();
    }

    final newHash = Object.hashAll(widget.messages);
    final messagesChanged = newHash != _messagesHash;
    final delayChanged = oldWidget.showMessageAfter != widget.showMessageAfter;
    final cycleChanged =
        oldWidget.messageCyclePeriod != widget.messageCyclePeriod;

    if (messagesChanged) {
      _messagesHash = newHash;
      if (widget.messages.isEmpty) {
        // Нет сообщений — убираем подпись и останавливаем цикл
        _showMessage = false;
        _message = null;
        _cycleTimer?.cancel();
      } else {
        // Сообщения поменялись — если подпись уже показана и цикл включён, просто продолжим
        // (можно сразу дернуть новое сообщение, но без "дерганья" оставим текущее).
      }
    }

    // Если подпись ещё не показана и изменились параметры показа — перезапускаем show-таймер.
    if (!_showMessage && (delayChanged || messagesChanged)) {
      _showTimer?.cancel();
      _cycleTimer?.cancel();

      if (widget.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _armShowTimer();
        });
      }
    }

    // Если подпись уже показана и поменяли режим cycling — пересобираем cycle-таймер.
    if (_showMessage && cycleChanged) {
      _cycleTimer?.cancel();
      _armCycleTimer();
    }
  }

  void _armShowTimer() {
    if (widget.messages.isEmpty) return;

    _showTimer?.cancel();

    if (widget.showMessageAfter <= Duration.zero) {
      _showNow();
      return;
    }

    _showTimer = Timer(widget.showMessageAfter, () {
      if (!mounted) return;
      _showNow();
    });
  }

  void _showNow() {
    if (_showMessage) return;
    if (widget.messages.isEmpty) return;

    setState(() {
      _message = _pickRandom(except: null);
      _showMessage = true;
    });

    _armCycleTimer();
  }

  void _armCycleTimer() {
    _cycleTimer?.cancel();

    final period = widget.messageCyclePeriod;
    if (!_showMessage) return;
    if (period == null) return; // статично
    if (period <= Duration.zero) return;
    if (widget.messages.length <= 1) return; // нечего крутить

    _cycleTimer = Timer.periodic(period, (_) {
      if (!mounted) return;
      if (widget.messages.isEmpty) return;

      final next = _pickRandom(except: _message);
      setState(() => _message = next);
    });
  }

  String _pickRandom({String? except}) {
    final msgs = widget.messages;
    if (msgs.isEmpty) return '';

    if (except == null || msgs.length == 1) {
      return msgs[_rnd.nextInt(msgs.length)];
    }

    // Пытаемся избежать повторов.
    for (var i = 0; i < 4; i++) {
      final candidate = msgs[_rnd.nextInt(msgs.length)];
      if (candidate != except) return candidate;
    }
    // Если "не повезло" — вернем что есть.
    return msgs[_rnd.nextInt(msgs.length)];
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _cycleTimer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.color ?? Theme.of(context).colorScheme.primary;

    final msgStyle = widget.messageStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.65),
          letterSpacing: 0.2,
        );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10,),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final available = constraints.hasBoundedWidth
                        ? constraints.maxWidth
                        : double.infinity;

                    // Подгоняем gap, чтобы влезло, НЕ меняя dotSize.
                    final neededForDots = widget.dotSize * 3;
                    final maxGap = (available.isFinite)
                        ? ((available - neededForDots) / 2)
                        .clamp(0.0, widget.gap)
                        : widget.gap;

                    final gap = maxGap;

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Dot(
                          t: _c.value,
                          index: 0,
                          size: widget.dotSize,
                          gapRight: gap,
                          color: dotColor,
                          inactiveOpacity: widget.inactiveOpacity,
                          activeOpacity: widget.activeOpacity,
                          bounce: widget.bounce,
                        ),
                        _Dot(
                          t: _c.value,
                          index: 1,
                          size: widget.dotSize,
                          gapRight: gap,
                          color: dotColor,
                          inactiveOpacity: widget.inactiveOpacity,
                          activeOpacity: widget.activeOpacity,
                          bounce: widget.bounce,
                        ),
                        _Dot(
                          t: _c.value,
                          index: 2,
                          size: widget.dotSize,
                          gapRight: 0,
                          color: dotColor,
                          inactiveOpacity: widget.inactiveOpacity,
                          activeOpacity: widget.activeOpacity,
                          bounce: widget.bounce,
                        ),
                      ],
                    );
                  },
                ),
                if (_showMessage && _message != null) ...[
                  SizedBox(height: widget.messageSpacing),
                  Text(
                    _message!,
                    style: msgStyle,
                    maxLines: widget.messageMaxLines,
                    overflow: TextOverflow.ellipsis,
                    textAlign: widget.messageTextAlign,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.t,
    required this.index,
    required this.size,
    required this.gapRight,
    required this.color,
    required this.inactiveOpacity,
    required this.activeOpacity,
    required this.bounce,
  });

  final double t;
  final int index;
  final double size;
  final double gapRight;
  final Color color;
  final double inactiveOpacity;
  final double activeOpacity;
  final double bounce;

  @override
  Widget build(BuildContext context) {
    final phase = (t + index * 0.18) % 1.0;
    final pulse = (1.0 - (phase - 0.5).abs() * 2.0).clamp(0.0, 1.0);

    final opacity = inactiveOpacity + (activeOpacity - inactiveOpacity) * pulse;
    final dy = -bounce * pulse;

    return Padding(
      padding: EdgeInsets.only(right: gapRight),
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
