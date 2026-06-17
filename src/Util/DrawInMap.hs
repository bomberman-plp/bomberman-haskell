module Util.DrawInMap where

import qualified Data.Map as M
import Map


drawInMap :: Coord -> Char -> Tile -> GameMap -> IO GameMap
drawInMap (x,y) c tile gameMap = do
    -- aparentemente o terminal conta a partir de 1, não de 0. então sempre tem que somar +1 nos valores de X e Y
    putStr $ "\x1b[" ++ show (y + 1) ++ ";" ++ show (x + 1) ++ "H"
    putChar c
    let newMap = M.insert (x,y) tile gameMap
    return newMap



