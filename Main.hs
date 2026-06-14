module Main where
import GHC.IO.Encoding(setLocaleEncoding, utf8)

import qualified Data.Map as M

import Map
import Util.DrawMap
import Util.DrawInMap
import Util.CleanTerminal
import Core
import System.IO

main :: IO ()
main = do
    setLocaleEncoding utf8
    hSetBuffering stdout NoBuffering
    hSetBuffering stdin LineBuffering
    hSetEcho stdin True


    cleanTerminal

    putStrLn "Carregando a arena de Bomberman..."
    (mapaEstatico, initialPosition) <- loadStaticMap "assets/level1.txt"

    let initialEnemyPosition = (1, 9)

    let mapaComPlayer = M.insert initialPosition Player mapaEstatico
    let estadoInicial = M.insert initialEnemyPosition Enemy mapaComPlayer

    cleanTerminal
    drawMap estadoInicial

    --let initialPosition = (1,1) -- assumindo que sempre começa em 1,1

    _ <- drawInMap initialPosition '☻' Player estadoInicial
    _ <- drawInMap initialEnemyPosition 'E' Enemy estadoInicial

    _ <- drawInMap (0, 7) ' ' Empty estadoInicial
    putStr "Use W, A, S, D + Enter para andar. 'q' + Enter para sair.\nInput: "
    core initialPosition initialEnemyPosition estadoInicial Nothing
