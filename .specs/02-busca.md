# 02 — Busca de municípios

## Requisitos
- R1. Campo de texto com foco automático ao abrir a tela e rótulo "Buscar município".
- R2. A busca dispara 400 ms após o usuário parar de digitar (debounce), com no mínimo 2 caracteres.
- R3. Resultados restritos ao Brasil, até 20 itens, cada um mostrando "Cidade" e "UF" (estado por extenso).
- R4. Cada resultado tem um botão de estrela para adicionar/remover dos favoritos;
  o estado da estrela reflete se o município já é favorito.
- R5. Tocar no resultado (fora da estrela) abre a página do município ([03](03-pagina-municipio.md)),
  mesmo que ele não seja favorito.
- R6. Respostas de buscas antigas são descartadas se o texto já mudou.

## Estados
| Estado | Comportamento |
|--------|---------------|
| Inicial (texto < 2 caracteres) | Dica: "Digite o nome de um município" |
| Carregando | Indicador de progresso |
| Sem resultados | "Nenhum município encontrado para '<texto>'" |
| Erro | Mensagem de erro e botão "Tentar novamente" |
| Sucesso | Lista de resultados |

## Critérios de aceite
- Digitar "Belo Hor" lista "Belo Horizonte — Minas Gerais".
- Tocar na estrela adiciona o município; voltar à Home mostra o novo card.
- Tocar na estrela de um favorito o remove.
