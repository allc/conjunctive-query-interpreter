import CsvReader
import System.Directory
import System.FilePath.Posix
main = do 
        files <- getDirectoryContents "."
        let allCsv = findAllCsv files
        return allCsv;

findAllCsv [] = [] 
findAllCsv (file:files) | takeExtension file == ".csv" = file: findAllCsv files
                        | otherwise = findAllCsv files