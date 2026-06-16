module Home_Screen where

import System.IO (hFlush, stdout, readFile')
import System.Exit (exitSuccess)
import Util.CleanTerminal


telaInicial :: IO ()
telaInicial = do
    cleanTerminal
    conteudoMenu <- readFile' "assets/home_screen.txt"
    putStr conteudoMenu
    hFlush stdout

    opcao <- getLine

    if opcao == "1" then do
        clearAll
        return ()
    else if opcao == "2" then do
        clearAll
        putStrLn "Obrigado por jogar Bomberman Reborn! Até logo."
        exitSuccess
    else do
        putStrLn "\n[!] Opção inválida! Pressione Enter para tentar novamente..."
        _ <- getLine
        telaInicial