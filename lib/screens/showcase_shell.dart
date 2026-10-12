import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/motion.dart';
import 'gallery_screen.dart';
import 'scene_screen.dart';

class ShowcaseShell extends StatefulWidget {
  final bool dark, reducedMotion;
  final ValueChanged<bool> onThemeChanged, onMotionChanged;
  const ShowcaseShell({super.key, required this.dark, required this.reducedMotion,
    required this.onThemeChanged, required this.onMotionChanged});
  @override
  State<ShowcaseShell> createState() => _ShowcaseShellState();
}

class _ShowcaseShellState extends State<ShowcaseShell> {
  bool menu = false;
  int selected = 0;
  static const titles = ['Visão geral', 'Galeria 3D', 'Cena viva', 'Configurações'];
  static const icons = [Icons.auto_awesome, Icons.view_carousel_outlined,
    Icons.token_outlined, Icons.tune];

  void select(int index) => setState(() { selected = index; menu = false; });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final menuWidth = math.min(width * .7, 285.0);
    return PopScope(
      canPop: !menu,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && menu) setState(() => menu = false);
      },
      child: Scaffold(
        body: Stack(children: [
          Container(decoration: const BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF302450), Color(0xFF111322)]))),
          SafeArea(child: SizedBox(width: menuWidth, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.flutter_dash, size: 48, color: Color(0xFFB3A2FF)),
              const SizedBox(height: 16),
              const Text('MOTION\nLAB', style: TextStyle(color: Colors.white,
                fontSize: 29, fontWeight: FontWeight.w800, letterSpacing: 4)),
              const SizedBox(height: 12),
              const Text('Explore o movimento.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 30),
              Expanded(child: ListView(children: [
                for (var i = 0; i < titles.length; i++) Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(color: selected == i ? Colors.white12 : Colors.transparent,
                    borderRadius: BorderRadius.circular(16), child: ListTile(
                      leading: Icon(icons[i], color: Colors.white),
                      title: Text(titles[i], style: const TextStyle(color: Colors.white)),
                      onTap: () => select(i))),
                ),
              ])),
              TextButton.icon(onPressed: () => setState(() => menu = false),
                icon: const Icon(Icons.close, color: Colors.white70),
                label: const Text('Fechar menu', style: TextStyle(color: Colors.white70))),
            ]),
          ))),
          TweenAnimationBuilder<double>(
            tween: Tween(end: menu ? 1 : 0),
            duration: motionDuration(context), curve: Curves.easeInOutCubic,
            builder: (context, t, child) => Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.identity()
                ..setEntry(3, 2, .0008)
                ..translate(menuWidth * t, 0.0)
                ..rotateY(-.13 * t)
                ..scale(1 - .13 * t),
              child: ClipRRect(borderRadius: BorderRadius.circular(30 * t), child: child),
            ),
            child: Stack(children: [
              Scaffold(
                appBar: AppBar(
                  leading: IconButton(tooltip: 'Abrir menu', icon: const Icon(Icons.menu_rounded),
                    onPressed: () => setState(() => menu = !menu)),
                  title: const Text('MOTION LAB', style: TextStyle(fontSize: 16,
                    letterSpacing: 3, fontWeight: FontWeight.w800)),
                  actions: [IconButton(tooltip: 'Alternar tema',
                    onPressed: () => widget.onThemeChanged(!widget.dark),
                    icon: Icon(widget.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined))],
                ),
                body: SafeArea(top: false, child: AnimatedSwitcher(
                  duration: motionDuration(context, 420),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation,
                    child: SlideTransition(position: Tween<Offset>(
                      begin: const Offset(.05, 0), end: Offset.zero).animate(animation), child: child)),
                  child: TickerMode(key: ValueKey(selected), enabled: !menu, child: _page()),
                )),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: selected,
                  onDestinationSelected: select,
                  destinations: [for (var i = 0; i < titles.length; i++)
                    NavigationDestination(icon: Icon(icons[i]),
                      label: ['Início', 'Galeria', 'Cena', 'Ajustes'][i])],
                ),
              ),
              if (menu) Positioned.fill(child: Semantics(
                button: true, label: 'Fechar menu', child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => menu = false),
                  child: Container(color: Colors.black.withOpacity(.12)),
                ),
              )),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _page() => switch (selected) {
    0 => _overview(),
    1 => const GalleryScreen(),
    2 => const SceneScreen(),
    _ => ListView(padding: const EdgeInsets.all(24), children: [
      const Text('Seu ritmo.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      SwitchListTile(title: const Text('Tema escuro'), value: widget.dark,
        onChanged: widget.onThemeChanged),
      SwitchListTile(title: const Text('Reduzir movimento'),
        subtitle: const Text('Interrompe movimentos contínuos e torna as transições imediatas.'),
        value: widget.reducedMotion, onChanged: widget.onMotionChanged),
      const Padding(padding: EdgeInsets.all(16), child: Text(
        'Os efeitos de profundidade usam perspectiva, sombras e camadas. '
        'O cubo é projetado matematicamente em uma superfície 2D; não usa motor 3D.')),
    ]),
  };

  Widget _overview() => ListView(padding: const EdgeInsets.all(24), children: [
    const Enter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('FEITO COM FLUTTER', style: TextStyle(color: Color(0xFF9A84FF),
        fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.bold)),
      SizedBox(height: 12),
      Text('Interfaces que\nganham vida.', style: TextStyle(fontSize: 36,
        height: 1.1, fontWeight: FontWeight.w800)),
      SizedBox(height: 14),
      Text('Toque, arraste e descubra. Cada interação demonstra um recurso diferente.'),
      SizedBox(height: 28),
      FlipCard(),
      SizedBox(height: 14),
      Center(child: Text('Toque no cartão para virar ↻')),
      SizedBox(height: 28),
    ])),
    _feature(1, 'Explore a galeria', 'Carrossel com perspectiva e transição Hero.', Icons.view_carousel),
    _feature(2, 'Entre na cena viva', 'Cubo projetado, partículas e controle por gesto.', Icons.token),
    Card(child: ExpansionTile(title: const Text('O que observar na demonstração'),
      leading: const Icon(Icons.school_outlined), children: const [
        Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 20), child: Text(
          '1. Abra a gaveta e observe a tela recuar.\n'
          '2. Vire o cartão: o verso continua legível.\n'
          '3. Arraste a galeria e abra um cartão.\n'
          '4. Gire o cubo e abra o painel inferior.\n'
          '5. Alterne o tema e experimente reduzir movimento.')),
      ])),
  ]);

  Widget _feature(int index, String title, String subtitle, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Card(child: ListTile(contentPadding: const EdgeInsets.all(16),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle), trailing: const Icon(Icons.arrow_forward_rounded),
      onTap: () => select(index))),
  );
}
