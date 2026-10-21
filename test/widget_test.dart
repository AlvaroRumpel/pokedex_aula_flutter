import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex/pokeapi_service.dart';
import 'package:pokedex/pokemon.dart';
import 'package:pokedex/pokemon_detail_page.dart';
import 'package:pokedex/pokemon_list_page.dart';

// Serviço falso: devolve o que o teste mandar, sem internet.
class FakePokeApiService extends PokeApiService {
  FakePokeApiService({this.onFetchPokemons, this.onFetchDetails});

  final Future<List<Pokemon>> Function()? onFetchPokemons;
  final Future<PokemonDetails> Function(int id)? onFetchDetails;

  @override
  Future<List<Pokemon>> fetchPokemons() => onFetchPokemons!();

  @override
  Future<PokemonDetails> fetchPokemonDetails(int id) =>
      // Sem resposta definida, devolve um detalhe vazio na hora.
      onFetchDetails?.call(id) ??
      Future.value(const PokemonDetails(types: [], height: 0, weight: 0));
}

Widget app(Future<List<Pokemon>> Function() fetch) => MaterialApp(
  home: PokemonListPage(service: FakePokeApiService(onFetchPokemons: fetch)),
);

void main() {
  testWidgets('mostra carregando', (tester) async {
    await tester.pumpWidget(app(() => Completer<List<Pokemon>>().future));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra lista', (tester) async {
    await tester.pumpWidget(
      app(
        () async => [
          const Pokemon(id: 1, name: 'Bulbasaur'),
          const Pokemon(id: 4, name: 'Charmander'),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Charmander'), findsOneWidget);
    // Sem rede no teste, a imagem cai no ícone do errorBuilder.
    expect(find.byIcon(Icons.catching_pokemon), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('card pinta com a cor do primeiro tipo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PokemonListPage(
          service: FakePokeApiService(
            onFetchPokemons: () async => [
              const Pokemon(id: 4, name: 'Charmander'),
            ],
            onFetchDetails: (_) async => const PokemonDetails(
              types: ['fire', 'flying'],
              height: 6,
              weight: 85,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final card = tester.widget<Card>(find.byType(Card));
    expect(card.color, typeColor('fire'));
  });

  testWidgets('mostra erro', (tester) async {
    await tester.pumpWidget(
      app(() => Future<List<Pokemon>>.error(Exception('sem internet'))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível carregar'), findsOneWidget);
  });

  testWidgets('detalhe mostra dados', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PokemonDetailPage(
          pokemon: const Pokemon(id: 1, name: 'Bulbasaur'),
          service: FakePokeApiService(
            onFetchDetails: (_) async => const PokemonDetails(
              types: ['grass', 'poison'],
              height: 7,
              weight: 69,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final text in [
      '#001',
      'grass',
      'poison',
      '0,7 m',
      '6,9 kg',
      'Altura',
      'Peso',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    // Nome aparece na AppBar e no título.
    expect(find.text('Bulbasaur'), findsNWidgets(2));
  });

  testWidgets('tocar no card abre detalhe', (tester) async {
    await tester.pumpWidget(
      app(() async => [const Pokemon(id: 1, name: 'Bulbasaur')]),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bulbasaur'));
    await tester.pumpAndSettle();
    expect(find.byType(PokemonDetailPage), findsOneWidget);
  });

  testWidgets('detalhe mostra erro', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PokemonDetailPage(
          pokemon: const Pokemon(id: 1, name: 'Bulbasaur'),
          service: FakePokeApiService(
            onFetchDetails: (_) => Future<PokemonDetails>.error(Exception('x')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível carregar'), findsOneWidget);
  });
}
