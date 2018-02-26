module Main where

import System.Environment

main = do
    args <- getArgs
    prog <- readFile (head args)
    print prog
