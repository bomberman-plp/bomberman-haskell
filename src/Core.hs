module Core where

import Map
import Util.DrawInMap
import Util.CleanTerminal
import System.IO
import Util.Bomb
import Util.DrawMap (drawMap)

import qualified Data.Map as M
import qualified Data.Set as Set
import Control.Concurrent                                      
import Util.Elimination (checkElimination)

{-
    Autor: João Targino

    Descrição: loop principal do jogo, no qual os comandos do usuario sao lidos e convertidos em ações no mapa. Por enquanto, apenas a movimentação esta implementada. Recebe a posicao inicial e o mapa
-}

core :: Int -> Coord -> Coord -> GameMap -> Maybe BombData -> IO ()
core faseAtual playerPos enemyPos current_map bomb = do

    command <- getLine 

    let ((bomb_x, bomb_y), bombTimer) = case bomb of
            Just (BombData pos timer) -> (pos, timer - 1) 
            Nothing -> ((-1, -1), -1) 
    _ <- checkElimination playerPos (bomb_x, bomb_y) bombTimer

    if command == "q" 
    then do
        cleanTerminal
    else if command == "b" && bombTimer < 0 
    then do
        let ((bomb_x, bomb_y), bombTimer) = (playerPos, 3) 

        newMapBomb <- handleBomb playerPos current_map (Just (BombData (bomb_x, bomb_y) bombTimer)) 

        _ <- drawInMap (0,11) ' ' Empty newMapBomb 

        putStr "\nUse W, A, S, D + Enter para andar.\n" 
        putStr "Use B para jogar a bomba.\n"
        putStr "Use q + Enter para sair.\n"
        putStr "\nInput:"

        core faseAtual playerPos enemyPos newMapBomb (Just (BombData (bomb_x, bomb_y) bombTimer)) 
    else do
        let (x,y) = playerPos
        let newPos = case command of
                    "w" -> (x, y - 1) 
                    "s" -> (x, y + 1) 
                    "a" -> (x - 1, y) 
                    "d" -> (x + 1, y) 
                    _ -> playerPos 

        let destinationTile = getTile newPos current_map 
        -------------------------------------------------------------------------
        -- INTERCEPTAÇÃO: SCRIPT DE VITÓRIA
        -------------------------------------------------------------------------
        if destinationTile == Victory 
        then do
            let proximaFase = faseAtual + 1
            if proximaFase > 5 
                then do 
                    cleanTerminal                    
                    telaVitoria <- readFile "assets/vitoria.txt"  
                    putStrLn telaVitoria                 
                    Control.Concurrent.threadDelay 5000000 
                    cleanTerminal
                    return()
            else do 
                let arquivo =  "assets/level" ++ show proximaFase ++ ".txt"
                (novoMapa, posInicial) <- loadStaticMap arquivo
                let initialEnemyPosition = (1, 9)
                let mapaComPlayer = M.insert posInicial Player novoMapa
                let estadoNovo = M.insert initialEnemyPosition Enemy mapaComPlayer
                cleanTerminal
                drawMap estadoNovo
                putStr "\nUse W, A, S, D + Enter para andar.\n" 
                putStr "Use B para jogar a bomba.\n"
                putStr "Use q + Enter para sair.\n"
                putStr "\nInput:"
                core proximaFase posInicial initialEnemyPosition estadoNovo Nothing

        else if destinationTile == Empty 
        then do

            let oldMap = M.insert playerPos Empty current_map
            let newMap = M.insert newPos Player oldMap

            _ <- drawInMap playerPos ' ' Empty newMap 
            _ <- drawInMap newPos '☻' Player newMap 

            let nextEnemyPos = findNextStep enemyPos newPos newMap
            
            let finalEnemyPos = if nextEnemyPos == newPos 
                                then pass enemyPos newPos newMap 
                                else nextEnemyPos
                                
            let mapSemInimigoVelho = M.insert enemyPos Empty newMap
            let newMapComInimigo = M.insert finalEnemyPos Enemy mapSemInimigoVelho
            
            _ <- drawInMap enemyPos ' ' Empty newMapComInimigo
            _ <- drawInMap finalEnemyPos '⚉' Enemy newMapComInimigo

            newMapBomb <- handleBomb newPos newMapComInimigo (Just (BombData (bomb_x, bomb_y) bombTimer))

            _ <- drawInMap (0,11) ' ' Empty newMapBomb 

            putStr "\nUse W, A, S, D + Enter para andar.\n" 
            putStr "Use B para jogar a bomba.\n"
            putStr "Use q + Enter para sair.\n"
            putStr "\nInput:"

            core faseAtual newPos finalEnemyPos newMapBomb (Just (BombData (bomb_x, bomb_y) bombTimer)) 

        else do 
            newMapBomb <- handleBomb (bomb_x, bomb_y) current_map (Just (BombData (bomb_x, bomb_y) bombTimer)) 

            _ <- drawInMap (0, 11) ' ' Empty newMapBomb

            putStr "\nColisão detectada! Use W, A, S, D + Enter para andar.\n" 
            putStr "Use B para jogar a bomba.\n"
            putStr "Use q + Enter para sair.\n"
            putStr "\nInput:"
            core faseAtual playerPos enemyPos newMapBomb (Just (BombData (bomb_x, bomb_y) bombTimer))

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
