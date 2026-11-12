# 11 — Trocar a cor do tema para âmbar

- **Status:** done
- **Spec:** `DESIGN.md`

## Objetivo
Trocar a cor principal de `Colors.teal` para `Colors.amber`, mantendo o estilo
Skeuomorphism e contraste ≥ 4.5:1. Como o âmbar é claro, o texto sobre placas passa a ser escuro.

## Arquivos
- `lib/core/theme/skeuo_theme.dart`
- `lib/ui/widgets/`, `lib/ui/home/`, `lib/ui/search/`, `lib/ui/city/`
- `DESIGN.md`, `AGENTS.md`, `.specs/00-overview.md`

## Checklist
- [x] Tokens e gradientes em âmbar; fundo creme; visores em vidro fumê
- [x] Separar cores de texto por superfície (`ink` × `displayInk`)
- [x] Variantes sobre placa: `favorite`, `rainOnPlate`, `dangerOnPlate`
- [x] Anel de foco e sombra de texto adaptados ao metal claro
- [x] Documentação atualizada
- [x] `flutter analyze` e `flutter test` passando
