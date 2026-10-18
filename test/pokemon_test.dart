import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/pokemon.dart';

void main() {
  test('number tem 3 dígitos', () {
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
}
