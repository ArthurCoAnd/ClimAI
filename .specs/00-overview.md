# 00 — Visão geral

## Objetivo
ClimAI é um aplicativo Flutter para consultar o clima de municípios brasileiros.
O usuário pesquisa um município, adiciona aos favoritos e acompanha o clima atual,
a previsão horária das próximas 24h e a previsão diária dos próximos 7 dias.

## Telas
| Tela | Spec | Descrição |
|------|------|-----------|
| Home (favoritos) | [01](01-home-favoritos.md) | Lista de cards com o clima atual de cada favorito |
| Busca | [02](02-busca.md) | Pesquisa de municípios e favoritar/desfavoritar |
| Município | [03](03-pagina-municipio.md) | Clima atual + horária 24h + diária 7 dias |
| Painel do dia | [03](03-pagina-municipio.md#painel-do-dia) | Horas de um dia escolhido na previsão diária |
| Widget Android | [05](05-widget-android.md) | Clima atual + próximas 8 horas de um favorito escolhido, na tela inicial |

## Fluxo de navegação
```
Home ──(buscar)──▶ Busca ──(tocar resultado)──▶ Município
  └──(tocar card)────────────────────────────▶ Município ──(tocar dia)──▶ Painel do dia
```

## Fonte de dados
Open-Meteo, sem chave de API. Detalhes em [04](04-dados-api.md).

## Escopo
- Busca restrita ao Brasil (`countryCode=BR`), exibindo "Cidade, UF".
- Favoritos persistidos localmente no dispositivo.
- Interface em português (PT-BR), unidades métricas (°C, %).
- Estilo visual Glassmorphism, cor principal `Colors.amber` (ver `DESIGN.md`).

## Fora de escopo (por enquanto)
- Exibir dados históricos: o cliente da Archive API existe no código, mas não é usado na interface.
- Geolocalização do dispositivo, notificações, contas de usuário, troca de unidades.
- Cache offline da previsão.
