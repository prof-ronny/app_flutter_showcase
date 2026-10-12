import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../widgets/motion.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final controller = PageController(viewportFraction: .78);
  double page = 0;
  int current = 0;
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.hasClients) setState(() => page = controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void goToPage(int target) {
    if (!controller.hasClients) return;
    final duration = motionDuration(context);
    if (duration == Duration.zero) {
      controller.jumpToPage(target);
    } else {
      controller.animateToPage(target,
          duration: duration, curve: Curves.easeOutCubic);
    }
  }

  void open(int index) {
    final duration = motionDuration(context, 650);
    final reduced = MediaQuery.of(context).disableAnimations;
    Navigator.of(context).push(PageRouteBuilder<void>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondary) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: DetailScreen(index: index)),
      transitionsBuilder: (context, animation, secondary, child) {
        final curved =
            animation.drive(CurveTween(curve: Curves.easeInOutCubic));
        return FadeTransition(
            opacity: curved,
            child: SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
                        .animate(curved),
                child: child));
      },
    ));
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final height = (constraints.maxHeight * .48).clamp(190.0, 330.0);
        return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Escolha uma dimensão.',
                            style: TextStyle(
                                fontSize: 29, fontWeight: FontWeight.w800)),
                        SizedBox(height: 8),
                        Text('Arraste para os lados. Toque para abrir.'),
                      ])),
              const SizedBox(height: 32),
              SizedBox(
                  height: height,
                  child: ScrollConfiguration(
                    behavior:
                        const MaterialScrollBehavior().copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                    }),
                    child: PageView.builder(
                      controller: controller,
                      itemCount: 3,
                      onPageChanged: (value) => setState(() => current = value),
                      itemBuilder: (context, index) {
                        final distance = (page - index).clamp(-1.0, 1.0);

                        return ClipRect(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, .0005)
                                ..rotateY(distance * .25)
                                ..scale(1 - distance.abs() * .15),
                              child: Semantics(
                                button: true,
                                label: 'Abrir ${GradientCard.titles[index]}',
                                child: GestureDetector(
                                  onTap: () => open(index),
                                  child: Hero(
                                    tag: 'card-$index',
                                    child: GradientCard(index: index),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                    tooltip: 'Anterior',
                    onPressed: current > 0 ? () => goToPage(current - 1) : null,
                    icon: const Icon(Icons.chevron_left)),
                for (var i = 0; i < 3; i++)
                  AnimatedContainer(
                      duration: motionDuration(context, 250),
                      width: i == current ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: i == current
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withOpacity(.3))),
                IconButton(
                    tooltip: 'Próximo',
                    onPressed: current < 2 ? () => goToPage(current + 1) : null,
                    icon: const Icon(Icons.chevron_right)),
              ]),
              Padding(
                  padding: const EdgeInsets.all(24),
                  child: FilledButton.icon(
                      onPressed: () => open(current),
                      icon: const Icon(Icons.open_in_full),
                      label: const Text('Abrir cartão selecionado'))),
            ]);
      });
}

class DetailScreen extends StatefulWidget {
  final int index;
  const DetailScreen({super.key, required this.index});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool favorite = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(GradientCard.titles[widget.index])),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Hero(
              tag: 'card-${widget.index}',
              child: AspectRatio(
                  aspectRatio: 1.5, child: GradientCard(index: widget.index))),
          const SizedBox(height: 28),
          const Text('O mesmo elemento.\nUm novo espaço.',
              style: TextStyle(
                  fontSize: 30, height: 1.15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          const Text(
              'O cartão viaja entre as telas com Hero. O restante da página '
              'aparece com uma combinação de deslocamento e transparência.'),
          const SizedBox(height: 24),
          FilledButton.icon(
              onPressed: () => setState(() => favorite = !favorite),
              icon: AnimatedSwitcher(
                  duration: motionDuration(context, 250),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(favorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(favorite))),
              label: Text(favorite ? 'Adicionado aos favoritos' : 'Favoritar')),
          const SizedBox(height: 16),
          AnimatedSize(
              duration: motionDuration(context),
              curve: Curves.easeInOutCubic,
              child: favorite
                  ? const Card(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                              'A mudança de estado também pode ser visual: ícone, texto e altura animados.')))
                  : const SizedBox(width: double.infinity)),
        ]),
      );
}
