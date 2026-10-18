import 'package:flutter/material.dart';

import 'package:pokedex/pokemon_list_page.dart';

void main() => runApp(const PokedexApp());

// Tudo no Flutter é widget: o app, a tela, o texto e até o espaçamento.
// Por isso o app inteiro começa com uma classe "widget" como esta.
class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      // Tema: define as cores e o estilo de todo o app de uma vez só.
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFCC0000),
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFCC0000),
          foregroundColor: Colors.white,
        ),
      ),
      // A primeira tela do app.
      home: const PokemonListPage(),
    );
  }
}
