int: n;

array[1..n] of var 1..2: class;

constraint forall(x in [class[a] != class[b] \/ class[b] != class[c] \/ class[c] != class[a] | a,b,c in 1..n where (a<=b /\ b<=c /\ a^2 + b^2 = c^2)])(x);

solve satisfy;
