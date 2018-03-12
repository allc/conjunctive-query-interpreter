module Eval where

import Grammar
import CsvReader

type Judgement = [[String]]
type Var = String
type RelationSymbol = String
type ConjResult = [[(Var, String)]]

eval :: Exp -> Judgement
eval (ExpJudgement vs cq) = judge (evalVarList vs) (evalConjQuer cq)

evalVarList :: VarList -> [Var]
evalVarList (ExpVar v) = [v]
evalVarList (ExpVarList v vl) = v : (evalVarList vl)

judge :: [Var] -> ConjResult -> Judgement
judge _ [] = []
judge vl (c:cs) = judgeALine vl c : judge vl cs

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
evalConjQuer (ExpRelation r vl) = relation csvData (evalVarList vl)
    where
        csvData = readCsv (r ++ ".csv")

evalConjQuer (ExpAnd cq1 cq2) = evalAnd (evalConjQuer cq1) (evalConjQuer cq2)

-- | Evaluation helper functions
relation :: CsvData -> [Var] -> ConjResult
relation [] _ = []
relation (d:ds) vl = relationALine d vl : relation ds vl

relationALine :: [String] -> [Var] -> [(Var, String)]
relationALine _ [] = []
relationALine [] (v:vs) = (v, "") : relationALine [] vs
relationALine (s:ss) (v:vs) = (v, s) : relationALine ss vs

evalAnd :: ConjResult -> ConjResult -> ConjResult
evalAnd [] _ = []
evalAnd (cr1:cr1s) cr2s = evalAnd' cr1 cr2s ++ evalAnd cr1s cr2s

evalAnd' :: [(Var, String)] -> ConjResult -> ConjResult
evalAnd' _ [] = []
evalAnd' cr1 (cr2:cr2s) | evalAndCheck newConj = newConj : evalAnd' cr1 cr2s
                        | otherwise = newConj : evalAnd' cr1 cr2s
                        where
                            newConj = (cr1 ++ cr2)

evalAndCheck :: [(Var, String)] -> [(Var, String)] -> Bool
evalAndCheck [] _ = True
evalAndCheck (b1:b1s) b2s = evalAndCheck' b1 b2s && evalAndCheck b1s b2s

evalAndCheck' :: (Var, String) -> [(Var, String)] -> Bool
evalAndCheck' _ [] = True
evalAndCheck' bind@(v, s) b | findVar v b == Nothing = True
                            | otherwise = getVar (findVar v b) == s
