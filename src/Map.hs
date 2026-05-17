module Game.Map 
    ( Tile(..)
    , Coord
    , GameMap
    , loadStaticMap
    , getTile
    ) where

import qualified Data.Map as M
import System.IO

-- Elementos que compõem a estrutura fixa e física do mapa
data Tile = Indestructible | Destructible | Empty
  deriving (Eq, Show)

type Coord = (Int, Int)

type GameMap = M.Map Coord Tile 

assetToMap :: Char -> Tile
assetToMap '#' = Indestructible
assetToMap 'x' = Destructible
assetToMap '.' = Empty        
assetToMap '1' = Empty        
assetToMap '2' = Empty        
assetToMap _   = Empty

loadStaticMap :: FilePath -> IO GameMap
loadStaticMap path = do
    content <- readFile path
    let rows = lines content
        -- Varre todas as linhas e colunas gerando tuplas ((x, y), Tile)
        processedData = do
            (y, row) <- zip [0..] rows
            (x, char)  <- zip [0..] row
            return ((x, y), assetToMap char)
            
    return (M.fromList processedData)

getTile :: Coord -> GameMap -> Tile
getTile coord my_map = M.findWithDefault Indestructible coord my_map