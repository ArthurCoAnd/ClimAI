# 18 — CI/CD: GitHub Pages e Release do APK

- **Status:** done
- **Spec:** `.specs/00-overview.md`

## Objetivo
Automatizar a verificação e a publicação do app com GitHub Actions:
análise e testes em todo PR/push, deploy da versão web no GitHub Pages a cada
push na `main`. A Release do APK Android (tag `v*`) foi preparada mas está
**desabilitada por enquanto**.

## Arquivos
- `.github/workflows/ci.yml` — `analyze` + `test`; na `main`, `flutter build web
  --base-href /<repositório>/`, cópia `index.html` → `404.html` e deploy via
  `actions/deploy-pages`
- `.github/workflows/release.yml` — **desabilitado** (`if: false`, sem gatilho
  de tag); quando reativado, na tag `vX.Y.Z`: `analyze` + `test`,
  `flutter build apk --release --build-name X.Y.Z` e `gh release create` com
  `ClimAI-vX.Y.Z.apk` anexado
- `README.md` (seção "Deploy")

## Checklist
- [x] Workflow de CI + Pages
- [x] Workflow de Release do APK (criado e desabilitado)
- [x] Revisão do Flutter master fixada em `FLUTTER_REF` nos dois workflows
- [x] README documenta o deploy e o passo manual do Pages
- [x] `flutter analyze`, `flutter test` e build web com `--base-href` passando

## Observações
- Para reativar o APK: restaure o gatilho `push: tags: ['v*']` e remova o
  `if: false` do job em `release.yml`.
- Passo manual único: Settings → Pages → Source: **GitHub Actions**.
- Ao atualizar o Flutter local, atualize `FLUTTER_REF` nos workflows.
- Melhoria futura: assinar o APK com um keystore próprio (secrets) em vez da
  chave debug do template, necessário para publicar na Play Store.
