module Core where

import Map
import Util.DrawInMap
import Util.CleanTerminal
import System.IO
import Util.Bomb

import qualified Data.Map as M

{-
    Autor: João Targino

    Descrição: loop principal do jogo, no qual os comandos do usuario sao lidos e convertidos em ações no mapa. Por enquanto, apenas a movimentação esta implementada. Recebe a posicao inicial e o mapa
-}

core :: Coord -> GameMap -> Maybe Bomb -> IO ()
core playerPos current_map bomb = do

    -- >>> APENAS ESTA LINHA FOI ADICIONADA AQUI NO INÍCIO PARA O SEU TESTE <<<
    putStrLn $ "\n[TESTE] Conteúdo da posição ATUAL do player na MATRIZ: " ++ show (getTile playerPos current_map)
    putStrLn $ "\n[TESTE] Conteúdo da posição (1,2) na MATRIZ: " ++ show (getTile (1,2) current_map)

    command <- getLine --recebe a entrada e na sequencia faz a lógica do que fazer

    let ((bomb_x, bomb_y), bombTimer) = case bomb of
            Just (Bomb pos timer) -> (pos, timer - 1) -- se a bomba existir, decrementa o timer
            Nothing -> ((-1, -1), -1) -- se não existir, coloca um valor inválido

    if command == "q" -- encerra o jogo
    then do
        cleanTerminal
    else if command == "b" && bombTimer < 0 -- coloca a bomba na posição atual do jogador, se não tiver bomba ativa
    then do
        let ((bomb_x, bomb_y), bombTimer) = (playerPos, 3) -- a bomba tem um timer de 3 turnos, então ela explode depois de 3 comandos do jogador

        handleBomb playerPos current_map (Just (Bomb (bomb_x, bomb_y) bombTimer)) -- desenha a bomba no mapa

        drawInMap (0,7) ' ' --isso aqui é uma gambiarra para forçar o cursor pra baixo. sem isso aqui, o cursor ficava no mapa e estragava tudo
        putStr "Use W, A, S, D + Enter para andar. 'q' + Enter para sair.\nInput: "

        core playerPos current_map (Just (Bomb (bomb_x, bomb_y) bombTimer)) --roda o core novamente com a nova posicao (como se fosse um while)
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
            let oldMap = M.insert playerPos Empty current_map
            let newMap = M.insert newPos Player oldMap

            drawInMap playerPos ' ' -- aqui ele "apaga o player"
            drawInMap newPos '☻' -- redesenha o player em outro lugar
            handleBomb newPos current_map (Just (Bomb (bomb_x, bomb_y) bombTimer)) -- atualiza a bomba

            drawInMap (0,7) ' ' --isso aqui é uma gambiarra para forçar o cursor pra baixo. sem isso aqui, o cursor ficava no mapa e estragava tudo
            putStr "Use W, A, S, D + Enter para andar. 'q' + Enter para sair.\nInput: "

            core newPos newMap (Just (Bomb (bomb_x, bomb_y) bombTimer)) --roda o core novamente com a nova posicao (como se fosse um while)

        else do -- se colidir, só roda o core novamente na mesma posicao
            handleBomb playerPos current_map (Just (Bomb (bomb_x, bomb_y) bombTimer)) -- atualiza a bomba 
            drawInMap (0, 7) ' '
            putStr "Colisão detectada! Use W, A, S, D + Enter.\nInput: "
            core playerPos current_map (Just (Bomb (bomb_x, bomb_y) bombTimer))

