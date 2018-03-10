module Eval where

import Grammar
import CsvReader

type Judgement = [[String]]
type Var = String
type RelationSymbol = String
type ConjResult = [(Var, String)]

--eval :: ExpJudgement -> Judgement
--eval (ExpJudgement vs cq) = somefunction (evalVarList vs) (evalConjQuer cq)

evalVarList :: VarList -> [Var]
evalVarList (ExpVar v) = [v]
evalVarList (ExpVarList v vl) = v : (evalVarList vl)

-- evalConjQuer :: ConjQuer -> ConjResult
-- evalConjQuer (ExpRelation r vl) = relation csvData vl
--     where
--         csvData = readCsv (r ++ ".csv")

--relation :: CsvData -> VarList -> ConjResult

