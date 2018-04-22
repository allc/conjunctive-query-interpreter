# conjunctive query interpreter

## How to Compile
```
make
```
optional:

```
make clean
```

## How to Run
```
./myinterpreter program_filename
```

## Imported Packages
- System.Environment
- Data.List
- Control.Monad
- Data.Text *
- Data.List.Split *

(*) package not in the default installation

## Language Syntax
```
             <expr> ::= select <var-list> where <conjunctive-query>
         <var-list> ::= <var>
                      | <var-skip>
                      | <var> <var-list>
                      | <var-skip> <var-list>
<conjunctive-query> ::= <conjunctive-query> ^ <conjunctive-query>
                      | <var> = <var>
                      | <relation-symbol> ( <var-list> )
                      | exists <var> in <conjunctive-query>
              <var> ::= <identifier>
         <var-skip> ::= _<digits>
  <relation-symbol> ::= <identifier>
           <digits> ::= <digit> | <digit><digits>
            <digit> ::= [0-9]
       <identifier> ::= <alpha><identifier>
                      | <digit><identifier>
                      | <alpha>_<identifier>
                      | <digit>_<identifier>
            <alpha> ::= [a-zA-Z]
```
