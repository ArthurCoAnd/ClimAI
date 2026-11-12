# DESIGN — ClimAI

Estilo: **Glassmorphism** (referência: skill `ui-ux-pro-max`, `data/styles.csv` → "Glassmorphism").
Metáfora: **painéis de vidro fosco** flutuando sobre um céu de fim de tarde — fundo escuro
com manchas de luz âmbar que o vidro desfoca.
Cor principal: `Colors.amber`.

> Histórico: o app começou em Skeuomorphism (teal, depois âmbar) — tasks 05 e 11.
> A troca para Glassmorphism está na task 12.

## Princípios
1. **Vidro fosco**: toda superfície é translúcida, com desfoque do que está atrás (blur 18).
2. **Fundo vibrante**: o vidro só funciona sobre cor; as manchas âmbar dão vida ao desfoque.
3. **Camadas**: painéis flutuam (sombra suave); leituras ficam em "poços" mais escuros dentro do painel.
4. **Legibilidade primeiro**: o fundo é escuro e as manchas têm opacidade ≤ 40%, para o texto
   claro manter contraste ≥ 4.5:1 em qualquer ponto.

## Cores (tokens em `lib/core/theme/glass_theme.dart`)
| Token | Valor | Uso |
|-------|-------|-----|
| `bgTop` / `bgBottom` | `#1F1100` / `#0D0700` | gradiente de fundo (marrom quase preto) |
| `blobAmber` / `blobGold` / `blobOrange` | `Colors.amber` / `amber.shade700` / `deepOrange.shade400` | manchas de luz (radiais, opacidade 25–40%) |
| `glassFill` / `glassFillPressed` | branco 12% / 20% | preenchimento do vidro, normal / pressionado |
| `glassHighlight` | branco 15% | reflexo de luz no canto superior esquerdo |
| `glassBorder` | branco 25% | borda fina (1 px) |
| `glassOpaque` | `#3A2406` | vidro sólido quando o sistema pede alto contraste |
| `wellFill` / `wellBorder` | preto 22% / branco 12% | "poços" de leitura dentro de painéis |
| `ink` | `#FFF8EC` | texto e ícones em todas as superfícies |
| `inkMuted` | `#FFF0CF` | texto secundário |
| `accent` | `Colors.amber.shade300` | estrela de favorito, sol, "Agora", máxima, cursor, anel de foco |
| `rain` | `#B3E5FF` | chuva / probabilidade, mínima |
| `danger` | `#FFCDC4` | erros |
| `handle` | branco 40% | alça do bottom sheet |

**Uma cor de texto só**: todas as superfícies são escuras e translúcidas, então o texto é
sempre claro (`ink`). Nunca usar hex cru nos widgets: sempre os tokens.

## Efeitos
- **Desfoque**: `BackdropFilter` com `ImageFilter.blur(sigma 18)`, recortado pelo raio do painel.
  Só os painéis desfocam; os poços internos apenas escurecem (evita blur aninhado).
- **Reflexo**: gradiente linear `glassHighlight → transparente` do canto superior esquerdo.
- **Borda**: 1 px `glassBorder`, desenhada por cima do conteúdo.
- **Sombra** (`GlassShadows`): `panel` = `0,12,32 preto 25%`; `pressed` = `0,4,12 preto 20%`.
- **Sombra de texto**: `0,1,4 preto 35%`, mantém o texto nítido sobre o desfoque.
- **Alto contraste**: com `MediaQuery.highContrast`, o desfoque é desligado e o vidro vira `glassOpaque`.

## Forma e espaçamento
- Raio: 24 (painéis/cards), 16 (poços, campo de busca), circular (botões de ícone, glifos).
- Grade de 4: espaçamentos 4 / 8 / 12 / 16 / 24.
- Margem lateral das telas: 16. Largura máxima de conteúdo: 640 (centralizado em telas largas).

## Tipografia
Fonte do sistema (Roboto). Números com `FontFeature.tabularFigures()`.
| Estilo | Tamanho / peso | Uso |
|--------|----------------|-----|
| display | 72 / w200 | temperatura atual (página do município) |
| headline | 40 / w300 | temperatura no card da Home |
| title | 20 / w600 | nome do município, títulos de seção |
| body | 16 / w500 | descrições |
| label | 13 / w600, espaçamento 0.4 | rótulos e métricas |

Pesos leves nos números grandes combinam com o vidro. Tamanho mínimo 12; respeitar a escala de texto do sistema.

## Ícones
Material Icons (`Icons.*`), nunca emoji. Um ícone por código WMO, com variação dia/noite
(`lib/core/weather_codes.dart`). Ícones de clima dentro de um poço circular (`WeatherGlyph`).

## Movimento
- Pressão: 120 ms para afundar (escala 0.98, vidro clareia), 250 ms para voltar, `Curves.easeOut`.
- Transições de página: padrão da plataforma.
- Com `MediaQuery.disableAnimations`, durações viram zero.

## Componentes (`lib/ui/widgets/`)
| Componente | Descrição |
|------------|-----------|
| `GlassBackground` | gradiente escuro + manchas âmbar |
| `GlassPanel` | superfície de vidro: desfoque, preenchimento, reflexo, borda, sombra |
| `GlassCard` | `GlassPanel` com padding, opcionalmente tocável |
| `GlassWell` | poço escuro dentro de um painel, para leituras |
| `GlassIconButton` | botão circular de vidro, 48×48, com tooltip/semântica |
| `GlassButton` | botão de vidro com rótulo |
| `GlassNotice` | painel com ícone, mensagem e ação (estados vazio/erro) |
| `WeatherGlyph` | ícone de clima em poço circular |
| `MetricChip` | ícone + valor (umidade, chuva) |
| `HourlyStrip` | faixa horizontal de fichas horárias (página e painel do dia) |

## Telas
### Home
Cabeçalho com o nome do app e botão de busca de vidro. Lista de `GlassCard`:
à esquerda `WeatherGlyph`; ao centro município/UF e descrição; à direita um `GlassWell`
com a temperatura; rodapé com umidade e botão remover.
Estado vazio: `GlassNotice` com ícone, texto e `GlassButton` "Buscar município".

### Busca
Campo de texto num `GlassPanel`. Resultados como cards de vidro com nome/UF e
estrela (`accent`, preenchida, quando favorito).

### Município
1. `GlassCard` herói: `WeatherGlyph` grande, temperatura em `display` dentro de um poço,
   descrição, umidade e sensação térmica.
2. "Próximas 24 horas": `HourlyStrip` dentro de um `GlassPanel`.
3. "Próximos 7 dias": 7 `GlassCard` tocáveis com chevron indicando que abrem detalhe.

### Painel do dia
Bottom sheet de vidro com alça, título do dia, resumo máx/mín e `HourlyStrip` do dia.

## Acessibilidade
- Contraste ≥ 4.5:1 do texto `ink`/`inkMuted`/`accent`/`rain` sobre o vidro, inclusive sobre as manchas
  (por isso o fundo escuro e as manchas ≤ 40%). Anel de foco `accent`, 3 px.
- Alto contraste do sistema desliga a translucidez.
- Alvos de toque ≥ 48×48 dp, com ≥ 8 dp entre eles.
- Botões de ícone com `tooltip`; cards com `Semantics` resumindo o conteúdo.
- Informação nunca só por cor: ícone + texto sempre juntos.
