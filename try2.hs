import CsvReader

a = readCsv "sample.csv"
test a = do 
           content <- a
           let x1 = Prelude.head content
           return x1;