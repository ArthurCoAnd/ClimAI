# 05 — Tema e widgets Skeuomorphism

- **Status:** done
- **Spec:** `DESIGN.md`

## Objetivo
Implementar os tokens de design e os componentes Skeuo reutilizáveis.

## Arquivos
- `lib/core/theme/skeuo_theme.dart`
- `lib/core/weather_codes.dart`
- `lib/core/formatters.dart`
- `lib/ui/widgets/`

## Checklist
- [x] Tokens de cor, gradientes, sombras, tipografia
- [x] `SkeuoBackground`, `SkeuoCard`, `SkeuoDisplay`, `SkeuoIconButton`, `SkeuoButton`
- [x] `WeatherGlyph`, `MetricChip`, `HourlyStrip`
- [x] Mapeamento WMO → descrição PT-BR + ícone (dia/noite)
- [x] Pressão tátil respeitando `disableAnimations`
