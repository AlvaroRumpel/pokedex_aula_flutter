import 'package:flutter/material.dart';

import 'package:pokedex/pokeapi_service.dart';
import 'package:pokedex/pokemon.dart';
import 'package:pokedex/pokemon_detail_page.dart';

// Card de um Pokémon na grade: imagem em cima, nome e número embaixo,
// e um coração no canto.
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap; // o que fazer ao tocar no card
  final bool isFavorite; // coração cheio ou vazio
  final VoidCallback? onFavoriteTap; // o que fazer ao tocar no coração

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero, // o espaço entre os cards vem da grade
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // o efeito do toque respeita as bordas
      child: InkWell(
        onTap: onTap,
        // Stack empilha os filhos: o coração fica por cima, no canto.
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              // Column coloca os filhos um embaixo do outro.
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
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
                  const SizedBox(height: 8),
                  Text(
                    pokemon.name,
                    // Nome comprido não quebra a linha: termina em "...".
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    pokemon.number,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5F5F5F),
                    ),
                  ),
                ],
              ),
            ),
            // O card só mostra o coração; quem guarda os favoritos é a tela.
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: onFavoriteTap,
                tooltip: isFavorite ? 'Desfavoritar' : 'Favoritar',
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? const Color(0xFFCC0000)
                      : const Color(0xFF5F5F5F),
                ),
              ),
            ),
          ],
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

  // Texto digitado na busca. Começa vazio: mostra todos.
  String _query = '';

  // Ids dos favoritos. Ficam só na memória: fechou o app, perdeu.
  final _favorites = <int>{};

  // Marca ou desmarca e redesenha a tela.
  void _toggleFavorite(Pokemon pokemon) {
    setState(() {
      if (!_favorites.remove(pokemon.id)) _favorites.add(pokemon.id);
    });
  }

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
              // Filtra pelo nome, sem diferenciar maiúscula de minúscula.
              final pokemons = snapshot.data!
                  .where(
                    (p) => p.name.toLowerCase().contains(_query.toLowerCase()),
                  )
                  .toList();
              // Column: campo de busca em cima, lista embaixo.
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar pelo nome',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      // A cada letra digitada, guarda o texto e redesenha.
                      onChanged: (text) => setState(() => _query = text),
                    ),
                  ),
                  // Expanded: a lista ocupa o resto da altura da tela.
                  Expanded(
                    child: pokemons.isEmpty
                        ? const Center(child: Text('Nenhum Pokémon encontrado'))
                        // GridView: como o ListView, mas com colunas.
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // 2 colunas
                              mainAxisExtent: 150, // altura de cada card
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: pokemons.length,
                            itemBuilder: (context, i) => PokemonCard(
                              pokemon: pokemons[i],
                              isFavorite: _favorites.contains(pokemons[i].id),
                              onFavoriteTap: () => _toggleFavorite(pokemons[i]),
                              // Navigator.push empilha uma nova tela.
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
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
