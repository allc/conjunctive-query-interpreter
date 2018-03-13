{
module Token where
}
%wrapper "basic"

$digit = 0-9
$alpha = [a-zA-Z]

tokens :-
  $white+ ;
  "--".*  ;
  select    { \s -> TokenSelect}
  where     { \s -> TokenWhere }
  and       { \s -> TokenAnd }
  \=        { \s -> TokenEq }
  \(        { \s -> TokenLParen}
  \)        { \s -> TokenRParen }
  exists    { \s -> TokenExists }
  in        { \s -> TokenDot }
  [$alpha $digit] [$alpha $digit \_ \’]* { \s -> TokenVarRelation s }

{
data Token =
  TokenSelect     |
  TokenWhere      |
  TokenAnd        |
  TokenEq         |
  TokenLParen     |
  TokenRParen     |
  TokenExists     |
  TokenDot        |
  TokenVarRelation String
  deriving (Eq,Show)
  
}
