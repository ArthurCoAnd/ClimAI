# 13 — Barra de rolagem na borda da tela

- **Status:** done
- **Spec:** `DESIGN.md`

## Objetivo
Em telas largas o conteúdo fica centralizado (máx. 640), mas a barra de rolagem
aparecia colada ao conteúdo, no meio da tela. As áreas roláveis passam a ocupar a
largura total e o conteúdo é centralizado por padding lateral, levando a barra
para a borda direita.

## Arquivos
- `lib/ui/widgets/glass_surfaces.dart` (`ContentWidth` → `ContentLayout` + `contentSidePadding`)
- `lib/ui/widgets/page_header.dart`
- `lib/ui/home/`, `lib/ui/search/`, `lib/ui/city/`
- `test/content_layout_test.dart`, `DESIGN.md`

## Checklist
- [x] `contentSidePadding` calcula o padding que centraliza o conteúdo
- [x] Home, busca e município com listas em largura total
- [x] Teste unitário do padding
- [x] `flutter analyze` e `flutter test` passando
