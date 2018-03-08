{
module Main where
}
%wrapper "basic"

$digit = 0-9
$alpha = [a-zA-Z]

tokens :-
  $white+ ;
  "--".*  ;
  where     { \s -> TokenWhere }
  \^        { \s -> TokenAnd }
  \=        { \s -> TokenEq }
  \(        { \s -> TokenLParen}
  \)        { \s -> TokenRParen }
  exists    { \s -> TokenExists }
  \.        { \s -> TokenDot }
  [$alpha $digit] [$alpha $digit \_ \’]* { \s -> TokenVarRelation s }

{
data Token =
  TokenWhere      |
  TokenAnd        |
  TokenEq         |
  TokenLParen     |
  TokenRParen     |
  TokenExists     |
  TokenDot        |
  TokenVarRelation String
  deriving (Eq,Show)

main = do
  s <- readFile "test.txt"
  print (alexScanTokens s)
  
}
