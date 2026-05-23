module Main where

import Map
import Util.DrawMap
import Util.DrawInMap
import Util.CleanTerminal
import Core
import System.IO

main :: IO ()
main = do
    hSetBuffering stdout NoBuffering
    hSetBuffering stdin LineBuffering
    hSetEcho stdin True


    cleanTerminal

    putStrLn "Carregando a arena de Bomberman..."
    estadoInicial <- loadStaticMap "assets/level1.txt"

    cleanTerminal
    drawMap estadoInicial

    let initialPosition = (1,1) -- assumindo que sempre começa em 1,1

    drawInMap initialPosition '☻'

    drawInMap (0, 7) ' '
    putStr "Use W, A, S, D + Enter para andar. 'q' + Enter para sair.\nInput: "

    core initialPosition estadoInicial