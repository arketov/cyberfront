//lib/features/hello/cards/hello_about_card.dart
import 'package:flutter/material.dart';
import 'hello_card_base.dart';
import 'hello_kicker.dart';

class HelloAboutCard extends HelloCardBase {
  const HelloAboutCard({super.key});

  @override
  Color? backgroundColor(BuildContext context) => const Color(0xFFA9A9A9);

  @override
  bool get backgroundGradientEnabled => false;

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HelloKicker('[ЧТО ЭТО ТАКОЕ]', color: Colors.black54,),
        const SizedBox(height: 10),
        Text(
          'ЭТО ВЕСЁЛЫЕ\nГОНКИ\nС ПАРНЯМИ',
          style: TextStyle(
            height: .96,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        const _ExpandableAboutText(
          text:'Симрейсинг (simracing или sim-racing) – словосочетание, говорящее само за себя, и означает гонки на симуляторах. Стоит отметить, что под словом симуляторы подразумеваются компьютерные игры, созданные с упором на максимальную реалистичность поведения автомобиля на трассе, что достигается за счёт детального моделирования физической модели по правилам ньютоновской механики. В симуляторах моделируется механика подвески, деформация и температура покрышек, деформация рычагов подвески, распределение массы машины и инерция по всем осям. Со всем этим игроку приходится иметь дело при управлении той или иной модели автомобиля, учитывать расход топлива, следить за износом шин,сцеплением с поверхностью дороги и т. п',

        ),
      ],
    );
  }
}


class _ExpandableAboutText extends StatefulWidget {
  const _ExpandableAboutText({
    required this.text,
    this.collapsedLines = 6,
  });

  final String text;
  final int collapsedLines;

  @override
  State<_ExpandableAboutText> createState() => _ExpandableAboutTextState();
}

class _ExpandableAboutTextState extends State<_ExpandableAboutText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      height: 1.25,
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 180),
        crossFadeState:
        _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        firstChild: Text(
          widget.text,
          style: style,
          maxLines: widget.collapsedLines,
          overflow: TextOverflow.ellipsis,
        ),
        secondChild: Text(
          widget.text,
          style: style,
        ),
      ),
    );
  }
}