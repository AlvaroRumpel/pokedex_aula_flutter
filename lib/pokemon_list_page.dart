import 'package:flutter/material.dart';

import 'package:pokedex/pokeapi_service.dart';
import 'package:pokedex/pokemon.dart';
import 'package:pokedex/pokemon_detail_page.dart';

// Card de um Pokémon: imagem, nome, número e uma setinha.
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap; // o que fazer ao tocar no card
  final Color? color; // cor do primeiro tipo; sem cor, o card fica branco

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Card colorido pede texto branco; card branco, texto escuro.
    final textColor = color == null ? null : Colors.white;
    final grayOrWhite = color == null ? const Color(0xFF5F5F5F) : Colors.white;
    return Card(
      color: color ?? Colors.white,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // o efeito do toque respeita as bordas
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          // Row coloca os filhos lado a lado.
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDEDED),
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  pokemon.imageUrl,
                  // Se a imagem falhar (sem internet), mostra um ícone.
                  errorBuilder: (context, error, stack) => const Icon(
                    Icons.catching_pokemon,
                    color: Color(0xFF9A9A9A),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Expanded ocupa o espaço que sobra, empurrando a seta p/ a direita.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pokemon.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      pokemon.number,
                      style: TextStyle(fontSize: 13, color: grayOrWhite),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: grayOrWhite),
            ],
          ),
        ),
      ),
    );
  }
}

// Tela da lista: busca os Pokémon na internet e mostra o resultado.
class PokemonListPage extends StatefulWidget {
  // O serviço vem de fora: nos testes dá para trocar por um falso.
  const PokemonListPage({super.key, required this.service});

  final PokeApiService service;

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  // Future = um valor que ainda vai chegar (a resposta da internet).
  // late: só é calculado no primeiro uso, quando já existe acesso a widget.
  late final Future<List<Pokemon>> _future = widget.service.fetchPokemons();

  // A lista não traz os tipos: cada card pede o detalhe do seu Pokémon.
  // O mapa guarda os pedidos por id, para não buscar de novo ao rolar.
  final _details = <int, Future<PokemonDetails>>{};

  Future<PokemonDetails> _detailsOf(Pokemon pokemon) => _details.putIfAbsent(
      pokemon.id, () => widget.service.fetchPokemonDetails(pokemon.id));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pokédex',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('151 Pokémon', style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
      // Center + ConstrainedBox: conteúdo centralizado com largura máxima.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          // FutureBuilder redesenha conforme o estado do Future:
          // carregando, erro ou com dados.
          child: FutureBuilder<List<Pokemon>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Não foi possível carregar'));
              }
              final pokemons = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: pokemons.length,
                // Um FutureBuilder por card: cada um espera os seus tipos.
                itemBuilder: (context, i) => FutureBuilder<PokemonDetails>(
                  future: _detailsOf(pokemons[i]),
                  builder: (context, details) {
                    // Enquanto os tipos não chegam (ou se der erro), fica branco.
                    final types = details.data?.types ?? [];
                    return PokemonCard(
                      pokemon: pokemons[i],
                      color: types.isEmpty ? null : typeColor(types.first),
                      // Navigator.push empilha uma nova tela sobre a atual.
                      // Passamos o Pokémon tocado para a tela de detalhe.
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PokemonDetailPage(
                            pokemon: pokemons[i],
                            service: widget.service,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
