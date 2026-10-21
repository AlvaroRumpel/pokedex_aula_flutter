import 'dart:convert';

import 'package:flutter/material.dart' show Color;

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

// Detalhes de um Pokémon: tipos, altura e peso.
class PokemonDetails {
  final List<String> types;
  final int height; // em decímetros, como a API devolve
  final int weight; // em hectogramas, como a API devolve

  const PokemonDetails(
      {required this.types, required this.height, required this.weight});

  // 7 decímetros viram '0,7 m' (divide por 10, uma casa, vírgula).
  String get heightText => '${_oneDecimal(height)} m';

  String get weightText => '${_oneDecimal(weight)} kg';

  static String _oneDecimal(int value) =>
      (value / 10).toStringAsFixed(1).replaceAll('.', ',');

  // Lê o JSON de /pokemon/{id}; os tipos ficam em types[].type.name.
  factory PokemonDetails.fromJson(Map<String, dynamic> json) {
    final types = (json['types'] as List)
        .map((t) => (t as Map<String, dynamic>)['type']['name'] as String)
        .toList();
    return PokemonDetails(
      types: types,
      height: json['height'] as int,
      weight: json['weight'] as int,
    );
  }
}

// Cor de cada tipo (todas têm bom contraste com texto branco).
Color typeColor(String type) {
  const colors = {
    'grass': Color(0xFF3F7F2F),
    'poison': Color(0xFF8A3F9E),
    'fire': Color(0xFFC8501E),
    'water': Color(0xFF2A6DD7),
    'bug': Color(0xFF6B7F1A),
    'normal': Color(0xFF6E6E5A),
    'electric': Color(0xFF9A7B00),
    'ground': Color(0xFF8A6A2F),
    'fairy': Color(0xFFB0477F),
    'fighting': Color(0xFFA0302A),
    'psychic': Color(0xFFC23B6E),
    'rock': Color(0xFF7F6F2A),
    'ghost': Color(0xFF5A4A8A),
    'ice': Color(0xFF3E8C8C),
    'dragon': Color(0xFF5530C8),
    'flying': Color(0xFF6A5ACD),
    'steel': Color(0xFF6A6A80),
  };
  return colors[type] ?? const Color(0xFF5F5F5F); // tipo desconhecido: cinza
}
