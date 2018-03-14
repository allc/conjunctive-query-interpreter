module Eval where

import Grammar
import CsvReader

type Judgement = IO [[String]]
type Var = String
type RelationSymbol = String
type BoundVar = [Var]
type ConjResult = IO ([[(Var, String)]],BoundVar)

-- test case
-- *Eval> eval (ExpJudgement (ExpVarList "x1" (ExpVar "x2")) (ExpRelation "sample" (ExpVarList "x1" (ExpVar "x2"))))

eval :: Exp -> Judgement
eval (ExpJudgement vs cq) = judge (evalVarList vs) (evalConjQuer cq)

evalVarList :: VarList -> [Var]
evalVarList (ExpVar v) = [v]
evalVarList (ExpVarList v vl) = v : (evalVarList vl)

-- judge method : print the results.
-- judge :: [Var] -> ConjResult -> Judgement
judge' _ [] = []
judge' vl (c:cs) = judgeALine vl c : judge' vl cs

judge vl cq = do 
                cqResults <- cq
                let result = judge' vl (fst cqResults)
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
                                    let result = ((relation csvData a),[])
                                    return result;

-- one of smallest fragments
-- this is useless. ExpEq without previous cq is useless.
-- evalConjQuer (ExpExists s (ExpEq s1 s2)) = ?

-- this one makes sense
evalConjQuer (ExpAnd cq1 (ExpExists s (ExpEq s1 s2))) = do 
                                                            cq1Result <- evalConjQuer cq1
                                                            let oldBoundVarList = snd cq1Result
                                                            let newBoundVarList = s: oldBoundVarList
                                                            let eqResult = evalEq s1 s2 (fst cq1Result)
                                                            let result = (eqResult, newBoundVarList)
                                                            return result; 

evalConjQuer (ExpAnd (ExpExists s cq1) cq2) = do 
                                                cq1Result <- evalConjQuer (ExpExists s cq1)
                                                cq2Result <- evalConjQuer cq2
                                                let boundVarList = snd cq1Result ++ snd cq2Result
                                                let result = (evalAnd (fst cq1Result) (fst cq2Result), boundVarList)
                                                return result;

evalConjQuer (ExpAnd cq1 (ExpExists s cq2)) = do 
                                                cq1Result <- evalConjQuer cq1
                                                cq2Result <- evalConjQuer (ExpExists s cq2)
                                                let boundVarList = snd cq1Result ++ snd cq2Result
                                                let result = (evalAnd (fst cq1Result) (fst cq2Result), boundVarList)
                                                return result;                                    
evalConjQuer (ExpAnd cq1 (ExpEq s1 s2)) = do 
                                             cq1Result <- evalConjQuer cq1
                                             let result = (evalEq s1 s2 (fst cq1Result), snd cq1Result)
                                             return result;   


evalConjQuer (ExpEq s1 s2) = error ("Symbol " ++ s1 ++ ", " ++ s2 ++ " not found in the scope.")

evalConjQuer (ExpAnd cq1 cq2) = do 
                                   cq1Result <- evalConjQuer cq1
                                   cq2Result <- evalConjQuer cq2
                                   let boundVarList = snd cq1Result ++ snd cq2Result
                                   let result = (evalAnd (fst cq1Result) (fst cq2Result), boundVarList)
                                   return result;

-- evalConjQuer (ExpExists s cq) = evalConjQuer cq

-- the other smallest fragements
evalConjQuer (ExpExists s (ExpRelation r vl)) = do 
                                                    relationResult <- evalConjQuer (ExpRelation r vl)
                                                    let oldBoundVarList = snd relationResult
                                                    let newBoundVarList = s:oldBoundVarList
                                                    return (fst relationResult, newBoundVarList);


evalConjQuer (ExpExists s (ExpExists s2 cq)) = do 
                                                  subResult <- evalConjQuer (ExpExists s2 cq)
                                                  let oldBoundVarList = snd subResult
                                                  let newBoundVarList = s : oldBoundVarList
                                                  let result = ((fst subResult), newBoundVarList)
                                                  return result;

evalConjQuer (ExpExists s (ExpAnd cq1 cq2)) = do 
                                                andResult <- evalConjQuer (ExpAnd cq1 cq2)
                                                let oldBoundVarList = snd andResult
                                                let newBoundVarList = s: oldBoundVarList
                                                let result = ((fst andResult), newBoundVarList)
                                                return result;

evalConjQuer (ExpExists _ (ExpEq s1 s2)) = error ("Symbol " ++ s1 ++ ", " ++ s2 ++ " not found in scope.")





-- this case seems impossible, cause the ExpEq should always follow some other expressions to make sense. 
-- evalConjQuer (ExpAnd (ExpEq s1 s2) cq2) = do

-- test case:
-- eval (ExpJudgement (ExpVarList "x1" (ExpVarList "x3" (ExpVarList "x2" (ExpVar "x4")))) (ExpAnd (ExpAnd (ExpRelation "A" (ExpVarList "x1" (ExpVar "x2"))) (ExpRelation "B"
-- (ExpVarList "x3" (ExpVar "x4")))) (ExpEq "x2" "x3")))

evalEq :: Var -> Var -> [[(String, String)]] -> [[(String, String)]]                                             
evalEq s1 s2 b = [x| tuple <- b, s1val<-[(findVar s1 tuple)], s1val/=Nothing, s2val<-[(findVar s2 tuple)], s2val/=Nothing, s1val == s2val, x<-[tuple]]
                                   




-- | Evaluation helper functions
relation :: [[String]] -> [Var] -> [[(Var, String)]]
relation [] _ = []
relation (d:ds) vl = relationALine d vl : relation ds vl

relationALine :: [String] -> [Var] -> [(Var, String)]
relationALine _ [] = []
relationALine [] _ = error ("Bad CSV input, columns do not correspond to the relation")
relationALine (s:ss) (v:vs) = (v, s) : relationALine ss vs

-- evalAnd :: ConjResult -> ConjResult -> ConjResult
evalAnd [] _ = []
evalAnd (cr1:cr1s) cr2s = evalAnd' cr1 cr2s ++ evalAnd cr1s cr2s


-- evalAnd' :: [(Var, String)] -> ConjResult -> ConjResult
evalAnd' _ [] = []
evalAnd' cr1 (cr2:cr2s) | evalAndCheck cr1 cr2 = newConj : evalAnd' cr1 cr2s
                        | otherwise = evalAnd' cr1 cr2s
                        where
                            newConj = (cr1 ++ cr2)

evalAndCheck :: [(Var, String)] -> [(Var, String)] -> Bool
evalAndCheck [] _ = True
evalAndCheck (b1:b1s) b2s = evalAndCheck' b1 b2s && evalAndCheck b1s b2s

evalAndCheck' :: (Var, String) -> [(Var, String)] -> Bool
evalAndCheck' _ [] = True
evalAndCheck' bind@(v, s) b | findVar v b == Nothing = True
                            | otherwise = getVar (findVar v b) == s

-- eval (ExpJudgement (ExpVarList "x1" (ExpVarList "x3" (ExpVarList "x2" (ExpVar "x4")))) (ExpAnd (ExpAnd (ExpRelation "B" (ExpVarList "x1" (ExpVar "x2")))(ExpRelation "A" (ExpVarList "x1" (ExpVar "x2")))) (ExpRelation "B" (ExpVarList "x3" (ExpVar "x4")))))


