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



core :: Int -> Coord -> Coord -> GameMap -> Maybe BombData -> IO ()
core faseAtual playerPos enemyPos current_map bomb = do
    
    cleanTerminal
    drawMap current_map
    
    let ((bomb_x, bomb_y), currentBombTimer) = case bomb of
            Just (BombData pos timer) -> (pos, timer) 
            Nothing -> ((-1, -1), -1) 
            
    _ <- checkElimination playerPos (bomb_x, bomb_y) currentBombTimer

    putStr "\nUse W, A, S, D para andar." 
    putStr "\nUse B para jogar bomba ou Espaço para esperar."
    putStr "\nUse Q para sair."
    putStr "\nInput: "
    
    hSetBuffering stdin NoBuffering
    hSetEcho stdin False

    command <- getChar  

    let bombTimer = currentBombTimer - 1

    if command == 'q' 
    then do
        hSetBuffering stdin LineBuffering
        hSetEcho stdin True
        clearTerminalScrollback
    else do
        let hasActiveBomb = bombTimer >= -1
        
        let (x,y) = playerPos
        let intentPos = case command of
                    'w' -> (x, y - 1) 
                    's' -> (x, y + 1) 
                    'a' -> (x - 1, y) 
                    'd' -> (x + 1, y) 
                    _   -> playerPos 

        let destinationTile = getTile intentPos current_map 
        
        if destinationTile == Victory 
        then do
            let proximaFase = faseAtual + 1
            if proximaFase > 5 
                then do 
                    hSetBuffering stdin LineBuffering
                    hSetEcho stdin True

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

        else do
            let isBombAction = (command == 'b') && not hasActiveBomb
            let isWaitAction = (command == ' ')
            let playerMoved = (destinationTile == Empty) && (intentPos /= playerPos)
            
            if not playerMoved && not isBombAction && not isWaitAction
            then core faseAtual playerPos enemyPos current_map bomb
            else do
                let newPlayerPos = if playerMoved then intentPos else playerPos
                
                let mapAfterPlayer = if playerMoved 
                                     then M.insert newPlayerPos Player (M.insert playerPos Empty current_map)
                                     else current_map
                
                let nextEnemyPos = if hasActiveBomb 
                                   then getSafeStep enemyPos (bomb_x, bomb_y) mapAfterPlayer
                                   else findNextStep enemyPos newPlayerPos mapAfterPlayer
                                   
                let finalEnemyPos = if nextEnemyPos == newPlayerPos 
                                    then pass enemyPos newPlayerPos mapAfterPlayer 
                                    else nextEnemyPos

                let mapSemInimigoVelho = M.insert enemyPos Empty mapAfterPlayer
                let newMapComInimigo = M.insert finalEnemyPos Enemy mapSemInimigoVelho
                
                let (ex, ey) = finalEnemyPos
                let (px, py) = newPlayerPos
                let distToPlayer = abs (ex - px) + abs (ey - py)
                
                let enemyDropsBomb = (distToPlayer <= 2) && not hasActiveBomb && not isBombAction

                let finalBombData = if isBombAction
                                    then Just (BombData newPlayerPos 3)
                                    else if enemyDropsBomb 
                                         then Just (BombData (ex, ey) 3) 
                                         else if hasActiveBomb
                                              then Just (BombData (bomb_x, bomb_y) bombTimer)
                                              else Nothing

                newMapBomb <- handleBomb newPlayerPos newMapComInimigo finalBombData

                core faseAtual newPlayerPos finalEnemyPos newMapBomb finalBombData 

getSafeStep :: Coord -> Coord -> GameMap -> Coord
getSafeStep (ex, ey) (bx, by) mapState =
    let neighbors = [(ex, ey - 1), (ex, ey + 1), (ex - 1, ey), (ex + 1, ey)]
        valid = filter (\pos -> getTile pos mapState == Empty) neighbors
        dist (x, y) = abs (x - bx) + abs (y - by)
        best = foldl (\bestPos currPos -> if dist currPos > dist bestPos then currPos else bestPos) (ex, ey) valid
    in best

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
       else case emptyNeighbors of
                (primeiro:_) -> primeiro   
                []           -> (ex, ey)
