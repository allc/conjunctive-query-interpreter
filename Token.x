{
module Token where
}
%wrapper "posn"

$digit = 0-9
$alpha = [a-zA-Z]

tokens :-
  $white+ ;
  "--".*  ;
  select    { tok (\p s -> TokenSelect p) }
  where     { tok (\p s -> TokenWhere p) }
  and       { tok (\p s -> TokenAnd p) }
  \=        { tok (\p s -> TokenEq p) }
  \(        { tok (\p s -> TokenLParen p) }
  \)        { tok (\p s -> TokenRParen p) }
  exists    { tok (\p s -> TokenExists p) }
  in        { tok (\p s -> TokenDot p) }
  [$alpha $digit] [$alpha $digit \_ \’]* { tok (\p s -> TokenVarRelation p s) }

{
-- Each action has type :: AlexPosn -> String -> Token 
tok f p s = f p s

data Token =
  TokenSelect AlexPosn     |
  TokenWhere AlexPosn      |
  TokenAnd AlexPosn        |
  TokenEq AlexPosn         |
  TokenLParen AlexPosn     |
  TokenRParen AlexPosn     |
  TokenExists AlexPosn     |
  TokenDot AlexPosn        |
  TokenVarRelation AlexPosn String
  deriving (Eq,Show)

tokenPosn :: Token -> AlexPosn
tokenPosn (TokenSelect p) = p
tokenPosn (TokenWhere p) = p
tokenPosn (TokenAnd p) = p
tokenPosn (TokenEq p) = p
tokenPosn (TokenLParen p) = p
tokenPosn (TokenRParen p) = p
tokenPosn (TokenExists p) = p
tokenPosn (TokenDot p) = p
tokenPosn (TokenVarRelation p _) = p

lineNum :: AlexPosn -> Int
lineNum (AlexPn _ n _) = n

colNum :: AlexPosn -> Int
colNum (AlexPn _ _ n) = n

tokenString :: Token -> String
tokenString (TokenSelect _) = "\"select\""
tokenString (TokenWhere _) = "\"where\""
tokenString (TokenAnd _) = "\"and\""
tokenString (TokenEq _) = "\"=\""
tokenString (TokenLParen _) = "\"(\""
tokenString (TokenRParen _) = "\")\""
tokenString (TokenExists _) = "\"exists\""
tokenString (TokenDot _) = "\"in\""
tokenString (TokenVarRelation _ s) = "\"" ++ s ++ "\""
}
