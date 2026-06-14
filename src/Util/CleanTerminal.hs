module Util.CleanTerminal
    (cleanTerminal, 
    clearTerminalScrollback
    ) where

{-
    Autor: João Targino

    Descrição: limpa o terminal. simples assim_

-}

cleanTerminal :: IO ()
cleanTerminal = putStr "\x1b[2J\x1b[H"

clearTerminalScrollback :: IO ()
clearTerminalScrollback = putStr "\ESC[3J\ESC[2J\ESC[H"