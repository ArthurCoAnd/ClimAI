# 05 — Widget Android "Próximas 8 horas"

Widget da tela inicial do Android, versão compacta da faixa "Próximas 24 horas"
da página do município ([03](03-pagina-municipio.md#seção-2--previsão-horária-próximas-24h)).

## Conteúdo
- Município: o favorito **escolhido ao adicionar o widget** (ver "Escolha do
  município"). Cada widget tem o seu; dá para ter um widget por favorito.
- **1/3 superior**, tudo numa linha: nome do município, ícone do clima atual,
  temperatura atual (°C, inteiro, em destaque), chance de chuva (%) e precipitação
  (mm), cada leitura com o ícone usado no app (guarda-chuva, gota). Valor ausente:
  "–" / "– mm". Nada no canto superior direito além disso. O widget não mostra
  umidade.
- Clima atual = condições de `current`, como o primeiro ponto de `next24Hours`
  (chance de chuva e mm vêm da previsão da hora atual).
- **2/3 inferiores**: as 8 horas seguintes à atual (sem repetir a hora atual), em
  colunas com hora ("21h"), ícone do status (mesmo mapeamento e tons do app),
  temperatura (°C, inteiro), chance de chuva (%, com o guarda-chuva) e
  precipitação ("0,1 mm", sem ícone por falta de largura).
- Tocar no widget abre o app.

## Escolha do município
- Ao adicionar o widget abre a tela "Escolha o município", com a lista dos
  favoritos na ordem da Home (nome + estado, ícone de local em âmbar).
- Tocar num favorito confirma: o widget é criado e já carrega aquele município.
  Voltar sem escolher cancela a adição.
- Sem favoritos: "Você ainda não tem municípios favoritos. Adicione um no ClimAI
  para usar o widget." + botão "Abrir o ClimAI" (a adição é cancelada).
- Trocar depois (Android 12+): pressionar o widget → "Configurações" reabre a tela,
  com ✓ no município atual. Voltar mantém o município.
- O município escolhido fica guardado com o widget: se ele sair dos favoritos, o
  widget continua mostrando-o até ser reconfigurado ou removido.
- Widgets colocados antes desta tela existir (sem escolha guardada) mostram o
  primeiro favorito.

## Estados
| Estado | Exibição |
|--------|----------|
| Sem município (sem escolha e sem favoritos) | "Adicione um município aos favoritos no ClimAI." |
| Carregando | "Carregando…" (só no primeiro preenchimento; depois mantém a última leitura) |
| Erro | "Não foi possível carregar o clima." + botão "Tentar novamente" |

## Atualização
- O próprio widget busca o Open-Meteo (funciona com o app fechado), a cada 30 min
  (`updatePeriodMillis`, mínimo do Android).
- O app pede atualização pelo canal `climai/home_widget` (método `refresh`) após
  cada mudança nos favoritos. Em outras plataformas (web) a chamada é ignorada.

## Dados
`GET https://api.open-meteo.com/v1/forecast` com os mesmos `current` e `hourly` da
previsão completa ([04](04-dados-api.md)), `timezone=auto` e `forecast_days=2`
(garante 8 horas à frente perto da meia-noite). Os 9 pontos (atual + 8) começam na
hora cheia de `current.time` (hora local do município, não do aparelho).

Os favoritos são lidos de `SharedPreferences` do app (`FlutterSharedPreferences`,
chave `flutter.favorites_v1`, JSON de `City`). O município escolhido é copiado para
as preferências do widget (`climai_widget`, chave `city_<id do widget>`) e apagado
quando o widget é removido. Widgets do mesmo município compartilham uma requisição.

## Visual
Painel de vidro escuro (`GlassPanel` sem blur, que o Android não oferece em
widgets) com as horas num `GlassWell`. Cores espelhadas de `GlassColors` em
`android/app/src/main/res/values/widget_colors.xml`. Ícones Material extraídos da
fonte do Flutter como vector drawables (`res/drawable/ic_weather_*.xml`).
Tamanho padrão 4×2 células, redimensionável.

## Implementação
| Arquivo | Papel |
|---------|-------|
| `android/.../widget/HourlyWidgetProvider.kt` | `AppWidgetProvider`: resolve o município de cada widget, busca e monta os `RemoteViews` |
| `android/.../widget/HourlyWidgetConfigureActivity.kt` | Tela "Escolha o município" (`layout/widget_configure*.xml`) |
| `android/.../widget/WidgetCities.kt` | Favoritos do app e município escolhido por widget |
| `android/.../widget/HourlyForecast.kt` | Recorte da hora atual + 8 horas e formatação (espelha `weather.dart`/`formatters.dart`) |
| `android/.../widget/WeatherIcons.kt` | Código WMO → ícone, tom e descrição (espelha `weather_codes.dart`) |
| `android/.../MainActivity.kt` | Canal `climai/home_widget` |
| `lib/data/home_widget_updater.dart` | Lado Dart do canal, injetado no `FavoritesController` |
