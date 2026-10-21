import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/pokemon.dart';

void main() {
  test('numero tem 3 dígitos', () {
    expect(const Pokemon(id: 1, name: 'Bulbasaur').number, '#001');
    expect(const Pokemon(id: 151, name: 'Mew').number, '#151');
  });

  test('urls das imagens usam o id', () {
    const p = Pokemon(id: 25, name: 'Pikachu');
    expect(
      p.imageUrl,
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png',
    );
    expect(
      p.largeImageUrl,
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
    );
  });

  test('fromJson extrai id da url com barra final e capitaliza', () {
    final p = Pokemon.fromJson({
      'name': 'pikachu',
      'url': 'https://pokeapi.co/api/v2/pokemon/25/',
    });
    expect(p.id, 25);
    expect(p.name, 'Pikachu');
  });

  test('nome com hífen só capitaliza a primeira letra', () {
    final p = Pokemon.fromJson({
      'name': 'mr-mime',
      'url': 'https://pokeapi.co/api/v2/pokemon/122/',
    });
    expect(p.name, 'Mr-mime');
  });

  test('pokemonsDoJson lê results', () {
    const body =
        '{"results":[{"name":"bulbasaur","url":"https://pokeapi.co/api/v2/pokemon/1/"},{"name":"ivysaur","url":"https://pokeapi.co/api/v2/pokemon/2/"}]}';
    final list = pokemonsFromJson(body);
    expect(list.length, 2);
    expect(list[1].name, 'Ivysaur');
  });

  test('detalhe lê tipos, altura e peso', () {
    final d = PokemonDetails.fromJson({
      'height': 7,
      'weight': 69,
      'types': [
        {
          'type': {'name': 'grass'},
        },
        {
          'type': {'name': 'poison'},
        },
      ],
    });
    expect(d.types, ['grass', 'poison']);
    expect(d.heightText, '0,7 m');
    expect(d.weightText, '6,9 kg');
  });

  test('valores inteiros mantêm uma casa', () {
    final d = PokemonDetails.fromJson({
      'height': 10,
      'weight': 1000,
      'types': [],
    });
    expect(d.heightText, '1,0 m');
    expect(d.weightText, '100,0 kg');
  });

  test('tipo desconhecido usa cor padrão', () {
    expect(typeColor('stellar'), const Color(0xFF5F5F5F));
    expect(typeColor('grass'), const Color(0xFF3F7F2F));
  });
}
