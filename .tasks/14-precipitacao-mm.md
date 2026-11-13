# 14 — Precipitação em mm nos cards

- **Status:** done
- **Spec:** `.specs/04-dados-api.md`, `.specs/01-home-favoritos.md`, `.specs/03-pagina-municipio.md`

## Objetivo
Buscar a precipitação (mm) no Open-Meteo e exibi-la junto da probabilidade de chuva:
atual nos cards da Home e no card "Agora", por hora na faixa horária e total do dia
nos cards diários e no painel do dia.

## Arquivos
- `lib/data/api/forecast_api.dart` (`precipitation` em `current` e `hourly`)
- `lib/data/models/weather.dart` (`precipitation`, `totalPrecipitation`, `sumPrecipitation`)
- `lib/core/formatters.dart` (`formatRainAmount`)
- `lib/ui/widgets/weather_widgets.dart` (`MetricChip.rainAmount`)
- `lib/ui/home/favorite_card.dart`, `lib/ui/city/city_page.dart`, `lib/ui/city/day_detail_sheet.dart`
- `test/`, specs e `DESIGN.md`

## Checklist
- [x] Parâmetro `precipitation` em `current` e `hourly`
- [x] Modelos com precipitação; total diário pela soma das horas (função pura)
- [x] Formatação PT-BR em mm
- [x] Cards da Home, card "Agora", faixa horária, cards diários e painel do dia
- [x] Testes de parsing, soma, formatação, API e Home
- [x] `flutter analyze` e `flutter test` passando
