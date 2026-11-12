# 04 — Favoritos: persistência e estado

- **Status:** done
- **Spec:** `.specs/01-home-favoritos.md`

## Objetivo
Persistir favoritos e expor o estado (favoritos + clima atual por município).

## Arquivos
- `lib/data/favorites_store.dart`
- `lib/state/favorites_controller.dart`

## Checklist
- [x] `FavoritesStore` em `shared_preferences` (chave `favorites_v1`)
- [x] `FavoritesController`: carregar, adicionar, remover, reinserir (desfazer), alternar
- [x] Clima atual por município com estados carregando/erro/sucesso
- [x] `refreshAll` em paralelo
