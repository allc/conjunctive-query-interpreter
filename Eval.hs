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
evalVarList (ExpVarSkip 0) = []
evalVarList (ExpVarSkip _) = ["_"]
evalVarList (ExpVarSkipList 0 vl) = evalVarList vl
evalVarList (ExpVarSkipList s vl) = "_" : evalVarList (ExpVarSkipList (s - 1) vl)

-- -- Check all variables are declared either in Existential quantitifer or in the free variable list. 
-- -- need modified, not the final result. 

checkAllVariableDeclared :: [Var] -> [Var] -> Bool
checkAllVariableDeclared [] freeAndBoundVars = True
checkAllVariableDeclared varsUsed@(v:vs) freeAndBoundVars | not(isVarDeclared v freeAndBoundVars) = error ("Variable " ++ v ++ " is not declared")
                                                          | otherwise = checkAllVariableDeclared vs freeAndBoundVars
isVarDeclared :: Var -> [Var] -> Bool                                            
isVarDeclared var freeAndBoundVars = or[boolResult| variable <- freeAndBoundVars, boolResult <- [var == variable]] 

-- function to check whether free var(s) has the same name as one or more bound variables
checkFreeBoundVarNames :: [Var] -> [Var] -> Bool
checkFreeBoundVarNames [] boundVars = True
checkFreeBoundVarNames freeVars@(f:fs) boundVars | checkFreeBoundVarNames' f boundVars = error ("Variable " ++ f ++ " cannot be declared as both the free variable and the bound variable. Please rename.")
                                                 | otherwise = checkFreeBoundVarNames fs boundVars
                                                 
-- return true if found variables having the same name.
-- return false if not.                                                 
checkFreeBoundVarNames' :: Var -> [Var] -> Bool
checkFreeBoundVarNames' free boundVars = or[boolResult | boundVar <- boundVars, boolResult <- [free == boundVar]]


-- judge method : print the results.
judge' :: [Var] -> [[(Var,String)]] -> [[String]]
judge' _ [] = []
judge' vl (c:cs) = judgeALine vl c : judge' vl cs

judge :: [Var] -> ConjResult -> Judgement
judge vl cq = do 
                cqResults <- cq
                let varsUsed = getAllVarFromBinding (fst cqResults)
                -- print varsUsed
                let boundVars = snd cqResults
                -- print boundVars
                let freeAndBoundVars = boundVars ++ vl
                -- print freeAndBoundVars
                let allDeclared = checkAllVariableDeclared varsUsed freeAndBoundVars
                -- print allDeclared
                let freeBoundVarNameOK = checkFreeBoundVarNames vl boundVars
                -- print vl
                -- print boundVars
                let checked = allDeclared && freeBoundVarNameOK 
                let result = judge' vl (fst cqResults)
                -- let result = fst cqResults
                case checked of 
                  True -> return result

judgeALine :: [Var] -> [(Var, String)] -> [String]
judgeALine [] _ = []
judgeALine (v:vs) b = getVar (findVar v b) : judgeALine vs b

getVar :: (String, Maybe String) -> String
getVar (v, Nothing) = error ("Free variable " ++ v ++ " not found.")
getVar (v, (Just s)) = s

findVar :: Var -> [(Var, String)] -> (String, Maybe String)
findVar v [] = (v, Nothing)
findVar v (l:ls) | v == fst l = (v, Just (snd l))
                 | otherwise = findVar v ls


-- | Evaluation Conjective Query
evalConjQuer :: ConjQuer -> ConjResult
evalConjQuer (ExpRelation r vl) = do 
                                    csvData <- readCsv (r ++ ".csv")
                                    let a = evalVarList vl
                                    let result = ((relation csvData a),[])
                                    return result;

-- | And queries: 

-- Design decision: we evaluate the statement from left to right, and Eq uses the result of previous query result. 
-- Thus, it cannot be in the first element of the And operator.
evalConjQuer (ExpAnd (ExpEq s1 s2) _ ) = error "No query result for the Eq operation to be applied on"


evalConjQuer (ExpAnd (ExpExists s cq1) cq2) = do 
                                                -- print "take one shell down 1"
                                                subResult <- evalConjQuer (ExpAnd cq1 cq2)
                                                let oldBoundVarList = snd subResult
                                                -- print "what's going on"

                                                let newList = s: oldBoundVarList 
                                                
                                                let result = ((fst subResult),newList)
                                                
                                                case checkUsedBoundVarName s oldBoundVarList of
                                                  False -> return result
                                                


evalConjQuer (ExpAnd cq1 (ExpExists s cq2)) = do 
                                                -- print "take one shell down 2"
                                                subResult <- evalConjQuer (ExpAnd cq1 cq2)
                                                let oldBoundVarList = snd subResult
                                                let newBoundVarlist = s : oldBoundVarList
                                                let result = ((fst subResult),newBoundVarlist)
                                                -- let boundVarList = snd cq1Result ++ snd cq2Result
                                                -- let result = (evalAnd (fst cq1Result) (fst cq2Result), boundVarList)
                                                case checkUsedBoundVarName s oldBoundVarList of
                                                  
                                                  False -> return result
                                                
                                                                              

