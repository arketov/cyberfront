// lib/features/hello/cards/hello_hero_card.dart
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/generated/assets.dart';
import 'package:flutter/material.dart';

import '../../../core/ui/cards/card_base.dart';


class HelloHeroCard extends CardBase {
  const HelloHeroCard({super.key});

  // В hero мы сами делаем внутренние отступы, поэтому базовые отключаем,
  // иначе будет двойной padding.
  @override
  EdgeInsetsGeometry get padding => EdgeInsets.zero;

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final secondaryBtnStyle = OutlinedButton.styleFrom(
      backgroundColor: Colors.black.withValues(alpha: .33),
      // затемнение/прозрачность
      foregroundColor: Colors.white.withValues(alpha: .88),
      side: BorderSide(color: Colors.grey.withValues(alpha: .25)),
      overlayColor: Colors.white.withValues(alpha: .06),
      // эффект нажатия/ховера
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    );

    const contentPadding = EdgeInsets.fromLTRB(18, 14, 18, 16);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 260),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Assets.cardsHelloAbout,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: .99),
                    Colors.black.withValues(alpha: .50),
                    Colors.black.withValues(alpha: .20),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: contentPadding,
            child: LayoutBuilder(
              builder: (context, c) {
                final isNarrow = c.maxWidth < 520;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Kicker('[ЧТО ЭТО]'),
                    const SizedBox(height: 8),
                    Text(
                      'ГОТОВЫ\nПОГОНЯТЬ?',
                      style: TextStyle(
                        height: .92,
                        fontSize: isNarrow ? 40 : 54,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isNarrow ? 520 : 620,
                      ),
                      child: Text(
                        'ЕДИНСТВЕННЫЙ В ГОРОДЕ ВИРТУАЛЬНЫЙ АВТОДРОМ В ЦЕНТРЕ ПЕРМИ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .78),
                          height: 1.25,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ВАЖНО: именно этот блок раньше центрировал кнопку,
                    // потому что у внутреннего Column crossAxisAlignment был по умолчанию center.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            child: const Text('ЗАПИСАТЬСЯ'),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.start,
                            children: [
                              OutlinedButton(
                                onPressed: () {},
                                style: secondaryBtnStyle,
                                child: const Text('ОТКРЫТЬ РЕКОРДЫ'),
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                style: secondaryBtnStyle,
                                child: const Text('ТРАССЫ'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
