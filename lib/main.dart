import 'package:flutter/material.dart';
import 'screens/showcase_shell.dart';
import 'package:flutter/semantics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Somente para teste/demonstração em debug.
  debugSemanticsDisableAnimations = false;

  runApp(const ShowcaseApp());
}

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});
  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  bool dark = true;
  bool reducedMotion = false;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorSchemeSeed: const Color(0xFF8268FF),
      scaffoldBackgroundColor:
          dark ? const Color(0xFF111322) : const Color(0xFFF3F1FA),
    );
    return MaterialApp(
      title: 'Flutter • Motion Lab',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Builder(builder: (context) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(disableAnimations: reducedMotion),
          child: ShowcaseShell(
            dark: dark,
            reducedMotion: reducedMotion,
            onThemeChanged: (value) => setState(() => dark = value),
            onMotionChanged: (value) => setState(() => reducedMotion = value),
          ),
        );
      }),
    );
  }
}
