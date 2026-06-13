module Util.Elimination where
import Map
import Util.CleanTerminal
import System.Exit (exitSuccess)
import Control.Concurrent (threadDelay)

checkElimination :: Coord -> Coord -> Int -> IO ()
checkElimination posicaoTestada (bomb_x, bomb_y) bombTimer = do
    if bombTimer == 0
    then do
        let explosionArea = [(bomb_x, bomb_y), (bomb_x, bomb_y - 1), (bomb_x, bomb_y + 1), (bomb_x - 1, bomb_y), (bomb_x + 1, bomb_y)]
        if posicaoTestada `elem` explosionArea
        then do
            Control.Concurrent.threadDelay 2000000 -- Tempo para ver a explosão na tela
            cleanTerminal
            putStrLn "========================================="
            putStrLn "💥 BOOM! Você foi pego pela explosão! 💥"
            putStrLn "                GAME OVER                "
            putStrLn "========================================="
            Control.Concurrent.threadDelay 3000000 
            cleanTerminal
            exitSuccess 
        else return ()
    else return ()