// Modelo de dados: descreve um Pokémon com só o que a lista precisa.
class Pokemon {
  final int id;
  final String name;

  const Pokemon({required this.id, required this.name});

  // Número com 3 dígitos: 1 vira '#001'.
  String get number => '#${id.toString().padLeft(3, '0')}';

  static const _base =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon';

  // Imagem pequena (sprite), usada na lista.
  String get imageUrl => '$_base/$id.png';

  // Imagem grande (artwork oficial), usada no detalhe.
  String get largeImageUrl => '$_base/other/official-artwork/$id.png';
}
