# 15 — Gráfico das próximas 24 horas

- **Status:** done
- **Spec:** `.specs/03-pagina-municipio.md`, `DESIGN.md`

## Objetivo
Abaixo do painel "Próximas 24 horas", um gráfico com as horas no eixo x, temperatura
no eixo y esquerdo e, nos eixos y direitos, a chance de chuva (0–100 %) e a chuva em mm.
Temperatura em área âmbar, mm em barras azuis e % em linha cinza tracejada.

## Arquivos
- `lib/data/models/chart_axis.dart` (escalas, funções puras)
- `lib/ui/widgets/hourly_chart.dart` (`CustomPainter`, sem pacotes novos)
- `lib/core/theme/glass_theme.dart` (tokens `chart*`), `lib/core/formatters.dart` (`formatDecimal`)
- `lib/ui/city/city_page.dart`
- `test/chart_axis_test.dart`, `test/home_page_test.dart`, spec e `DESIGN.md`

## Checklist
- [x] Escalas com 4 intervalos e grade compartilhada
- [x] Área, barras e linha tracejada com legenda
- [x] Balão ao passar o mouse / tocar / arrastar
- [x] Resumo para leitor de tela
- [x] Cores validadas para daltonismo sobre o vidro escuro
- [x] Testes de escala e de presença na página
- [x] `flutter analyze` e `flutter test` passando
