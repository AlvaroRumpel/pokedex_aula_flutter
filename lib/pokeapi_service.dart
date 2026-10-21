import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:pokedex/pokemon.dart';

// Serviço: a única classe do app que conversa com a PokeAPI.
// As telas pedem os dados para ele e não sabem nada de URL, HTTP ou JSON.
class PokeApiService {
  // O client vem de fora (injeção de dependência): nos testes dá para
  // passar um client falso e testar sem internet.
  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // Configuração num lugar só: se a API mudar, muda aqui.
  static const _baseUrl = 'https://pokeapi.co/api/v2';

  // Busca os 151 primeiros Pokémon.
  Future<List<Pokemon>> fetchPokemons() async {
    final body = await _get('/pokemon?limit=151');
    return pokemonsFromJson(body);
  }

  // Busca tipos, altura e peso de um Pokémon pelo id.
  Future<PokemonDetails> fetchPokemonDetails(int id) async {
    final body = await _get('/pokemon/$id');
    return PokemonDetails.fromJson(jsonDecode(body) as Map<String, dynamic>);
  }

  // GET usado por todos os métodos: a checagem do status fica num lugar só.
  // async/await: "await" espera a resposta chegar sem travar a tela.
  Future<String> _get(String path) async {
    final response = await _client.get(Uri.parse('$_baseUrl$path'));
    if (response.statusCode != 200) {
      throw Exception('A API respondeu ${response.statusCode}');
    }
    return response.body;
  }
}
