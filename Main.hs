module Main where
import GHC.IO.Encoding(setLocaleEncoding, utf8)
import System.Process (callCommand)
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
    callCommand "clear"
    putStrLn "Carregando a arena de Bomberman..."
    
    hFlush stdout
    threadDelay 2000000  -- 2 segundos

    (mapaEstatico, initialPosition) <- loadStaticMap "assets/level1.txt"

    let estadoInicial = M.insert initialPosition Player mapaEstatico
    callCommand "clear"
    drawMap estadoInicial

    --let initialPosition = (1,1) -- assumindo que sempre começa em 1,1

    _ <- drawInMap initialPosition '☻' Player estadoInicial

    _ <- drawInMap (0, 11) ' ' Empty estadoInicial
    putStr "Use W, A, S, D + Enter para andar. 'q' + Enter para sair.\nInput: "
    core 1 initialPosition estadoInicial Nothing
