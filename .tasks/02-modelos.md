# 02 — Modelos e agregação

- **Status:** done
- **Spec:** `.specs/04-dados-api.md`

## Objetivo
Criar os modelos de dados e as funções puras de derivação (24h e agregação diária).

## Arquivos
- `lib/data/models/city.dart`
- `lib/data/models/weather.dart`

## Checklist
- [x] `City` com `toJson`/`fromJson`
- [x] `CurrentWeather`, `HourlyPoint`, `DailySummary`, `WeatherForecast`
- [x] `WeatherForecast.fromJson` com recorte de 24h
- [x] Agregação diária: médias, moda do código WMO (empate → mais severo)
