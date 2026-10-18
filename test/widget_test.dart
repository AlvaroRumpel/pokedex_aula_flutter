import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex/main.dart';

void main() {
  testWidgets('mostra título Pokédex e saudação', (tester) async {
    await tester.pumpWidget(const PokedexApp());
    expect(find.text('Pokédex'), findsOneWidget);
    expect(find.text('Olá, Flutter!'), findsOneWidget);
  });
}
