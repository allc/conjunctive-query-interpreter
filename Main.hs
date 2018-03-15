module Main where

import Token
import Grammar
import Eval

import System.Environment
import Data.List
import Data.List.Split
import Control.Monad

main = do
    args <- getArgs
    prog <- readFile (head args)
    let progl = splitOn ";" prog
    run progl

run [] = putStr ""
run (l:ls) | l /= "\n" && l /= [] = do
                result <- sortOnM $ eval $ parse $ alexScanTokens (l)
                putStrLn (formatOut result)
                run ls
           | otherwise = do
                run ls


sortOnM :: (Monad m, Ord a) => m [a] -> m [a]
sortOnM l = liftM sort l

formatOut :: [[String]] -> String
formatOut [] = []
formatOut (l:ls) = formatALine l ++ "\n" ++ formatOut ls

formatALine :: [String] -> String
formatALine [] = []
formatALine (s:[]) = s
formatALine (s:ss) = s ++ "," ++ formatALine ss
