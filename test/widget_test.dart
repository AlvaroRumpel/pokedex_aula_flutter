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

  testWidgets('busca filtra pelo nome', (tester) async {
    await tester.pumpWidget(
      app(
        () async => [
          const Pokemon(id: 1, name: 'Bulbasaur'),
          const Pokemon(id: 4, name: 'Charmander'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'char');
    await tester.pump();
    expect(find.text('Charmander'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsNothing);

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump();
    expect(find.text('Nenhum Pokémon encontrado'), findsOneWidget);
  });

  testWidgets('coração marca e desmarca favorito', (tester) async {
    await tester.pumpWidget(
      app(() async => [const Pokemon(id: 25, name: 'Pikachu')]),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('grade mostra 2 por linha', (tester) async {
    await tester.pumpWidget(
      app(
        () async => [
          const Pokemon(id: 1, name: 'Bulbasaur'),
          const Pokemon(id: 4, name: 'Charmander'),
          const Pokemon(id: 7, name: 'Squirtle'),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);

    // Os dois primeiros ficam na mesma linha; o terceiro desce.
    final y1 = tester.getTopLeft(find.text('Bulbasaur')).dy;
    final y2 = tester.getTopLeft(find.text('Charmander')).dy;
    final y3 = tester.getTopLeft(find.text('Squirtle')).dy;
    expect(y2, y1);
    expect(y3, greaterThan(y1));
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

  testWidgets('busca, favorito, grade e cor juntos', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PokemonListPage(
          service: FakePokeApiService(
            onFetchPokemons: () async => [
              const Pokemon(id: 1, name: 'Bulbasaur'),
              const Pokemon(id: 4, name: 'Charmander'),
            ],
            onFetchDetails: (id) async => PokemonDetails(
              types: [id == 1 ? 'grass' : 'fire'],
              height: 0,
              weight: 0,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);

    // Filtra, favorita o Charmander e limpa a busca.
    await tester.enterText(find.byType(TextField), 'char');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    // Os dois voltam, o favorito continua marcado e cada um tem sua cor.
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    final colors = tester
        .widgetList<Card>(find.byType(Card))
        .map((c) => c.color);
    expect(colors, [typeColor('grass'), typeColor('fire')]);
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
