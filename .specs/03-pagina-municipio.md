# 03 — Página do município

Mostra os três tipos de apresentação do clima de um município.

## Cabeçalho
- Botão voltar, nome do município + UF.
- Botão de estrela para adicionar/remover dos favoritos.

## Seção 1 — Clima atual
- Temperatura atual (°C, inteiro, em destaque).
- Status do clima: ícone + descrição em PT-BR (variação dia/noite no ícone).
- Umidade relativa (%).
- Precipitação atual (mm).
- Sensação térmica (°C) como informação secundária.

## Seção 2 — Previsão horária (próximas 24h)
- Faixa horizontal rolável com 24 itens, começando na hora atual.
- Cada item: hora ("Agora" no primeiro, depois "14h"), ícone do status,
  temperatura (°C), probabilidade de chuva (%), precipitação (mm), umidade (%).

## Gráfico das próximas 24h
Painel logo abaixo da faixa horária, com as mesmas 24 horas.
- Eixo x: horas (rótulo a cada 3 h, ou 6 h em telas estreitas; o primeiro é "Agora").
- Eixo y esquerdo: temperatura (°C), passo inteiro de 1, 2, 5, 10 ou 20 °C.
- Eixos y direitos: chance de chuva (0–100 %) e precipitação (mm, de 0 ao primeiro
  máximo redondo que cabe: 2, 4, 8, 10, 20, 40, 80, 100, 200…). Os três eixos têm
  4 intervalos e compartilham as linhas de grade.
- Séries: temperatura como área âmbar, precipitação como barras azuis, chance de chuva
  como linha cinza tracejada. Legenda acima do gráfico.
- Passar o mouse, tocar ou arrastar mostra uma linha vertical e um balão com hora,
  temperatura, chance de chuva e chuva daquela hora.
- Leitor de tela: resumo com faixa de temperatura, chance máxima e chuva total.

## Seção 3 — Previsão diária (próximos 7 dias)
- Lista vertical com 7 cards, começando em hoje.
- Cada card: dia ("Hoje", "Amanhã", depois dia da semana + dd/mm), ícone e descrição
  do status médio, temperatura máxima e mínima, probabilidade média de chuva (%),
  precipitação total do dia (mm), umidade média (%).
- Regras de agregação em [04](04-dados-api.md#agregação-diária).
- Tocar num card abre o painel do dia.

## Painel do dia
- Bottom sheet com título do dia e resumo (máx/mín, chuva média, chuva total em mm, umidade média).
- Conteúdo: o mesmo painel horário da Seção 2, com as horas daquele dia (00h–23h)
  — temperatura, probabilidade de chuva, precipitação (mm), status e umidade.
- Abaixo do painel horário, o mesmo gráfico das próximas 24h (ver acima), com as horas
  do dia (00h–23h, sem "Agora"). O resumo para leitor de tela cita o dia.
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
- O gráfico mostra as mesmas 24 horas da faixa horária, com os três eixos.
- O painel do dia mostra o gráfico com as horas daquele dia.
- Favoritar pela estrela reflete na Home ao voltar.
