import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex/main.dart';

void main() {
  testWidgets('mostra título Pokédex e o card do Bulbasaur', (tester) async {
    await tester.pumpWidget(const PokedexApp());
    expect(find.text('Pokédex'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('#001'), findsOneWidget);
  });

  testWidgets('card tem a altura do conteúdo, sem esticar até o fim da tela',
      (tester) async {
    await tester.pumpWidget(const PokedexApp());
    expect(tester.getSize(find.byType(Card)).height, lessThan(200));
  });
}
