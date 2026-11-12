# AGENTS — orientações para agentes

ClimAI é um app Flutter de clima por município (Open-Meteo). Leia este arquivo antes de alterar o projeto.

## Onde está cada coisa
| Caminho | Conteúdo |
|---------|----------|
| `.specs/` | Especificações funcionais (fonte da verdade do comportamento) |
| `.tasks/` | Tasks de desenvolvimento, uma por arquivo, com status |
| `DESIGN.md` | Sistema de design (Glassmorphism, âmbar) |
| `.agents/skills/` | Skills locais; para UI use `ui-ux-pro-max` |
| `lib/core/` | Tema/tokens e mapeamento de códigos de clima |
| `lib/data/` | Modelos, clientes de API e persistência |
| `lib/state/` | Controllers (`ChangeNotifier`) |
| `lib/ui/` | Telas (`home`, `search`, `city`) e widgets compartilhados (`widgets`) |
| `test/` | Testes unitários e de widget |

## Fluxo de trabalho
1. Leia a spec relacionada em `.specs/` e o `DESIGN.md` (para qualquer mudança visual).
2. Pegue a próxima task `pending` em `.tasks/` e marque `in_progress`.
3. Implemente seguindo as convenções abaixo.
4. Rode `flutter analyze` e `flutter test` — ambos devem passar sem avisos.
5. Marque o checklist e o status da task como `done`.
6. Mudou o comportamento? Atualize a spec no mesmo trabalho. Trabalho novo? Crie uma task nova numerada.

## Stack e convenções
- Flutter (canal master) / Dart 3.15. O Material vem do pacote **`material_ui`**:
  importe `package:material_ui/material_ui.dart`, **não** `package:flutter/material.dart`.
- Use dot-shorthands do Dart quando deixarem o código mais limpo (`.fromSeed(...)`, `.all(8)`).
- Dependências permitidas: `http`, `shared_preferences`. Não adicione pacotes sem necessidade clara.
- Estado: `ChangeNotifier` + `ListenableBuilder`. Sem gerenciadores de estado externos.
- Clientes de API recebem `http.Client` no construtor (injeção para testes). Nunca faça HTTP dentro de widgets.
- Lógica de agregação/derivação fica em funções puras em `lib/data/models/` com teste unitário.
- Textos da interface em **PT-BR**; identificadores de código em inglês.
- Unidades: °C e %, temperaturas arredondadas para inteiro na exibição.

## UI
- Estilo Glassmorphism com `Colors.amber`: use os tokens de `lib/core/theme/glass_theme.dart`
  e os componentes `Glass*` de `lib/ui/widgets/`. Não use hex cru nem `Card`/`ElevatedButton` padrão.
- Texto sempre claro (`GlassColors.ink`). Painéis soltos no fundo usam `GlassPanel`/`GlassCard`;
  leituras dentro de um painel usam `GlassWell` (não aninhe `BackdropFilter`).
- Respeite `MediaQuery.highContrast` (vidro opaco) — já tratado em `GlassPanel`.
- Ícones: `Icons.*` (Material). Nunca emojis como ícone.
- Alvos de toque ≥ 48 dp, contraste ≥ 4.5:1, `tooltip` em botões de ícone, respeitar `disableAnimations`.
- Toda tela com dados remotos trata os estados carregando / erro (com "Tentar novamente") / vazio.

## APIs
Open-Meteo, sem chave. Endpoints e parâmetros em `.specs/04-dados-api.md`.
A Archive API tem cliente (`lib/data/api/archive_api.dart`) mas não é usada na UI por decisão do produto.

## Comandos
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Não faça
- Não commite nem faça push sem o usuário pedir.
- Não edite arquivos gerados de plataforma (`android/`, `web/`) além do necessário para a task.
- Não remova specs ou tasks concluídas: elas são o histórico do projeto.
