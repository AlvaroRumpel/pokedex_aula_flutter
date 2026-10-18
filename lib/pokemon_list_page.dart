import 'package:flutter/material.dart';

import 'package:pokedex/pokemon.dart';

// Card de um Pokémon: imagem, nome, número e uma setinha.
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap; // o que fazer ao tocar no card

  const PokemonCard({super.key, required this.pokemon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
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
              const Icon(Icons.chevron_right, color: Color(0xFF5F5F5F)),
            ],
          ),
        ),
      ),
    );
  }
}

// Tela da lista. Por enquanto mostra um Pokémon fixo.
class PokemonListPage extends StatelessWidget {
  const PokemonListPage({super.key});

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
          child: const Padding(
            padding: EdgeInsets.all(12),
            // Column: o card fica no topo, só com a altura do conteúdo.
            child: Column(
              children: [
                PokemonCard(pokemon: Pokemon(id: 1, name: 'Bulbasaur')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
