import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_showcase/main.dart';

void main() {
  testWidgets('Navega, abre detalhe e respeita movimento reduzido', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    expect(find.text('Interfaces que\nganham vida.'), findsOneWidget);
    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Galeria 3D'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir cartão selecionado'));
    await tester.pumpAndSettle();
    expect(find.text('O mesmo elemento.\nUm novo espaço.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Galeria'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Próximo'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Anterior'), findsOneWidget);
    await tester.tap(find.byTooltip('Anterior'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cena'));
    await tester.pumpAndSettle();
    expect(find.text('Movimento reduzido'), findsOneWidget);
    await tester.tap(find.text('Abrir painel'));
    await tester.pumpAndSettle();
    expect(find.text('Controle a experiência'), findsOneWidget);
    await tester.tap(find.text('Pronto'));
    await tester.pumpAndSettle();
    expect(find.text('Controle a experiência'), findsNothing);
  });
}
