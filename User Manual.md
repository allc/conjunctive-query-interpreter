# {{ cql_name }} User Manual

## 1. Introduction

{{ cql_name }} is a conjunctive query language. The language lets you do conjunctive queries with CSV files.

## 2. Get Started

You can do conjunctive queries with CSV files in the current working directory using {{ cql_name }}.

To run your program, simply go to the directory with your CSV files in the terminal and run the interpreter with your program file as the argument, the following is an example:

```bash
./myinterpreter myquery.cql
```

The result will be outputted to the terminal.

### My first {{ cql_name }} program

To show the data from the A.csv with the following content:

<table>
	<tbody>
		<tr>
			<td>Hello</td><td>World</td>
		</tr>
		<tr>
			<td>Hi</td><td>{{ cql_name }}</td>
		</tr>
	</tbody>
</table>

Write your program with the following line of code:

```cql
select x1 x2 from A(x1 x2);
```

The output is:

```
Hello,World
Hi,{{ cql_name }}
```

## 3. Functionalities

## 4. Features

## Appendix

### 1. Programs

#### Problem 1 - Conjunction
``` cql
select x1 x3 x2 x4 where A(x1 x2) and B(x3 x4);
```

#### Problem 2 - Conjunction and variable repetition
```cql
select x1 x2 x3 where A(x1 x2) and B(x2 x3);
```

#### Problem 3 - Equality
```cql
select x1 x2 where P(x1) and Q(x2) and x1=x2;
```

#### Problem 4 - Existential quantification
```cql
select x1 where exists z in R (x1 z);
```

#### Problem 5 - Existential quantification and conjunction
```cql
select x1 x2 where exists z in A (x1 z) and B (z x2);
```

#### Problem 6 - Check for emptiness
```cql
select x1 where R(x1) and exists z in S(z);
```

#### Problem 7 - Paths of length three
```cql
select x1 x2 where exists z1 in exists z2 in R(x1 z1) and R(z1 z2) and R(z2 x2);
```

#### Problem 8 - Cycles of length 4
```cql
select x1 x2 x3 x4 x5 where R(x1 x2) and R(x2 x3) and R(x3 x4) and R(x4 x5) and x1=x5;
```

#### Problem 9 - Triple composition
```cql
select x1 x2 where exists z1 in exists z2 in A(x1 z1) and B(z1 z2) and C(z2 x2);
```

#### Problem 10 - Check for pairs
```cql
select x1 x2 x3 where S(x1 x2 x3) and exists z1 in exists z2 in S(z1 z1 z2) and exists z3 in exists z4 in S(z3 z4 z4);
```

<hr>

### 2. Language Syntax

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