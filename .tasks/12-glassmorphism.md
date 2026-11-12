# 12 — Trocar o estilo de UI para Glassmorphism

- **Status:** done
- **Spec:** `DESIGN.md`

## Objetivo
Substituir o Skeuomorphism por Glassmorphism (vidro fosco sobre fundo vibrante),
mantendo `Colors.amber` como cor principal e contraste ≥ 4.5:1.

## Arquivos
- `lib/core/theme/glass_theme.dart` (substitui `skeuo_theme.dart`)
- `lib/ui/widgets/glass_surfaces.dart` (substitui `skeuo_surfaces.dart`)
- `lib/ui/widgets/glass_controls.dart` (era `skeuo_controls.dart`)
- `lib/ui/widgets/weather_widgets.dart`, telas em `lib/ui/`
- `DESIGN.md`, `AGENTS.md`, `.specs/00-overview.md`

## Checklist
- [x] Tokens de vidro: preenchimento translúcido, borda, reflexo, sombra suave
- [x] Fundo escuro com manchas âmbar (opacidade ≤ 40%)
- [x] `GlassPanel` com `BackdropFilter` (blur 18) e fallback opaco em alto contraste
- [x] `GlassWell` para leituras dentro de painéis, sem blur aninhado
- [x] Renomear componentes `Skeuo*` → `Glass*`; remover textura de grão
- [x] Texto claro único (`ink`) em todas as superfícies
- [x] Faixa de 24h, campo de busca e avisos viram painéis de vidro
- [x] Documentação atualizada
- [x] `flutter analyze` e `flutter test` passando
