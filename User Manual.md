<style>
P {
	margin: 5px;
	clear: both;
}
pre {
	margin: 5px;
}
table {
	margin: 0 10px 0 0;
}
</style>
# {{ cql_name }} User Manual

## 1. Introduction

{{ cql_name }} is a conjunctive query language which is mainly used to enquire specific data from local CSV files. This language is evaluated from the most inner to the most outer and from left to right (there is a specific word for it). Also, the results of queries will be outputted in lexicographical order. This user manual will help you to learn how to write queries in this language.

## 2. Get Started


In this section, we will introduce the syntax of our language to the reader.

To examine the detailed syntax tree, please go to Appendix 2

1. **Hello world and use interpreter in command line**

To run your program, simply open the terminal in the directory which holds the interpreter and the CSV files and run the interpreter with your program file (.cql) as an argument.

For example:

```bash
./myinterpreter myquery.cql
```

> Note: CSV files must be placed in the terminal’s current working directory.

The first example program is to show the data from the **A.csv** with the following content:
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

Create a new **HelloWorld.cql** file, and write your program as following: 

```cql
select x1 x2 where A(x1 x2);
```

Run your program and the output is:

```
Hello,World
Hi,{{ cql_name }}
```

In the program, there are two expressions `select x1 x2 where` and `A(x1 x2)` that you might not be familiar with. The next section will introduce them to you.

2. **Simple select-where statement**

   The definition of this type of statements is: `select [var_list] where [conjunctive_query]`

## 3. Features

1. Comment
   - You can have single line comments begin with `--`
   
     e.g. `-- This is a single line comment`
     
2. Multiple queries in one program file
   - You can have multiple queries in one program file, and the output results would be separated by empty lines.
3. Error handling and informative error message
   - See Appendix 3 for details
4. Support syntax highlighting
   - Syntax of {{ cql_name }} is similar to SQL, and compatible with SQL syntax highlighting
   - Also provide TextMate language grammar json file in Appendix 4, which can be used in many editors such as TextMate, Visual Studio Code and Sublime Text to support syntax highlighting of {{ cql_name }}
5. Skip columns in relations
   - You can use `_[number of variables to be skipped]` to skip columns, so that, you do not have to create variables for columns that you do not need.

     Example:
     
     A.csv with the following content:
<table>
	<tbody>
		<tr>
			<td>1</td><td>2</td><td>3</td>
		</tr>
	</tbody>
</table>

		```cql
		select x1 where A(_2 x1);
		```
	
		Output:
	
		```
		3
		```

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
             <expr> ::= select <var-list> where <conjunctive-query> ;
         <var-list> ::= <var>
                      | <var-skip>
                      | <var> <var-list>
                      | <var-skip> <var-list>
<conjunctive-query> ::= <conjunctive-query> and <conjunctive-query>
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

<hr>

### 3. Error messages

##### 3.1 Parsing error shows the position of the token

Example:

`from` is not a key word, so it is parsed as a variable, then `(` is an unexpected token

```cql
select x1 x2 from A(x1 x2);
```

Error message:

```
Parsing error at line 1 column 20 "("
```

##### 3.2 Compiling time error

- Using already taken bound variable names

  Example:
  
  Program with z1 appears in 2 bound variables:
  
  ```cql
  select x1 x2 where A(x1 x2) and exists z1 in exists z1 in B(z1);
  ```
  
  Error message:
  
  ```
  The bound variable z1 has already been used in the other exist statement. Please rename it
  ```
    
- Selecting a variable that does not exist in any relation

  Example:
  
  Program with x3 not in any relation:
  
  ```cql
  select x1 x2 x3 where A(x1 x2);
  ```
  
  Error message:
  
  ```
  Free variable x3 not found.
  ```
  
- Using a variable that is not declared as either a free or bound variable (not in scope or undeclared)

  Example:
  
  Program with x2 in the relation not declared as either a free or a bound variable:
  
  ```cql
  select x1 where A(x1 x2);
  ```
  
  Error message:
  
  ```
  Variable x2 is not declared
  ```

- Existing a free variable having the same name with a bound variable and vice versa

  Example:
  
  Program with x2 as both free variable and bound variable:
  
  ```cql
  select x1 x2 where A(x1 x2) and exists x2 in B(x2);
  ```
  
  Error message:
  
  ```
  Variable x2 cannot be declared as both the free variable and the bound variable. Please rename.
  ```


##### 3.3 Runtime error

- CSV data does not match relations
  
  Example:
  
  A.csv with two columns:
<table>
	<tbody>
		<tr>
			<td>Hello</td><td>World</td>
		</tr>
	</tbody>
</table>

  Program with relation of three variables:
  
  ```cql
  select x1 x2 x3 where A(x1 x2 x3);
  ```
  
  Error message:
  
  ```
  Bad CSV input, columns do not correspond to the relation.
  ```
  
<hr>

### 4. cql.tmLanguage JSON

```JSON
{	patterns = (
		{	name = 'comment.line.double-dash';
			begin = '--';
			end = '\n';
		},
		{	name = 'keyword.control.query';
			match = '\b(select|where)\b';
		},
		{	name = 'keyword.operator.logic';
			match = '\b(and|exists|in)\b';
		},
	);
}
```

Syntax highlighting in TextMate example:

![syntax highlighting](syntax-highlighting.png)
