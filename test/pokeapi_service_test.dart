import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:pokedex/pokeapi_service.dart';

void main() {
  test('fetchPokemons chama a URL certa e lê a lista', () async {
    Uri? requestedUrl;
    final service = PokeApiService(
      client: MockClient((request) async {
        requestedUrl = request.url;
        return http.Response(
            '{"results":[{"name":"bulbasaur","url":"https://pokeapi.co/api/v2/pokemon/1/"}]}',
            200);
      }),
    );

    final pokemons = await service.fetchPokemons();

    expect(
        requestedUrl.toString(), 'https://pokeapi.co/api/v2/pokemon?limit=151');
    expect(pokemons.single.name, 'Bulbasaur');
  });

  test('status diferente de 200 vira Exception', () async {
    final service = PokeApiService(
      client: MockClient((request) async => http.Response('erro', 500)),
    );

    expect(service.fetchPokemons(), throwsException);
  });
}
