# 17 — Assets e ícone do aplicativo

- **Status:** done
- **Spec:** `.specs/00-overview.md`

## Objetivo
Registrar a pasta `assets/images/` no `pubspec.yaml` e usar
`assets/images/icone_clima.svg` como ícone do app em todas as plataformas do
projeto (Android e Web).

## Arquivos
- `pubspec.yaml` (seção `flutter.assets`)
- `tool/generate_icons.sh` — rasteriza o SVG com Chrome/Edge headless
  (o SVG usa filtros `feTurbulence`, que conversores simples não renderizam)
- `android/app/src/main/res/mipmap-*/ic_launcher.png` (48–192 px)
- `web/favicon.png` (32 px), `web/icons/Icon-{192,512}.png` e
  `Icon-maskable-{192,512}.png` (desenho na zona segura de 80% sobre `#f3ead7`)

## Checklist
- [x] `assets/images/` declarado no `pubspec.yaml`
- [x] Script de geração reproduzível em `tool/`
- [x] Ícones Android (todas as densidades) e Web (favicon, PWA, maskable)
- [x] `flutter analyze` e `flutter test` passando

## Observação
Para trocar o ícone, edite o SVG e rode `bash tool/generate_icons.sh`.
Se forem adicionadas novas plataformas (`flutter create --platforms=ios,...`),
inclua os tamanhos delas no script.
