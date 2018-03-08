import Data.Char

-- task4
-- TO-DO: need to handel empty entry
filePath = "C:/study backup/CS/Y2S2/Programming Language Concepts/new_labs/lab1/test.txt"


-- get rid of all spaces first 
clearSpace [] = []
clearSpace (s:ss) | s == ' ' = clearSpace ss
                  | otherwise = s : clearSpace ss


readANumber [] = [] 
readANumber (s:ss) | s == ',' = []
                   | isNumber s = s : readANumber ss
                   | otherwise = error "bad format of the file. Exists non integer value."


readALine ss startIndex | startIndex >= length ss = []
                        | otherwise =  list1 : readALine ss (startIndex+(length list1)+1)
                            where list1 = readANumber (drop startIndex ss)

-- readFile writeFile
multiZipF = do
                content <- readFile filePath
                let numLines = lines content
                let result = [num| x<-numLines, num <- [readALine (clearSpace x) 0]]
                --let result = readALine (clearSpace content) 0 
                putStrLn "done"
                return "";
            
-- file format
--1,2,3,        7, 89,   212321
--123