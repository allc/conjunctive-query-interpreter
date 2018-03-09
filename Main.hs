module Main where

import Token
import Grammar

import System.Environment

main = do
    args <- getArgs
    prog <- readFile (head args)
    print (parse (alexScanTokens prog))
