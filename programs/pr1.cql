select x1 x3 x2 x4 where A(x1 x2) and B(x3 x4)

-- ExpJudgement (ExpVarList "x1" (ExpVarList "x3" (ExpVarList "x2" (ExpVar "x4")))) (ExpAnd (ExpRelation "A" (ExpVarList "x1" (ExpVar "x2"))) (ExpRelation "B" (ExpVarList "x3" (ExpVar "x4"))))
