module Core where

import Map
import Util.DrawInMap
import Util.CleanTerminal
import System.IO
import Util.Bomb

import qualified Data.Map as M
import qualified Data.Set as Set
import Control.Concurrent 

{-
    Autor: João Targino

    Descrição: loop principal do jogo, no qual os comandos do usuario sao lidos e convertidos em ações no mapa. Por enquanto, apenas a movimentação esta implementada. Recebe a posicao inicial e o mapa
-}

core :: Coord -> Coord -> GameMap -> Maybe BombData -> IO ()
core playerPos enemyPos current_map bomb = do

    command <- getLine --recebe a entrada e na sequencia faz a lógica do que fazer

    let ((bomb_x, bomb_y), bombTimer) = case bomb of
            Just (BombData pos timer) -> (pos, timer - 1) -- se a bomba existir, decrementa o timer
            Nothing -> ((-1, -1), -1) -- se não existir, coloca um valor inválido

    if command == "q" -- encerra o jogo
    then do
        cleanTerminal
    else if command == "b" && bombTimer < 0 -- coloca a bomba na posição atual do jogador, se não tiver bomba ativa
    then do
        let ((bomb_x, bomb_y), bombTimer) = (playerPos, 3) -- a bomba tem um timer de 3 turnos, então ela explode depois de 3 comandos do jogador

        newMapBomb <- handleBomb playerPos current_map (Just (BombData (bomb_x, bomb_y) bombTimer)) -- desenha a bomba no mapa

        _ <- drawInMap (0,7) ' ' Empty newMapBomb --isso aqui é uma gambiarra para forçar o cursor pra baixo. sem isso aqui, o cursor ficava no mapa e estragava tudo

        putStr "Use W, A, S, D + Enter para andar. 'q' + Enter para sair.\nInput: "

        core playerPos enemyPos newMapBomb (Just (BombData (bomb_x, bomb_y) bombTimer)) --roda o core novamente com a nova posicao (como se fosse um while)
    else do
        let (x,y) = playerPos
        let newPos = case command of
                    "w" -> (x, y - 1) -- cima
                    "s" -> (x, y + 1) -- baixo
                    "a" -> (x - 1, y) -- esquerda
                    "d" -> (x + 1, y) -- direita
                    _ -> playerPos -- ingora se teclar outra coisa

        let destinationTile = getTile newPos current_map -- calcula a tile de destino
        -------------------------------------------------------------------------
        -- INTERCEPTAÇÃO: SCRIPT DE VITÓRIA
        -------------------------------------------------------------------------
        if destinationTile == Victory 
        then do
            cleanTerminal --Limpa o mapa de tela                    
            telaVitoria <- readFile "assets/vitoria.txt"  --carrega o troféu 
            putStrLn telaVitoria  --imprima na tela                 
            Control.Concurrent.threadDelay 5000000  --Tempo de 5 segundos 
            cleanTerminal
            return()

        else if destinationTile == Empty --verifica se esta vazia (colisão)
        then do

            {-Gera um novo mapa atualizando a posição do player no mapa-}

            let oldMap = M.insert playerPos Empty current_map
            let newMap = M.insert newPos Player oldMap

            _ <- drawInMap playerPos ' ' Empty newMap -- aqui ele "apaga o player"
            _ <- drawInMap newPos '☻' Player newMap -- redesenha o player em outro lugar

            -- Calcula o próximo passo usando o BFS
            let nextEnemyPos = findNextStep enemyPos newPos newMap
            
            -- INTERCEPTAÇÃO DA FUGA: Se o BFS disser pro inimigo pisar no player, ele aciona o pass
            let finalEnemyPos = if nextEnemyPos == newPos 
                                then pass enemyPos newPos newMap 
                                else nextEnemyPos
                                
            let mapSemInimigoVelho = M.insert enemyPos Empty newMap
            let newMapComInimigo = M.insert finalEnemyPos Enemy mapSemInimigoVelho
            
            _ <- drawInMap enemyPos ' ' Empty newMapComInimigo
            _ <- drawInMap finalEnemyPos 'E' Enemy newMapComInimigo

            newMapBomb <- handleBomb newPos newMapComInimigo (Just (BombData (bomb_x, bomb_y) bombTimer))

            _ <- drawInMap (0,7) ' ' Empty newMapBomb --isso aqui é uma gambiarra para forçar o cursor pra baixo. sem isso aqui, o cursor ficava no mapa e estragava tudo

            putStr "Use W, A, S, D + Enter para andar. 'q' + Enter para sair.\nInput: "

            {- LINHA DE TESTE PARA VERIFICAR SE TEM UM PLAYER EM UMA POSIÇÃO NA MATRIZ
            -- Buscamos na MATRIZ NOVA o que tem na nova posição:
            let tileNaMatriz = getTile newPos newMap
            putStr $ "Matriz na pos " ++ show newPos ++ " eh: " ++ show tileNaMatriz ++ "\nInput: "
            -}

            core newPos finalEnemyPos newMapBomb (Just (BombData (bomb_x, bomb_y) bombTimer)) --roda o core novamente com a nova posicao (como se fosse um while)

        else do -- se colidir, só roda o core novamente na mesma posicao
            newMapBomb <- handleBomb (bomb_x, bomb_y) current_map (Just (BombData (bomb_x, bomb_y) bombTimer)) -- atualiza a bomba

            _ <- drawInMap (0, 7) ' ' Empty newMapBomb

            putStr "Colisão detectada! Use W, A, S, D + Enter.\nInput: "
            core playerPos enemyPos newMapBomb (Just (BombData (bomb_x, bomb_y) bombTimer))


findNextStep :: Coord -> Coord -> GameMap -> Coord
findNextStep start target gameMap = 
    case bfs [(start, [])] (Set.singleton start) of
        Just step -> step
        Nothing   -> start 
  where
    bfs [] _ = Nothing
    bfs ((current, path):queue) visited
        | current == target = case reverse path of
                                [] -> Nothing
                                (firstStep:_) -> Just firstStep
        | otherwise =
            let (x,y) = current
                neighbors = [(x, y - 1), (x, y + 1), (x - 1, y), (x + 1, y)]
                validNeighbors = filter (\pos -> getTile pos gameMap == Empty || getTile pos gameMap == Player) neighbors
                unvisited = filter (`Set.notMember` visited) validNeighbors
                newVisited = foldr Set.insert visited unvisited
                newQueue = queue ++ map (\n -> (n, n:path)) unvisited
            in bfs newQueue newVisited

            
pass :: Coord -> Coord -> GameMap -> Coord
pass (ex, ey) (px, py) m =
    let dx = signum (ex - px)
        dy = signum (ey - py)
        tryX = (ex + dx, ey)
        tryY = (ex, ey + dy)
        neighbors = [(ex, ey - 1), (ex, ey + 1), (ex - 1, ey), (ex + 1, ey)]
        emptyNeighbors = filter (\pos -> getTile pos m == Empty) neighbors
    in if dx /= 0 && getTile tryX m == Empty 
       then tryX 
       else if dy /= 0 && getTile tryY m == Empty 
       then tryY 
       else if not (null emptyNeighbors)
       then head emptyNeighbors
       else (ex, ey)
