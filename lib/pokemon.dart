import 'dart:convert';

// Modelo de dados: descreve um Pokémon com só o que a lista precisa.
class Pokemon {
  final int id;
  final String name;

  const Pokemon({required this.id, required this.name});

  // Cria um Pokémon a partir do JSON da lista: {"name": "...", "url": ".../pokemon/25/"}
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    // A url termina com o id (e talvez uma barra): pegamos o último pedaço não vazio.
    final parts = (json['url'] as String).split('/').where((p) => p.isNotEmpty);
    return Pokemon(
      id: int.parse(parts.last),
      name:
          name[0].toUpperCase() + name.substring(1), // primeira letra maiúscula
    );
  }

  // Número com 3 dígitos: 1 vira '#001'.
  String get number => '#${id.toString().padLeft(3, '0')}';

  static const _base =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon';

  // Imagem pequena (sprite), usada na lista.
  String get imageUrl => '$_base/$id.png';

  // Imagem grande (artwork oficial), usada no detalhe.
  String get largeImageUrl => '$_base/other/official-artwork/$id.png';
}

// Transforma o texto JSON da resposta numa lista de Pokémon.
List<Pokemon> pokemonsFromJson(String body) {
  final data = jsonDecode(body) as Map<String, dynamic>;
  final results = data['results'] as List;
  return results
      .map((item) => Pokemon.fromJson(item as Map<String, dynamic>))
      .toList();
}
