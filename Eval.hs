module Eval where

import Grammar
import CsvReader

type Judgement = [[String]]
type Var = String
type RelationSymbol = String
type ConjResult = [[(Var, String)]]

eval :: ExpJudgement -> Judgement
eval (ExpJudgement vs cq) = judge (evalVarList vs) (evalConjQuer cq)

evalVarList :: VarList -> [Var]
evalVarList (ExpVar v) = [v]
evalVarList (ExpVarList v vl) = v : (evalVarList vl)

judge :: [Var] -> ConjResult -> Judgement
judge _ [] = []
judge vl (c:cs) = judgeALine vl c : judge vl cs

-- judgeALine :: [Var] -> [(Var, String)] -> [String]

-- findVar :: Var -> [(Var, String)] -> String
-- findVar _ [] = error "Free variable found"
-- findVar v (l:ls)
  

-- | Evaluation Conjective Query
evalConjQuer :: ConjQuer -> ConjResult
evalConjQuer (ExpRelation r vl) = relation csvData (evalVarList vl)
    where
        csvData = readCsv (r ++ ".csv")

-- | Evaluation helper functions
relation :: CsvData -> [Var] -> ConjResult
relation [] _ = []
relation (d:ds) vl = relationALine d vl : relation ds vl

relationALine :: [String] -> [Var] -> [(Var, String)]
relationALine _ [] = []
relationALine [] (v:vs) = (v, "") : relationALine [] vs
relationALine (s:ss) (v:vs) = (v, s) : relationALine ss vs
