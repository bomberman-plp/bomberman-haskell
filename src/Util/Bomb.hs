module Util.Bomb where

import Map
import Util.DrawInMap

data Bomb = Bomb { position :: Coord, timer :: Int }

{--}

handleBomb :: Coord -> GameMap -> Maybe Bomb -> IO ()
handleBomb playerPos current_map (Just (Bomb (bomb_x, bomb_y) bombTimer)) = do
    if bombTimer > 0 then
        drawInMap (bomb_x, bomb_y) '●'
    else if bombTimer == 0 then do
        explodeBomb (bomb_x, bomb_y) current_map
    else
        return ()
handleBomb _ _ Nothing = return ()

explodeBomb :: Coord -> GameMap -> IO ()
explodeBomb (x, y) gameMap = do
    drawInMap (x, y) '✶'
    if getTile (x, y - 1) gameMap == Destructible || getTile (x, y - 1) gameMap == Empty then
        drawInMap (x, y - 1) '✶'
    else
        return ()
    if getTile (x, y + 1) gameMap == Destructible || getTile (x, y + 1) gameMap == Empty then
        drawInMap (x, y + 1) '✶'
    else
        return ()
    if getTile (x - 1, y) gameMap == Destructible || getTile (x - 1, y) gameMap == Empty then
        drawInMap (x - 1, y) '✶'
    else
        return ()
    if getTile (x + 1, y) gameMap == Destructible || getTile (x + 1, y) gameMap == Empty then
        drawInMap (x + 1, y) '✶'
    else
        return ()
    
