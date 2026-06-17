module Config where

escolherFase :: IO Int
escolherFase = do
    putStrLn "===================="
    putStrLn "      BOMBERMAN     "
    putStrLn "===================="
    putStrLn "Escolha uma fase (1-5):"

    entrada <- getLine

    case reads entrada of
        [(fase, "")]
            | fase >= 1 && fase <= 5 -> return fase
        _ -> do
            putStrLn "Fase invalida!"
            escolherFase