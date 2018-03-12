module Main where

import Token
import Grammar
import Eval

import System.Environment

main = do
    args <- getArgs
    prog <- readFile (head args)
    print (eval $ parse $ alexScanTokens prog)
