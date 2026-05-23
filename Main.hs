module Main where

import Map
import Util.DrawMap

main :: IO ()
main = do
    putStrLn "Carregando a arena de Bomberman..."
    estadoInicial <- loadStaticMap "assets/level1.txt"
    
    putStrLn "\n--- Sucesso ao Inicializar ---"
    drawMap estadoInicial