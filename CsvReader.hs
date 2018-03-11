module CsvReader where

import Data.Char
import Data.Text

type CsvData = [[String]]

-- task4
-- TO-DO: need to handel empty entry


-- get rid of all spaces first 
clearSpace [] = []
clearSpace (s:ss) | s == ' ' = clearSpace ss
                  | otherwise = s : clearSpace ss

readAnEntry :: String -> String
readAnEntry [] = [] 
readAnEntry (s:ss) | s == ',' = []
                   | otherwise = s : readAnEntry ss

readALine :: String -> Int -> [String]
readALine ss startIndex | startIndex >= Prelude.length ss = []
                        | otherwise =  stringWithoutSpace : readALine ss (startIndex+(Prelude.length stringWithSpace)+1)
                            where stringWithoutSpace = unpack $ strip $ pack $ readAnEntry (Prelude.drop startIndex ss)
                                  stringWithSpace = readAnEntry (Prelude.drop startIndex ss)
                                  
                                  
                                  

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

--readCsv :: String -> CsvData
readCsv f = do
    content <- readFile f
    --let result = [num| x<-numLines, num <- [readALine (clearSpace x) 0]]
    print content
