import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex/pokeapi_service.dart';
import 'package:pokedex/pokemon_list_page.dart';
import 'package:pokedex/pokemon.dart';

// Serviço falso: devolve o que o teste mandar, sem internet.
class FakePokeApiService extends PokeApiService {
  FakePokeApiService(this.onFetchPokemons);

  final Future<List<Pokemon>> Function() onFetchPokemons;

  @override
  Future<List<Pokemon>> fetchPokemons() => onFetchPokemons();
}

Widget app(Future<List<Pokemon>> Function() fetch) =>
    MaterialApp(home: PokemonListPage(service: FakePokeApiService(fetch)));

void main() {
  testWidgets('mostra carregando', (tester) async {
    await tester.pumpWidget(app(() => Completer<List<Pokemon>>().future));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra lista', (tester) async {
    await tester.pumpWidget(app(() async => [
          const Pokemon(id: 1, name: 'Bulbasaur'),
          const Pokemon(id: 4, name: 'Charmander'),
        ]));
    await tester.pumpAndSettle();
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Charmander'), findsOneWidget);
    // Sem rede no teste, a imagem cai no ícone do errorBuilder.
    expect(find.byIcon(Icons.catching_pokemon), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mostra erro', (tester) async {
    await tester.pumpWidget(
        app(() => Future<List<Pokemon>>.error(Exception('sem internet'))));
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível carregar'), findsOneWidget);
  });
}
