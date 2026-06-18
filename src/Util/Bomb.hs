module Util.Bomb where

import Map
import Util.DrawInMap

data BombData = BombData { position :: Coord, timer :: Int }

handleBomb :: Coord -> GameMap -> Maybe BombData -> IO GameMap
handleBomb playerPos current_map (Just (BombData (bomb_x, bomb_y) bombTimer)) = do
    if bombTimer > 0 then
        drawInMap (bomb_x, bomb_y) '●' Indestructible current_map
    else if bombTimer == 0 then do
        explodeBomb (bomb_x, bomb_y) current_map
    else do
        newMap <- cleanExplosion (bomb_x, bomb_y) current_map
        return newMap
handleBomb _ gameMap Nothing = return gameMap

explodeBomb :: Coord -> GameMap -> IO GameMap
explodeBomb (x, y) gameMap = do
    gameMap1 <- drawInMap (x, y) '✶' Explosion gameMap
    gameMap2 <- if getTile (x, y - 1) gameMap == Destructible || getTile (x, y - 1) gameMap == Empty
        then drawInMap (x, y - 1) '✶' Explosion gameMap1
        else return gameMap1
    gameMap3 <- if getTile (x, y + 1) gameMap == Destructible || getTile (x, y + 1) gameMap == Empty
        then drawInMap (x, y + 1) '✶' Explosion gameMap2
        else return gameMap2
    gameMap4 <- if getTile (x - 1, y) gameMap == Destructible || getTile (x - 1, y) gameMap == Empty
        then drawInMap (x - 1, y) '✶' Explosion gameMap3
        else return gameMap3
    gameMap5 <- if getTile (x + 1, y) gameMap == Destructible || getTile (x + 1, y) gameMap == Empty
        then drawInMap (x + 1, y) '✶' Explosion gameMap4
        else return gameMap4
    return gameMap5

cleanExplosion :: Coord -> GameMap -> IO GameMap
cleanExplosion (x, y) gameMap = do
    gameMap1 <- if getTile (x, y) gameMap == Bomb || getTile (x, y) gameMap == Explosion
        then drawInMap (x, y) ' ' Empty gameMap
        else return gameMap
    gameMap2 <- if getTile (x, y - 1) gameMap == Explosion
        then drawInMap (x, y - 1) ' ' Empty gameMap1
        else return gameMap1
    gameMap3 <- if getTile (x, y + 1) gameMap == Explosion
        then drawInMap (x, y + 1) ' ' Empty gameMap2
        else return gameMap2
    gameMap4 <- if getTile (x - 1, y) gameMap == Explosion
        then drawInMap (x - 1, y) ' ' Empty gameMap3
        else return gameMap3
    gameMap5 <- if getTile (x + 1, y) gameMap == Explosion
        then drawInMap (x + 1, y) ' ' Empty gameMap4
        else return gameMap4
    return gameMap5

