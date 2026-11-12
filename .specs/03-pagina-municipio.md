# 03 — Página do município

Mostra os três tipos de apresentação do clima de um município.

## Cabeçalho
- Botão voltar, nome do município + UF.
- Botão de estrela para adicionar/remover dos favoritos.

## Seção 1 — Clima atual
- Temperatura atual (°C, inteiro, em destaque).
- Status do clima: ícone + descrição em PT-BR (variação dia/noite no ícone).
- Umidade relativa (%).
- Sensação térmica (°C) como informação secundária.

## Seção 2 — Previsão horária (próximas 24h)
- Faixa horizontal rolável com 24 itens, começando na hora atual.
- Cada item: hora ("Agora" no primeiro, depois "14h"), ícone do status,
  temperatura (°C), probabilidade de chuva (%), umidade (%).

## Seção 3 — Previsão diária (próximos 7 dias)
- Lista vertical com 7 cards, começando em hoje.
- Cada card: dia ("Hoje", "Amanhã", depois dia da semana + dd/mm), ícone e descrição
  do status médio, temperatura máxima e mínima, probabilidade média de chuva (%),
  umidade média (%).
- Regras de agregação em [04](04-dados-api.md#agregação-diária).
- Tocar num card abre o painel do dia.

## Painel do dia
- Bottom sheet com título do dia e resumo (máx/mín).
- Conteúdo: o mesmo painel horário da Seção 2, com as horas daquele dia (00h–23h)
  — temperatura, probabilidade de chuva, status e umidade.
- Fecha arrastando para baixo, tocando fora ou no botão "Fechar".

## Estados
| Estado | Comportamento |
|--------|---------------|
| Carregando | Placeholders nas três seções |
| Erro | Mensagem e botão "Tentar novamente" |
| Sucesso | Três seções preenchidas |

Pull-to-refresh recarrega a previsão.

## Critérios de aceite
- A faixa horária tem exatamente 24 itens e o primeiro corresponde à hora atual local do município.
- A lista diária tem exatamente 7 cards e o primeiro é "Hoje".
- Tocar num dia abre o painel com as 24 horas daquele dia.
- Favoritar pela estrela reflete na Home ao voltar.
