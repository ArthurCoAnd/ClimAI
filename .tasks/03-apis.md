# 03 — Clientes de API

- **Status:** done
- **Spec:** `.specs/04-dados-api.md`

## Objetivo
Implementar os clientes HTTP do Open-Meteo com `http.Client` injetado.

## Arquivos
- `lib/data/api/api_exception.dart`
- `lib/data/api/geocoding_api.dart`
- `lib/data/api/forecast_api.dart`
- `lib/data/api/archive_api.dart`

## Checklist
- [x] `GeocodingApi.search` (Brasil, PT, 20 resultados)
- [x] `ForecastApi.fetchCurrent` e `ForecastApi.fetchForecast`
- [x] `ArchiveApi.fetchDaily` (sem uso na UI)
- [x] Erros convertidos em `WeatherApiException`
