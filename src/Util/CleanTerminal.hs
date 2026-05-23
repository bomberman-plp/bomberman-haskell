module Util.CleanTerminal
    ( cleanTerminal
    )where

{-
    Autor: João Targino

    Descrição: limpa o terminal. simples assim_

-}

cleanTerminal :: IO ()
cleanTerminal = putStr "\x1b[2J\x1b[H"