module Core where

import Map
import Util.DrawInMap
import Util.CleanTerminal
import System.IO

{-
    Autor: João Targino

    Descrição: loop principal do jogo, no qual os comandos do usuario sao lidos e convertidos em ações no mapa. Por enquanto, apenas a movimentação esta implementada. Recebe a posicao inicial e o mapa
-}

core :: Coord -> GameMap -> IO ()
core playerPos current_map = do
    command <- getLine --recebe a entrada e na sequencia faz a lógica do que fazer

    if command == "q" -- encerra o jogo
    then do
        cleanTerminal
    else do
        let (x,y) = playerPos
        let newPos = case command of
                    "w" -> (x, y - 1) -- cima
                    "s" -> (x, y + 1) -- baixo
                    "a" -> (x - 1, y) -- esquerda
                    "d" -> (x + 1, y) -- direita
                    _ -> playerPos -- ingora se teclar outra coisa

        let destinationTile = getTile newPos current_map -- calcula a tile de destino

        if destinationTile == Empty --verifica se esta vazia (colisão)
        then do
            drawInMap playerPos ' ' -- aqui ele "apaga o player"
            drawInMap newPos '☻' -- redesenha o player em outro lugar

            drawInMap (0,7) ' ' --isso aqui é uma gambiarra para forçar o cursor pra baixo. sem isso aqui, o cursor ficava no mapa e estragava tudo
            putStr "Use W, A, S, D + Enter para andar. 'q' + Enter para sair.\nInput: "

            core newPos current_map --roda o core novamente com a nova posicao (como se fosse um while)

        else do -- se colidir, só roda o core novamente na mesma posicao
            drawInMap (0, 7) ' '
            putStr "Colisão detectada! Use W, A, S, D + Enter.\nInput: "
            core playerPos current_map
