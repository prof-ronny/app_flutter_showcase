import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/motion.dart';

class SceneScreen extends StatefulWidget {
  const SceneScreen({super.key});
  @override
  State<SceneScreen> createState() => _SceneScreenState();
}
class _SceneScreenState extends State<SceneScreen> with SingleTickerProviderStateMixin {
  late final AnimationController clock;
  double rotationX = -.35, rotationY = .5, speed = 1;
  bool paused = false, particles = true;
  bool reduced = false;
  @override
  void initState() {
    super.initState();
    clock = AnimationController(vsync: this, duration: const Duration(seconds: 16));
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = MediaQuery.of(context).disableAnimations;
    syncClock();
  }
  void syncClock() {
    if (paused || reduced) {
      clock.stop();
    } else {
      clock.repeat(period: Duration(milliseconds: (16000 / speed).round()));
    }
  }
  @override
  void dispose() { clock.dispose(); super.dispose(); }

  void controls() => showModalBottomSheet<void>(
    context: context, showDragHandle: true, isScrollControlled: true,
    builder: (context) => StatefulBuilder(builder: (context, updateSheet) => SafeArea(
      child: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Controle a experiência', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Velocidade: ${speed.toStringAsFixed(1)}×'),
            Slider(value: speed, min: .3, max: 2, divisions: 17,
              label: '${speed.toStringAsFixed(1)}×', onChanged: (value) {
                setState(() { speed = value; syncClock(); });
                updateSheet(() {});
              }),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Mostrar partículas'),
              value: particles, onChanged: (value) {
                setState(() => particles = value); updateSheet(() {});
              }),
            const Text('Arraste o cubo para mudar sua orientação. '
              'A velocidade controla a rotação automática e as partículas.'),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () => Navigator.pop(context), child: const Text('Pronto'))),
          ]),
      )),
    )),
  );

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(24), children: [
    const Text('Uma cena viva.', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    const Text('Arraste para girar. Pause para examinar a profundidade.'),
    const SizedBox(height: 24),
    Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620),
      child: AspectRatio(aspectRatio: 1.12, child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: ColoredBox(color: const Color(0xFF15162C), child: GestureDetector(
          onPanUpdate: (details) => setState(() {
            rotationY += details.delta.dx * .012;
            rotationX -= details.delta.dy * .012;
          }),
          child: Semantics(label: 'Cubo com perspectiva. Arraste para girar.',
            child: AnimatedBuilder(animation: clock, builder: (context, child) => CustomPaint(
              painter: ScenePainter(phase: clock.value, x: rotationX,
                y: rotationY, particles: particles), child: const SizedBox.expand())),
          ),
        )),
      )),
    )),
    const SizedBox(height: 24),
    Wrap(spacing: 12, runSpacing: 12, children: [
      FilledButton.icon(onPressed: reduced ? null : () => setState(() {
        paused = !paused; syncClock();
      }), icon: Icon(paused ? Icons.play_arrow : Icons.pause),
        label: Text(reduced ? 'Movimento reduzido' : paused ? 'Continuar' : 'Pausar')),
      OutlinedButton.icon(onPressed: controls, icon: const Icon(Icons.tune),
        label: const Text('Abrir painel')),
      IconButton(tooltip: 'Restaurar orientação', onPressed: () => setState(() {
        rotationX = -.35; rotationY = .5;
      }), icon: const Icon(Icons.restart_alt)),
    ]),
    const SizedBox(height: 24),
    const Card(child: Padding(padding: EdgeInsets.all(20), child: Text(
      'CustomPainter desenha as partículas e as faces do cubo. As coordenadas '
      'são rotacionadas, projetadas em perspectiva e desenhadas do fundo para a frente.'))),
  ]);
}

class ScenePainter extends CustomPainter {
  final double phase, x, y;
  final bool particles;
  ScenePainter({required this.phase, required this.x, required this.y, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final extent = size.shortestSide;
    final glow = Paint()..shader = const RadialGradient(colors: [
      Color(0x556956E8), Color(0x0015162C),
    ]).createShader(Rect.fromCircle(center: center, radius: extent * .55));
    canvas.drawRect(Offset.zero & size, glow);
    if (particles) {
      for (var i = 0; i < 42; i++) {
        final seed = i * 2.399;
        final angle = seed + phase * math.pi * 2;
        final radius = extent * (.26 + (i % 7) * .03);
        final position = center + Offset(math.cos(angle) * radius,
          math.sin(angle) * radius * .8);
        canvas.drawCircle(position, 1.3 + (i % 3), Paint()
          ..color = const Color(0xFFAA94FF).withOpacity(.15 + (i % 5) * .12));
      }
    }
    canvas.drawOval(Rect.fromCenter(center: center + Offset(0, extent * .29),
      width: extent * .49, height: extent * .065),
      Paint()..color = Colors.black.withOpacity(.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    final ax = x + math.sin(phase * math.pi * 2) * .16;
    final ay = y + phase * math.pi * 2;
    final vertices = <List<double>>[];
    for (final original in const [
      [-1.0,-1.0,-1.0], [1.0,-1.0,-1.0], [1.0,1.0,-1.0], [-1.0,1.0,-1.0],
      [-1.0,-1.0,1.0], [1.0,-1.0,1.0], [1.0,1.0,1.0], [-1.0,1.0,1.0],
    ]) {
      final rx = original[0] * math.cos(ay) + original[2] * math.sin(ay);
      final rz = -original[0] * math.sin(ay) + original[2] * math.cos(ay);
      final ry = original[1] * math.cos(ax) - rz * math.sin(ax);
      final z = original[1] * math.sin(ax) + rz * math.cos(ax);
      vertices.add([rx, ry, z]);
    }
    final faces = <List<int>>[
      [0,1,2,3], [4,5,6,7], [0,1,5,4], [3,2,6,7], [0,3,7,4], [1,2,6,5],
    ];
    // Maior z = mais perto da câmera; desenhar primeiro as faces distantes.
    double depth(List<int> face) => face.fold<double>(0, (sum, index) => sum + vertices[index][2]) / 4;
    faces.sort((a, b) => depth(a).compareTo(depth(b)));
    for (final face in faces) {
      final path = Path();
      for (var i = 0; i < face.length; i++) {
        final vertex = vertices[face[i]];
        final perspective = 4 / (4 - vertex[2]);
        final px = center.dx + vertex[0] * extent * .14 * perspective;
        final py = center.dy + vertex[1] * extent * .14 * perspective;
        if (i == 0) { path.moveTo(px, py); } else { path.lineTo(px, py); }
      }
      path.close();
      final light = ((depth(face) + 1.75) / 3.5).clamp(0.0, 1.0);
      canvas.drawPath(path, Paint()..color = Color.lerp(
        const Color(0xFF352B6B), const Color(0xFFB3A0FF), light)!);
      canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5
        ..color = const Color(0xFFDCD3FF).withOpacity(.65));
    }
  }

  @override
  bool shouldRepaint(covariant ScenePainter old) =>
    old.phase != phase || old.x != x || old.y != y || old.particles != particles;
}
