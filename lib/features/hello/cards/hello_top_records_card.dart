//lib/features/hello/cards/hello_top_records_card.dart
import 'package:flutter/material.dart';
import 'hello_card_base.dart';
import 'hello_kicker.dart';

class HelloTopRecordsCard extends HelloCardBase {
  const HelloTopRecordsCard({super.key});

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HelloKicker('[ТОП РЕКОРДЫ]', color: cs.onSurface.withOpacity(.55)),
        const SizedBox(height: 10),
        Text(
          'ГРУППОВЫЕ РЕКОРДЫ',
          style: TextStyle(
            height: .92,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 12),
        _Row(
          index: 1,
          name: 'Денис',
          car: 'Porsche 911 · Nürburgring',
          time: '5:13',
        ),
        const SizedBox(height: 10),
        _Row(index: 2, name: 'Иван', car: 'Nissan GT-R · Azure', time: '5:51'),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.index,
    required this.name,
    required this.car,
    required this.time,
  });

  final int index;
  final String name;
  final String car;
  final String time;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

    // База серого под твою тему (не чистый grey)
    final base = mix(cs.surface, cs.onSurface, 0.10).withOpacity(0.55);

    return LayoutBuilder(
      builder: (context, c) {
        // фиксируем "крутизну" диагонали: чем шире/ниже — тем больше k
        final h = (c.maxHeight.isFinite && c.maxHeight > 0) ? c.maxHeight : 56.0;
        final w = c.maxWidth.isFinite ? c.maxWidth : 320.0;
        final k = (w / h).clamp(4.0, 10.0); // 4..10 обычно идеально

        return Container(
          constraints: const BoxConstraints(minHeight: 56),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),

            // БАЗА (не серая в лоб, а "тёмное стекло")
            color: cs.surface.withOpacity(0.10),

            // Чуть "подняли" над фоном
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
              // микро-блик сверху, чтобы не было плоско
              BoxShadow(
                color: Colors.white.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, -1),
              ),
            ],
          ),

          // ПОВЕРХ: диагональный блик + тонкая рамка
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
            gradient: LinearGradient(
              // вот это и даёт "из угла в угол" визуально даже на низкой плашке
              begin: const Alignment(-1, -8),
              end: const Alignment(1, 8),
              colors: [
                Colors.white.withOpacity(0.12), // верхний левый блик
                Colors.white.withOpacity(0.03), // середина
                Colors.black.withOpacity(0.18), // нижний правый “притемнитель”
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        car,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withOpacity(.55),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(time,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface.withOpacity(.85),
                    )),
              ],
            ),
          ),
        );
      },
    );

  }
}
