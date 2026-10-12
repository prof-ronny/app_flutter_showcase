import 'dart:math' as math;
import 'package:flutter/material.dart';

Duration motionDuration(BuildContext context, [int milliseconds = 550]) =>
    MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : Duration(milliseconds: milliseconds);

class Enter extends StatelessWidget {
  final Widget child;
  const Enter({super.key, required this.child});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: motionDuration(context, 700),
        curve: Curves.easeOutCubic,
        child: child,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 24 * (1 - value)), child: child),
        ),
      );
}

class GradientCard extends StatelessWidget {
  final int index;
  final bool back;
  const GradientCard({super.key, required this.index, this.back = false});
  static const titles = ['NEBULA', 'AURORA', 'ORBIT'];
  static const colors = [
    [Color(0xFF7562EF), Color(0xFFDB78D5)],
    [Color(0xFF087D91), Color(0xFF64DFC2)],
    [Color(0xFFB44866), Color(0xFFF3B066)],
  ];
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors[index],
          )),
          child: Stack(children: [
            Positioned(right: -35, top: -35, child: _ring(170)),
            Positioned(left: -60, bottom: -100, child: _ring(260)),
            Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.blur_on, color: Colors.white, size: 30),
                      const Spacer(),
                      Text(back ? 'VERSO' : 'MOTION / 0${index + 1}',
                          style: const TextStyle(
                              color: Colors.white,
                              letterSpacing: 2,
                              fontSize: 11)),
                    ]),
                    Flexible(
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                                back ? 'Flutter em movimento' : titles[index],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: back ? 25 : 34,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: back ? 0 : 4)))),
                    Text(
                        back
                            ? 'Perspectiva • rotação • profundidade'
                            : 'Uma interface. Muitas possibilidades.',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                )),
          ]),
        ),
      );
  Widget _ring(double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(.18), width: 28)));
}

class FlipCard extends StatefulWidget {
  const FlipCard({super.key});
  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> {
  bool flipped = false;
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Virar cartão. ${flipped ? "Verso" : "Frente"}',
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => setState(() => flipped = !flipped),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: flipped ? math.pi : 0),
            duration: motionDuration(context, 750),
            curve: Curves.easeInOutCubic,
            builder: (context, angle, child) {
              final back = angle > math.pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, .0015)
                  ..rotateY(angle),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(back ? math.pi : 0),
                  child: AspectRatio(
                      aspectRatio: 1.65,
                      child: GradientCard(index: 0, back: back)),
                ),
              );
            },
          ),
        ),
      );
}
