{
module Grammar where
import Token
}

%name parse
%tokentype { Token }
%error { parseError }
%token
  select { TokenSelect _ }
  where  { TokenWhere _ }
  '^'    { TokenAnd _ }
  '='    { TokenEq _ }
  '('    { TokenLParen _ }
  ')'    { TokenRParen _ }
  exists { TokenExists _ }
  in     { TokenIn _ }
  varRelation { TokenVarRelation _ $$ }
  varSkip { TokenVarSkip _ $$ }

%left '^'
%right in
%%
Exp : select VarList where ConjQuer { ExpJudgement $2 $4 }
VarList : varRelation         { ExpVar $1 }
        | varSkip             { ExpVarSkip $1 }
        | varRelation VarList { ExpVarList $1 $2 }
        | varSkip VarList     { ExpVarSkipList $1 $2 }
ConjQuer : ConjQuer '^' ConjQuer           { ExpAnd $1 $3 }
         | varRelation '=' varRelation     { ExpEq $1 $3 }
         | varRelation '(' VarList ')'     { ExpRelation $1 $3 }
         | exists varRelation in ConjQuer { ExpExists $2 $4 }

{
parseError :: [Token] -> a
parseError t = error ("Parsing error at " ++ (tokenMessage (head t)))
data Exp = ExpJudgement VarList ConjQuer
         deriving Show
data VarList = ExpVar String
             | ExpVarSkip Int
             | ExpVarList String VarList
             | ExpVarSkipList Int VarList 
             deriving Show
data ConjQuer = ExpAnd ConjQuer ConjQuer
              | ExpEq String String
              | ExpRelation String VarList
              | ExpExists String ConjQuer
              deriving Show

tokenMessage :: Token -> String
tokenMessage t = "line " ++ (show $ lineNum $ tokenPn) ++ " column " ++ (show $colNum $ tokenPn) ++ " " ++ tokenStr
  where
    tokenPn = tokenPosn t
    tokenStr = tokenString t
}
