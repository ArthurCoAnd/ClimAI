# 20 — Build Android no CI e Release do APK

- **Status:** done
- **Spec:** `.specs/00-overview.md`

## Objetivo
Incluir o Android no CI/CD: gerar o APK em todo PR/push e reativar a Release
do APK em tags `v*` (preparada e desabilitada na task 18).

## Arquivos
- `.github/workflows/ci.yml` — novo job `build-android` (após `check`, em
  paralelo com `build-web`): Java 17, cache do Gradle,
  `flutter build apk --release --build-number <run_number>` e upload do APK
  como artifact `ClimAI-apk` (14 dias). Não bloqueia o deploy do Pages.
- `.github/workflows/release.yml` — reativado: gatilho `push: tags: ['v*']`,
  sem `if: false`, com cache do Gradle; `workflow_dispatch` removido (o nome
  da Release vem da tag)
- `README.md` (seção "Deploy")

## Checklist
- [x] Job `build-android` no `ci.yml` com artifact do APK
- [x] `release.yml` reativado para tags `v*`
- [x] Cache do Gradle nos dois workflows
- [x] README atualizado
- [x] `flutter analyze`, `flutter test` e `flutter build apk --release` passando

## Observações
- O APK continua assinado com a chave debug do template: serve para sideload,
  não para a Play Store. Melhoria futura: keystore próprio via secrets.
- Criar uma Release: `git tag v1.0.0` e `git push origin v1.0.0`.
