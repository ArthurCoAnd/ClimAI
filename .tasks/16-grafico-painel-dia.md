# 16 — Gráfico no painel do dia

- **Status:** done
- **Spec:** `.specs/03-pagina-municipio.md`, `DESIGN.md`

## Objetivo
Mostrar o gráfico horário (task 15) também no painel que abre ao tocar num dos
próximos 7 dias, com as 24 horas daquele dia.

## Arquivos
- `lib/ui/city/day_detail_sheet.dart`
- `lib/ui/widgets/hourly_chart.dart` (`semanticsTitle` para o resumo acessível)
- `test/home_page_test.dart`, spec e `DESIGN.md`

## Checklist
- [x] `HourlyChart` abaixo do `HourlyStrip`, dentro de um `GlassWell`
- [x] Resumo para leitor de tela com o nome do dia
- [x] Teste de widget do painel
- [x] `flutter analyze` e `flutter test` passando
