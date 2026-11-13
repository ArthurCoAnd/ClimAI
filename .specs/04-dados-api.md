# 04 — Dados e APIs

Todas as APIs são do Open-Meteo (https://open-meteo.com/), sem autenticação, respostas JSON.

## Geocoding (busca)
`GET https://geocoding-api.open-meteo.com/v1/search`

| Parâmetro | Valor |
|-----------|-------|
| `name` | texto digitado |
| `count` | `20` |
| `language` | `pt` |
| `countryCode` | `BR` |
| `format` | `json` |

Resposta: `results[]` (ausente quando não há resultado) com `id`, `name`, `latitude`,
`longitude`, `admin1` (estado). Mapeia para `City`.

## Forecast (previsão)
`GET https://api.open-meteo.com/v1/forecast`

### Previsão completa (página do município)
| Parâmetro | Valor |
|-----------|-------|
| `latitude`, `longitude` | do município |
| `timezone` | `auto` |
| `forecast_days` | `8` (garante 24h à frente e 7 dias completos) |
| `current` | `temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,is_day` |
| `hourly` | `temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,weather_code,is_day` |
| `daily` | `temperature_2m_max,temperature_2m_min` |

### Clima atual (cards da Home)
Mesma URL, apenas com `current` (sem `hourly`/`daily`).

## Archive (histórico)
`GET https://archive-api.open-meteo.com/v1/archive` com `latitude`, `longitude`,
`start_date`, `end_date` (`yyyy-MM-dd`), `timezone=auto`,
`daily=temperature_2m_max,temperature_2m_min,weather_code`.
Cliente implementado (`ArchiveApi`), **não usado na interface** nesta versão.

## Modelos
- `City { id, name, admin1, latitude, longitude }` — serializável em JSON.
- `CurrentWeather { time, temperature, apparentTemperature, humidity, weatherCode, isDay, precipitation? }`
- `HourlyPoint { time, temperature, humidity, precipitationProbability, weatherCode, isDay, precipitation? }`
- `DailySummary { date, tempMax, tempMin, avgPrecipitationProbability, avgHumidity, totalPrecipitation?, weatherCode, hours[] }`

`precipitation` é a precipitação em mm (chuva + pancadas + neve) do intervalo anterior
(no `current`, o intervalo atual; no `hourly`, a hora anterior). Nulo quando ausente.
- `WeatherForecast { current, hourly[], daily[] }` com `next24Hours` derivado.

Exibição em mm com uma casa decimal e vírgula, sem ",0" (`2,4 mm`, `12 mm`, `0 mm`; ausente: `– mm`).

Horários vêm em hora local do município (`timezone=auto`, formato `yyyy-MM-ddTHH:mm`)
e são tratados como "hora de parede", sem conversão de fuso.

## Previsão horária (24h)
Os 24 pontos de `hourly` a partir da hora cheia de `current.time` (inclusive).

## Agregação diária
Para cada um dos 7 primeiros dias de `daily.time`:
- **Máxima / mínima**: `daily.temperature_2m_max/min`.
- **Probabilidade média de chuva**: média aritmética de `precipitation_probability` das horas do dia (nulos ignorados), arredondada.
- **Umidade média**: média aritmética de `relative_humidity_2m` das horas do dia, arredondada.
- **Precipitação total (mm)**: soma de `precipitation` das horas do dia (nulos ignorados), arredondada a 0,1 mm; nula se nenhuma hora tiver valor.
- **Status médio**: código WMO mais frequente (moda) entre as horas do dia; em empate, o código mais alto (mais severo).
- **hours**: os pontos horários do dia, usados no painel do dia.

## Códigos de clima (WMO)
| Código | Descrição |
|--------|-----------|
| 0 | Céu limpo |
| 1 | Predominantemente limpo |
| 2 | Parcialmente nublado |
| 3 | Nublado |
| 45, 48 | Nevoeiro |
| 51, 53, 55 | Garoa |
| 56, 57 | Garoa congelante |
| 61, 63, 65 | Chuva fraca / moderada / forte |
| 66, 67 | Chuva congelante |
| 71, 73, 75, 77 | Neve |
| 80, 81, 82 | Pancadas de chuva |
| 85, 86 | Pancadas de neve |
| 95 | Trovoada |
| 96, 99 | Trovoada com granizo |

## Persistência
Favoritos em `shared_preferences`, chave `favorites_v1`, valor: string JSON com a lista de `City`.

## Erros
Status HTTP ≠ 200, falha de rede ou JSON inválido resultam em `WeatherApiException`,
tratada pela interface com mensagem e "Tentar novamente".
