module Eval where

import Grammar
import CsvReader

type Judgement = IO [[String]]
type Var = String
type RelationSymbol = String
type ConjResult = IO [[(Var, String)]]

-- test case
-- *Eval> eval (ExpJudgement (ExpVarList "x1" (ExpVar "x2")) (ExpRelation "sample" (ExpVarList "x1" (ExpVar "x2"))))

eval :: Exp -> Judgement
eval (ExpJudgement vs cq) = judge (evalVarList vs) (evalConjQuer cq)

evalVarList :: VarList -> [Var]
evalVarList (ExpVar v) = [v]
evalVarList (ExpVarList v vl) = v : (evalVarList vl)

-- judge method : print the results.
judge :: [Var] -> ConjResult -> Judgement
judge' _ [] = []
judge' vl (c:cs) = judgeALine vl c : judge' vl cs

judge vl cq = do 
                cqResults <- cq
                let result = judge' vl cqResults
                return result;  

judgeALine :: [Var] -> [(Var, String)] -> [String]
judgeALine [] _ = []
judgeALine (v:vs) b = getVar (findVar v b) : judgeALine vs b

getVar :: Maybe String -> String
getVar Nothing = error "Free variable found"
getVar (Just s) = s

findVar :: Var -> [(Var, String)] -> Maybe String
findVar _ [] = Nothing
findVar v (l:ls) | v == fst l = Just (snd l)
                 | otherwise = findVar v ls

-- | Evaluation Conjective Query
evalConjQuer :: ConjQuer -> ConjResult
evalConjQuer (ExpRelation r vl) = do 
                                    csvData <- readCsv (r ++ ".csv")
                                    let a = evalVarList vl
                                    let result = relation csvData a
                                    return result;
    

-- evalConjQuer (ExpAnd cq1 cq2) = evalAnd (evalConjQuer cq1) (evalConjQuer cq2)

-- | Evaluation helper functions
relation :: [[String]] -> [Var] -> [[(Var, String)]]
relation [] _ = []
relation (d:ds) vl = relationALine d vl : relation ds vl

relationALine :: [String] -> [Var] -> [(Var, String)]
relationALine _ [] = []
relationALine [] (v:vs) = (v, "") : relationALine [] vs
relationALine (s:ss) (v:vs) = (v, s) : relationALine ss vs

-- evalAnd :: ConjResult -> ConjResult -> ConjResult
-- evalAnd [] _ = []
-- evalAnd (cr1:cr1s) cr2s = evalAnd' cr1 cr2s ++ evalAnd cr1s cr2s

-- evalAnd' :: [(Var, String)] -> ConjResult -> ConjResult
-- evalAnd' _ [] = []
-- evalAnd' cr1 (cr2:cr2s) | evalAndCheck cr1 cr2 = newConj : evalAnd' cr1 cr2s
--                         | otherwise = evalAnd' cr1 cr2s
--                         where
--                             newConj = (cr1 ++ cr2)

-- evalAndCheck :: [(Var, String)] -> [(Var, String)] -> Bool
-- evalAndCheck [] _ = True
-- evalAndCheck (b1:b1s) b2s = evalAndCheck' b1 b2s && evalAndCheck b1s b2s

-- evalAndCheck' :: (Var, String) -> [(Var, String)] -> Bool
-- evalAndCheck' _ [] = True
-- evalAndCheck' bind@(v, s) b | findVar v b == Nothing = True
--                             | otherwise = getVar (findVar v b) == s
