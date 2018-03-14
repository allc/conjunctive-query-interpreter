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

-- eval :: Exp -> Judgement
-- eval (ExpJudgement vs cq) = judge (evalVarList vs) (evalConjQuer cq)

evalVarList :: VarList -> [Var]
evalVarList (ExpVar v) = [v]
evalVarList (ExpVarList v vl) = v : (evalVarList vl)

-- -- Check all variables are declared either in Existential quantitifer or in the free variable list. 
-- -- need modified, not the final result. 
checkAllVariableDeclared varsUsed freeAndBoundVars = and[boolResult| var <- varsUsed ,boolResult <- [isVarDeclared var freeAndBoundVars]]

isVarDeclared var freeAndBoundVars = or[boolResult| variable <- freeAndBoundVars, boolResult <- [var == variable]] 

-- judge method : print the results.
-- judge :: [Var] -> ConjResult -> Judgement
judge' :: [Var] -> [[(Var,String)]] -> [[String]]
judge' _ [] = []
judge' vl (c:cs) = judgeALine vl c : judge' vl cs

judge vl cq = do 
                cqResults <- cq
                let varsUsed = getAllVarFromBinding (fst cqResults)
                print varsUsed
                let boundVars = snd cqResults
                print boundVars
                let freeAndBoundVars = boundVars ++ vl
                print freeAndBoundVars
                let allDeclared = checkAllVariableDeclared varsUsed freeAndBoundVars
                print allDeclared
                let result = judge' vl (fst cqResults)
                -- let result = fst cqResults
                return boundVars;  

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
relationALine [] (v:vs) = (v, "") : relationALine [] vs
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

-- rename the redundant variable in nested exist statements

tryRename :: Var -> [[(Var,String)]] -> [Var] -> ([[(Var,String)]],[Var])
tryRename var binding boundVarList | checkUsedVarName var binding = ((renameBinding var newName binding), (renameBoundVarList var newName boundVarList))
                                   | otherwise = (binding, boundVarList)
                                      where newName = getANewVarName var binding


-- rename the bound variable list
renameBoundVarList :: Var -> Var ->[Var] -> [Var]
renameBoundVarList oldName newName [] = []
renameBoundVarList oldName newName boundVarList@(v:vs) | v == oldName = newName : renameBoundVarList oldName newName vs
                                                       | otherwise = v: (renameBoundVarList oldName newName vs)


-- rename the bindings    
renameBinding :: Var -> Var -> [[(Var,String)]] -> [[(Var,String)]]
renameBinding _ _ [] = []
renameBinding oldName newName bindingList@(bl:bls) = (renameABinding oldName newName bl) : renameBinding oldName newName bls 

renameABinding :: Var -> Var -> [(Var,String)] -> [(Var,String)]
renameABinding oldName newName [] = []
renameABinding oldName newName binding@(b:bs) | (fst b) == oldName = (newName, snd b) : (renameABinding oldName newName bs)
                                              | otherwise  = (fst b, snd b): (renameABinding oldName newName bs)     
                                   
-- -- Warning: potential overhead, repeated bound variables in the list. 
getANewVarName var binding | checkUsedVarName (var ++ "'") binding  = getANewVarName (var ++ "'") binding
                           | otherwise = var ++ "'"    

-- -- return true if there is a varibale with same name, otherwise return false.
checkUsedVarName :: Var -> [[(Var,String)]] -> Bool
checkUsedVarName var binding = Prelude.length [varName | varName <- getAllVarFromBinding binding ,var == varName] /= 0

getAllVarFromBinding :: [[(Var, String)]] -> [Var]
getAllVarFromBinding [] = []
getAllVarFromBinding (b:bs) = getAllVarFromABinding b ++ getAllVarFromBinding bs

getAllVarFromABinding :: [(Var, String)] -> [Var]
getAllVarFromABinding [] = [] 
getAllVarFromABinding (b:bs) = (fst b) : getAllVarFromABinding bs
