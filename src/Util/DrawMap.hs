module Util.DrawMap
    (drawMap
    ) where
            
import qualified Data.Map as M
import Map (Tile(..), GameMap, getTile)

{-
    Autor: João Targino

    Descrição: fornecer as funções necessárias para transformar o mapa gerado no arquivo Map.hs em algo mais visual.
-}

-- aqui, fiz o mapeamento de cada elemento da estrutura para um caracter. dessa forma acredito que ficou bom.
tupleToChar :: Tile -> Char
tupleToChar Indestructible = '█'
tupleToChar Destructible = '░'
tupleToChar Player = '☻'
tupleToChar Victory = '⚑'
tupleToChar Empty = ' '
tupleToChar Bomb = '●'
tupleToChar Explosion = '✶'
tupleToChar Enemy = '☠'


-- essa função verifica as coordenadas do mapa para saber a proporção de desenho na tela, e na sequencia faz o desenho
drawMap :: GameMap -> IO ()
drawMap current_map = do
    let coord = M.keys current_map
        -- descobrindo a largura com x maximo e minimo. dessa forma torna a função escalável se quiser fazer um mapa maior ou alguma outra coisa
        maxX = maximum [x | (x, _) <- coord]
        maxY = maximum [y | (_, y) <- coord]

    -- varre cada posição e faz o mapeamento
    -- obs: essa função varre todo o dicionario, então não seria eficiente redesenhá-lo toda vez que o usuário andar. Por isso, a ideia que eu tive seria implementar a mecanica de movimento fazendo atualizações parciais do mapa
    mapM_ (\y -> do
        mapM_ (\x -> do
            let tile = getTile (x, y) current_map
            putChar (tupleToChar tile)
            ) [0..maxX]
        putStrLn "" -- quebra a linha
        ) [0..maxY]
