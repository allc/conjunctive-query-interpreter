module Main where

import Token
import Grammar

main = do
    s <- readFile "test.txt"
    print (parse (alexScanTokens s))
