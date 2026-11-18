# 19 — Widget Android "Próximas 8 horas"

- **Status:** done
- **Spec:** `.specs/05-widget-android.md`

## Objetivo
Widget da tela inicial do Android, parecido com o card "Próximas 24 horas", mas
com o clima atual e as 8 próximas horas do primeiro município favorito
(começou com 6 horas; ver ajustes abaixo).

## Arquivos
- `android/app/src/main/kotlin/com/arthurcoand/clim_ai/widget/` — provider,
  recorte das horas e mapeamento de ícones (Kotlin, sem dependências novas)
- `android/app/src/main/kotlin/com/arthurcoand/clim_ai/MainActivity.kt` — canal
  `climai/home_widget`
- `android/app/src/main/res/` — `layout/hourly_widget.xml`,
  `xml/hourly_widget_info.xml`, `drawable/widget_*.xml`, `drawable/ic_weather_*.xml`,
  `values/widget_*.xml`
- `android/app/src/main/AndroidManifest.xml` — `<receiver>` do widget
- `lib/data/home_widget_updater.dart`, `lib/state/favorites_controller.dart`,
  `lib/main.dart`
- `test/home_widget_updater_test.dart`

## Checklist
- [x] Provider busca o Open-Meteo e mostra 6 horas ("Agora" + 5)
- [x] Estados: sem favoritos, carregando, erro com "Tentar novamente"
- [x] App atualiza o widget ao mudar os favoritos (no-op fora do Android)
- [x] Ícones Material como vector drawables, cores dos tokens Glass
- [x] Spec criada e visão geral atualizada
- [x] `flutter analyze`, `flutter test` e `flutter build apk --debug` passando

### Ajuste: hora atual em destaque
- [x] Precipitação (mm) e umidade (%) em todas as horas
- [x] "Agora" num painel maior à esquerda, 5 horas seguintes à direita
- [x] Removido o texto "Próximas 6h"; o cabeçalho mostra a descrição do clima atual
- [x] Conferido no emulador (sem textos cortados)

### Ajuste: layout em duas faixas e 8 horas
- [x] 1/3 superior: município, ícone, temperatura, chuva (%), mm e umidade em linha
- [x] 2/3 inferiores: 8 horas seguintes, só hora, ícone e temperatura (sem repetir
  as leituras da hora atual)
- [x] Nenhum texto no canto superior direito
- [x] Conferido no emulador

### Ajuste: chuva nas 8 horas
- [x] Chance de chuva (%) e precipitação (mm) em cada uma das 8 horas
- [x] Conferido no emulador (sem textos cortados)

### Ajuste: sem umidade
- [x] Umidade removida da linha do clima atual (o widget não mostra umidade)
- [x] Conferido no emulador

### Ajuste: escolher o município de cada widget
- [x] Tela "Escolha o município" ao adicionar o widget (`HourlyWidgetConfigureActivity`)
- [x] Município guardado por widget (`WidgetCities`); widgets antigos usam o 1º favorito
- [x] Reconfigurar pelo "Configurações" do widget (Android 12+), com ✓ no atual
- [x] Sem favoritos: mensagem + "Abrir o ClimAI"
- [x] Conferido no emulador: dois widgets com municípios diferentes; voltar na
  reconfiguração mantém o widget

## Observações
- O Kotlin espelha regras do Dart (recorte de horas, códigos WMO, formatação).
  Mudou `weather.dart`, `weather_codes.dart` ou `formatters.dart`? Revise o widget.
- Os ícones foram extraídos de `materialicons-regular.otf` (Flutter SDK) com
  fontTools; para trocar um ícone, gere o `pathData` do glifo do mesmo jeito.
- Verificado no emulador: estado vazio, favoritar atualiza o widget na hora, 6 horas
  com ícones e cores corretos.
- Ambiente: com o Android cmdline-tools 23 (CLI `android`), o Gradle não consegue
  instalar o NDK sozinho ("Package ndk not found"). Instale manualmente:
  `android sdk install ndk/28.2.13676358` (em `cmdline-tools/latest/bin`).
