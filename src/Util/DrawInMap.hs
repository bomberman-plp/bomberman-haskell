module Util.DrawInMap where

import qualified Data.Map as M
import Map

{-
    Autor: João Targino

    Descrição: dada a coordenada e o caractere, desenha no mapa. pode ser reaproveitada para bombas

-}

drawInMap :: Coord -> Char -> IO()
drawInMap (x,y) c = do
    -- aparentemente o terminal conta a partir de 1, não de 0. então sempre tem que somar +1 nos valores de X e Y
    putStr $ "\x1b[" ++ show (y + 1) ++ ";" ++ show (x + 1) ++ "H"
    putChar c