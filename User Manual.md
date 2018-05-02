# User Manual

## Appendix

### Programs

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
