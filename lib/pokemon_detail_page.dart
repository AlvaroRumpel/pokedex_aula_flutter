import 'package:flutter/material.dart';

import 'package:pokedex/pokeapi_service.dart';
import 'package:pokedex/pokemon.dart';

// Tela de detalhe: recebe o Pokémon da lista e busca tipos, altura e peso.
class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({
    super.key,
    required this.pokemon,
    required this.service,
  });

  final Pokemon pokemon; // veio da lista pelo Navigator.push
  final PokeApiService service; // o mesmo serviço da lista

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  // Guardado no State: se ficasse no build, cada redesenho buscaria de novo.
  // late: só é calculado no primeiro uso, quando já existe acesso a widget.
  late final Future<PokemonDetails> _future =
      widget.service.fetchPokemonDetails(widget.pokemon.id);

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;
    return Scaffold(
      // O Navigator põe a seta de voltar na AppBar sozinho.
      appBar: AppBar(title: Text(pokemon.name)),
      // Align no topo: o conteúdo começa logo abaixo da AppBar.
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: FutureBuilder<PokemonDetails>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Não foi possível carregar'));
              }
              final details = snapshot.data!;
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    Container(
                      width: 240,
                      height: 240,
                      alignment:
                          Alignment.center, // sem isso a imagem estica até 240
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Image.network(
                        pokemon.largeImageUrl,
                        width: 180,
                        errorBuilder: (context, error, stack) => const Icon(
                          Icons.catching_pokemon,
                          size: 80,
                          color: Color(0xFF9A9A9A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(pokemon.number,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5F5F5F))),
                    Text(pokemon.name,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    // Wrap quebra de linha sozinho se os chips não couberem.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final type in details.types)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: typeColor(type),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(type,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Altura e peso lado a lado, cada um num card.
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(details.heightText,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  const Text('Altura'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(details.weightText,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  const Text('Peso'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
