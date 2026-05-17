module Main where

import src.Map

main :: IO ()
main = do
    putStrLn "Carregando a arena de Bomberman..."
    estadoInicial <- carregarMapa "assets/mapa_bomberman.txt"
    
    putStrLn "\n--- Sucesso ao Inicializar ---"
    putStrLn $ "Coordenadas dos Players encontradas: " ++ show (posicoesPlayers estadoInicial)
    
    -- Testando colisões e tipos de bloco na matriz carregada
    putStrLn "\nChecando bloco na coordenada (1,1) [Spawn do Player]:"
    print $ obterTile (1,1) (mapaEstatico estadoInicial) -- Retorna: ChaoVazio
    
    putStrLn "\nChecando bloco na coordenada (2,1) [Tijolo destrutível]:"
    print $ obterTile (2,1) (mapaEstatico estadoInicial) -- Retorna: ParedeDestrutivel