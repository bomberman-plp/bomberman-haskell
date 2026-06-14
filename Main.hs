module Main where
import GHC.IO.Encoding(setLocaleEncoding, utf8)
import Control.Concurrent (threadDelay)

import qualified Data.Map as M

import Map
import Util.DrawMap
import Util.DrawInMap
import Util.CleanTerminal
import Core
import System.IO
import Home_Screen

main :: IO ()
main = do
    setLocaleEncoding utf8
    hSetBuffering stdout NoBuffering
    hSetBuffering stdin LineBuffering
    hSetEcho stdin True

    telaInicial
    cleanTerminal
    putStrLn "Carregando a arena de Bomberman..."
    
    hFlush stdout
    threadDelay 2000000  -- 2 segundos

    (mapaEstatico, initialPosition) <- loadStaticMap "assets/level1.txt"

    let initialEnemyPosition = (1, 9)

    let mapaComPlayer = M.insert initialPosition Player mapaEstatico
    let estadoInicial = M.insert initialEnemyPosition Enemy mapaComPlayer
    
    cleanTerminal
    drawMap estadoInicial

    _ <- drawInMap initialPosition '☻' Player estadoInicial
    _ <- drawInMap initialEnemyPosition 'E' Enemy estadoInicial

    _ <- drawInMap (0, 11) ' ' Empty estadoInicial
    putStr "Use W, A, S, D + Enter para andar. 'q' + Enter para sair.\nInput: "
    core 1 initialPosition initialEnemyPosition estadoInicial Nothing
