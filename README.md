# <img src="web/icons/Icon-192.png" alt="Ícone do ClimAI" width="40" align="center"> ClimAI

App de clima feito com IA. Pesquise um município brasileiro, adicione aos favoritos e acompanhe
o clima atual, a previsão das próximas 24 horas e a previsão dos próximos 7 dias.

## Funcionalidades

- **Home (favoritos)**: cards com o clima atual de cada município favorito.
- **Busca**: pesquisa de municípios do Brasil (exibidos como "Cidade, UF"), com favoritar/desfavoritar.
- **Página do município**: clima atual, gráfico horário das próximas 24h (temperatura, chuva em mm
  e probabilidade de chuva) e previsão diária de 7 dias.
- **Painel do dia**: detalhamento hora a hora de um dia escolhido na previsão diária.
- Favoritos salvos localmente no dispositivo.
- Interface em português, unidades métricas (°C, %, mm).
- Visual Glassmorphism com cor principal âmbar, com suporte a alto contraste e redução de animações.

## Tecnologias

| Tecnologia | Uso |
|------------|-----|
| [Flutter](https://flutter.dev/) (canal `master`) | Framework de UI multiplataforma |
| [Dart](https://dart.dev/) 3.15 | Linguagem |
| [`material_ui`](https://pub.dev/packages/material_ui) | Componentes Material |
| [`http`](https://pub.dev/packages/http) | Requisições às APIs |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Persistência local dos favoritos |
| [Open-Meteo](https://open-meteo.com/) | Geocoding e previsão do tempo (gratuita, sem chave de API) |
| `ChangeNotifier` + `ListenableBuilder` | Gerenciamento de estado, sem pacotes externos |
| `flutter_test` / `flutter_lints` | Testes unitários e de widget, análise estática |

Plataformas configuradas: **Web** e **Android**.

## Pré-requisitos

- [Git](https://git-scm.com/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) no canal **master**
  (o projeto exige Dart `^3.15.0-40.0.dev`, ainda não disponível no canal estável)
- Google Chrome (para rodar na Web) e/ou Android Studio com um emulador ou dispositivo Android

Para mudar o Flutter para o canal master:

```bash
flutter channel master
```

```bash
flutter upgrade
```

Confira se o ambiente está pronto:

```bash
flutter doctor
```

## Como baixar

```bash
git clone https://github.com/ArthurCoAnd/ClimAI.git
```

```bash
cd ClimAI
```

## Instalar as dependências

```bash
flutter pub get
```

## Executar

Na Web (Chrome):

```bash
flutter run -d chrome
```

No Android (com emulador aberto ou dispositivo conectado):

```bash
flutter run -d android
```

Para listar os dispositivos disponíveis:

```bash
flutter devices
```

## Testes e análise

```bash
flutter analyze
```

```bash
flutter test
```

## Estrutura do projeto

| Caminho | Conteúdo |
|---------|----------|
| `lib/core/` | Tema/tokens visuais, formatadores e mapeamento de códigos de clima |
| `lib/data/` | Modelos, clientes das APIs Open-Meteo e persistência dos favoritos |
| `lib/state/` | Controllers (`ChangeNotifier`) |
| `lib/ui/` | Telas (`home`, `search`, `city`) e widgets compartilhados (`widgets`) |
| `test/` | Testes unitários e de widget |
| `assets/images/` | Imagens do app (ícone em SVG) |
| `tool/` | Scripts auxiliares (ex.: `generate_icons.sh`, que gera os ícones Android/Web) |
| `.specs/` | Especificações funcionais |
| `.tasks/` | Tasks de desenvolvimento |
| `DESIGN.md` | Sistema de design |
| `AGENTS.md` | Orientações para agentes de IA que trabalham no projeto |

## Fonte dos dados

Dados meteorológicos fornecidos pela [Open-Meteo](https://open-meteo.com/)
(licença [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)). Endpoints e parâmetros
usados estão em [`.specs/04-dados-api.md`](.specs/04-dados-api.md).
