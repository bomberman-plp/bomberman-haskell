module Util.CleanTerminal
    (cleanTerminal, 
    clearTerminalScrollback,
    clearAll
    ) where

import System.Process (callCommand)
import System.Info (os)


cleanTerminal :: IO ()
cleanTerminal = putStr "\x1b[2J\x1b[H"

clearTerminalScrollback :: IO ()
clearTerminalScrollback = putStr "\ESC[3J\ESC[2J\ESC[H"

clearAll :: IO ()
clearAll = if os == "mingw32" || os == "windows"
        then callCommand "cls"   -- Comando do Windows
        else callCommand "clear" -- Comando do Linux / macOS