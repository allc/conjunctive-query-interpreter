module Main where

import Token

main = do
    s <- readFile "test.txt"
    print (alexScanTokens s)
