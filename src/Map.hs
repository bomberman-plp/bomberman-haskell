module Map 
    ( Tile(..)
    , Coord
    , GameMap
    , loadStaticMap
    , getTile
    ) where

import qualified Data.Map as M
import System.IO

-- Elementos que compõem a estrutura fixa e física do mapa
data Tile = Indestructible | Destructible | Empty | Player
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

startPos_player :: [[Char]] -> (Int, Int)
startPos_player rows = percorrerMatriz rows 0 0
    where
        percorrerMatriz [] _ _ = (1,1)
        percorrerMatriz (row:rest) x y = 
            if percorrerLinha row x y /= Nothing
                then
                    let Just (acheiX, acheiY) = percorrerLinha row x y 
                    in (acheiX, acheiY)
                else
                    percorrerMatriz rest 0 (y + 1)

        percorrerLinha :: [Char] -> Int -> Int -> Maybe (Int, Int)
        percorrerLinha [] _ _ = Nothing
        percorrerLinha (char:chars) x y =
            if char == '1'
                then Just (x,y)
                else percorrerLinha chars (x + 1) y

loadStaticMap :: FilePath -> IO (GameMap, Coord)
loadStaticMap path = do
    content <- readFile path
    let rows = lines content

        startPos = startPos_player rows

        -- Varre todas as linhas e colunas gerando tuplas ((x, y), Tile)
        processedData = do
            (y, row) <- zip [0..] rows
            (x, char)  <- zip [0..] row
            return ((x, y), assetToMap char)
            
    return (M.fromList processedData, startPos)

getTile :: Coord -> GameMap -> Tile
getTile coord my_map = M.findWithDefault Indestructible coord my_map