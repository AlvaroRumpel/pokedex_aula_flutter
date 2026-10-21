# Pokédex — aula de Flutter

App de Pokédex feito durante uma aula de introdução ao Flutter. Ao final, ele mostra uma lista de Pokémon vindos da internet e uma tela de detalhes para cada um.

## Requisitos

- Flutter 3.32 ou mais novo (Dart 3.8+) para as etapas 1 a 4.
- A etapa 0 é a saída pura do `flutter create` e precisa de Flutter 3.47+.
- Confira com `flutter --version` nas máquinas antes da aula.

## Como rodar

```bash
flutter pub get
flutter run -d chrome
```

## Etapas (branches)

Cada branch parte da anterior. Se você se perder, troque para a branch da etapa atual.

| Branch | O que você aprende |
|---|---|
| `etapa-0-projeto-base` | Projeto criado e rodando no Chrome |
| `etapa-1-primeiro-widget` | `StatelessWidget`, hot reload, mudar texto e cor |
| `etapa-2-card-pokemon` | Classe `Pokemon` e um card com dados fixos |
| `etapa-3-lista-api` | Pacote `http`, serviço `PokeApiService`, `FutureBuilder` e lista com dados reais |
| `etapa-4-tela-detalhe` | `Navigator.push` e o detalhe buscado pelo mesmo serviço |
| `main` | Versão final do app |

Se se perder, use:

```bash
git checkout <branch-da-etapa>
```

## Links úteis

- Documentação do Flutter: https://docs.flutter.dev
- API de Pokémon (PokeAPI): https://pokeapi.co
- Testar código Dart no navegador: https://dartpad.dev
