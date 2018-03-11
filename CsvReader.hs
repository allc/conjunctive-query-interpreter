module CsvReader where

import Data.Char
import Data.Text

type CsvData = [[String]]

-- task4
-- TO-DO: need to handel empty entry
filePath = "C:/study backup/CS/Y2S2/Programming Language Concepts/new_labs/lab1/test.txt"


-- get rid of all spaces first 
clearSpace [] = []
clearSpace (s:ss) | s == ' ' = clearSpace ss
                  | otherwise = s : clearSpace ss

readAnEntry :: String -> String
readAnEntry [] = [] 
readAnEntry (s:ss) | s == ',' = []
                   | otherwise = unpack $ strip $ pack (s : readAnEntry ss)

readALine :: String -> Int -> [String]
readALine ss startIndex | startIndex >= Prelude.length ss = []
                        | otherwise =  list1 : readALine ss (startIndex+(Prelude.length list1)+1)
                            where list1 = readAnEntry (Prelude.drop startIndex ss)

-- readFile writeFile
-- multiZipF = do
--                 content <- readFile filePath
--                 let numLines = lines content
--                 let result = [num| x<-numLines, num <- [readALine (clearSpace x) 0]]
--                 --let result = readALine (clearSpace content) 0 
--                 putStrLn "done"
--                 return "";
            
-- file format
--1,2,3,        7, 89,   212321
--123

readCsv :: String -> CsvData
readCsv f = [["Pawel", "Sobocinski"], ["Alice", "Bob"]]
