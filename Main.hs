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

    let estadoInicial = M.insert initialPosition Player mapaEstatico

    cleanTerminal
    drawMap estadoInicial

    --let initialPosition = (1,1) -- assumindo que sempre começa em 1,1

    drawInMap initialPosition '☻'

    drawInMap (0, 7) ' '
    putStr "Use W, A, S, D + Enter para andar. 'q' + Enter para sair.\nInput: "
    core initialPosition estadoInicial Nothing
