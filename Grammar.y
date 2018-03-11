{
module Grammar where
import Token
}

%name parse
%tokentype { Token }
%error { parseError }
%token
  where  { TokenWhere }
  '^'    { TokenAnd }
  '='    { TokenEq }
  '('    { TokenLParen }
  ')'    { TokenRParen }
  exists { TokenExists }
  '.'    { TokenDot }
  varRelation { TokenVarRelation $$ }

%left '^'
%right '.'
%%
Exp : VarList where ConjQuer { ExpJudgement $1 $3 }
VarList : varRelation         { ExpVar $1 }
        | varRelation VarList { ExpVarList $1 $2 }
ConjQuer : ConjQuer '^' ConjQuer           { ExpAnd $1 $3 }
         | varRelation '=' varRelation     { ExpEq $1 $3 }
         | varRelation '(' VarList ')'     { ExpRelation $1 $3 }
         | exists varRelation '.' ConjQuer { ExpExists $2 $4 }

{
parseError :: [Token] -> a
parseError t = error "error"
data Exp = ExpJudgement VarList ConjQuer
         deriving Show
data VarList = ExpVar String
             | ExpVarList String VarList
             deriving Show
data ConjQuer = ExpAnd ConjQuer ConjQuer
              | ExpEq String String
              | ExpRelation String VarList
              | ExpExists String ConjQuer
              deriving Show
}