evalConjQuer (ExpAnd cq1 (ExpEq s1 s2)) = do 
                                             cq1Result <- evalConjQuer cq1
                                             let result = (evalEq s1 s2 (fst cq1Result), snd cq1Result)
                                             return result;                   


                                                

evalConjQuer (ExpAnd cq1 cq2) = do 
                                  --  print "match the end"
                                   cq1Result <- evalConjQuer cq1

                                   cq2Result <- evalConjQuer cq2

                                   let boundVarList = snd cq1Result ++ snd cq2Result

                                   let result = (evalAnd (fst cq1Result) (fst cq2Result), boundVarList)

                                   return result;

evalConjQuer (ExpExists s (ExpAnd cq1 cq2)) = do 
                                                andResult <- evalConjQuer (ExpAnd cq1 cq2)
                                                let oldBoundVarList = snd andResult
                                                let newBoundVarList = s: oldBoundVarList
                                                let result = ((fst andResult), newBoundVarList)
                                                case checkUsedBoundVarName s oldBoundVarList of
                                            
                                                  False -> return result
                                                

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
                                                  case checkUsedBoundVarName s oldBoundVarList of
                                                    
                                                    False -> return result
                                                  


evalConjQuer (ExpExists _ (ExpEq s1 s2)) = error ("Symbol " ++ s1 ++ ", " ++ s2 ++ " not found in scope.")

evalConjQuer (ExpEq s1 s2) = error ("Symbol " ++ s1 ++ ", " ++ s2 ++ " not found in the scope.")




-- this case seems impossible, cause the ExpEq should always follow some other expressions to make sense. 
-- evalConjQuer (ExpAnd (ExpEq s1 s2) cq2) = do

-- test case:
-- eval (ExpJudgement (ExpVarList "x1" (ExpVarList "x3" (ExpVarList "x2" (ExpVar "x4")))) (ExpAnd (ExpAnd (ExpRelation "A" (ExpVarList "x1" (ExpVar "x2"))) (ExpRelation "B"
-- (ExpVarList "x3" (ExpVar "x4")))) (ExpEq "x2" "x3")))

evalEq :: Var -> Var -> [[(Var, String)]] -> [[(Var, String)]]                                             
evalEq s1 s2 b = [ tuple | tuple <- b, getVar (findVar s1 tuple) == getVar (findVar s2 tuple)]                    

-- | Evaluation helper functions
relation :: [[String]] -> [Var] -> [[(Var, String)]]
relation [] _ = []
relation (d:ds) vl | checkRelationALine rl = rl : relation ds vl
                   | otherwise = relation ds vl
                   where 
                    rl = relationALine d vl

checkRelationALine :: [(Var, String)] -> Bool
checkRelationALine [] = True
checkRelationALine (b:bs) | snd var == Nothing = checkRelationALine bs
                          | getVar var == snd b = checkRelationALine bs
                          | otherwise = False
                          where
                            var = findVar (fst b) bs

relationALine :: [String] -> [Var] -> [(Var, String)]
relationALine _ [] = []
relationALine [] _ = error ("Bad CSV input, columns do not correspond to the relation.")
relationALine (s:ss) (v:vs) | v /= "_" = (v, s) : relationALine ss vs
                            | otherwise = relationALine ss vs

evalAnd ::[[(Var, String)]] -> [[(Var, String)]] -> [[(Var, String)]]
evalAnd [] _ = []
evalAnd (cr1:cr1s) cr2s = evalAnd' cr1 cr2s ++ evalAnd cr1s cr2s


evalAnd' :: [(Var, String)] -> [[(Var, String)]] -> [[(Var, String)]]
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
evalAndCheck' bind@(v, s) b | snd (findVar v b) == Nothing = True
                            | otherwise = getVar (findVar v b) == s



checkUsedVarName :: Var -> [[(Var,String)]] -> Bool
checkUsedVarName var binding = Prelude.length [varName | varName <- getAllVarFromBinding binding ,var == varName] /= 0

-- return True, if the var is already used, otherwise False
checkUsedBoundVarName' :: Var -> [Var] -> Bool
checkUsedBoundVarName' var boundVars = Prelude.length [varName| varName <- boundVars, var == varName] /= 0

checkUsedBoundVarName :: Var -> [Var] -> Bool 
checkUsedBoundVarName var boundVars | checkUsedBoundVarName' var boundVars = error ("The bound variable " ++ var ++ " has already been used in the other exist statement. Please rename it")
                                    | otherwise = False

getAllVarFromBinding :: [[(Var, String)]] -> [Var]
getAllVarFromBinding [] = []
getAllVarFromBinding (b:bs) = getAllVarFromABinding b ++ getAllVarFromBinding bs

getAllVarFromABinding :: [(Var, String)] -> [Var]
getAllVarFromABinding [] = [] 
getAllVarFromABinding (b:bs) = (fst b) : getAllVarFromABinding bs
