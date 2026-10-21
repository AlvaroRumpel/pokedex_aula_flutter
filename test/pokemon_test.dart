import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/pokemon.dart';

void main() {
  test('numero tem 3 dígitos', () {
    expect(const Pokemon(id: 1, name: 'Bulbasaur').number, '#001');
    expect(const Pokemon(id: 151, name: 'Mew').number, '#151');
  });

  test('urls das imagens usam o id', () {
    const p = Pokemon(id: 25, name: 'Pikachu');
    expect(p.imageUrl,
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png');
    expect(p.largeImageUrl,
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png');
  });

  test('fromJson extrai id da url com barra final e capitaliza', () {
    final p = Pokemon.fromJson(
        {'name': 'pikachu', 'url': 'https://pokeapi.co/api/v2/pokemon/25/'});
    expect(p.id, 25);
    expect(p.name, 'Pikachu');
  });

  test('nome com hífen só capitaliza a primeira letra', () {
    final p = Pokemon.fromJson(
        {'name': 'mr-mime', 'url': 'https://pokeapi.co/api/v2/pokemon/122/'});
    expect(p.name, 'Mr-mime');
  });

  test('pokemonsDoJson lê results', () {
    const body =
        '{"results":[{"name":"bulbasaur","url":"https://pokeapi.co/api/v2/pokemon/1/"},{"name":"ivysaur","url":"https://pokeapi.co/api/v2/pokemon/2/"}]}';
    final list = pokemonsFromJson(body);
    expect(list.length, 2);
    expect(list[1].name, 'Ivysaur');
  });
}
