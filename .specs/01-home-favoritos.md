# 01 — Home (favoritos)

Tela inicial do app. Lista os municípios favoritos, cada um num card com o clima atual.

## Requisitos
- R1. Listar os favoritos na ordem em que foram adicionados.
- R2. Cada card mostra: nome do município, UF, temperatura atual (°C, inteiro),
  status do clima (ícone + descrição) e umidade relativa (%).
- R3. Tocar no card abre a página do município ([03](03-pagina-municipio.md)).
- R4. Botão visível para abrir a Busca ([02](02-busca.md)).
- R5. Cada card tem um botão visível para remover o município dos favoritos.
  A remoção mostra um SnackBar com a ação "Desfazer".
- R6. Puxar para atualizar (pull-to-refresh) recarrega o clima de todos os favoritos.
- R7. Os favoritos persistem entre execuções do app.
- R8. O clima atual de cada favorito é buscado ao abrir o app, em paralelo.

## Estados
| Estado | Comportamento |
|--------|---------------|
| Vazio (sem favoritos) | Ilustração/ícone, texto explicativo e botão "Buscar município" |
| Carregando (card) | Card com nome do município e placeholder no lugar dos dados |
| Erro (card) | Card com nome do município, mensagem "Não foi possível carregar" e botão "Tentar novamente" |
| Sucesso | Card completo (R2) |

O erro de um município não afeta os demais cards.

## Critérios de aceite
- Com zero favoritos, a tela mostra o estado vazio com o botão de busca.
- Após favoritar um município na busca e voltar, o card aparece sem reiniciar o app.
- Fechar e reabrir o app mantém os favoritos.
- Remover e tocar em "Desfazer" restaura o card na mesma posição.
