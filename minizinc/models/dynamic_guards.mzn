int: n;

array[1..n] of var 1..2: class;

constraint forall(a,b,c in 1..n)((a <=b /\ b <= c /\ a^2 + b^2 = c^2) -> (class[a] != class[b] \/ 
  class[b] != class[c] \/
  class[c] != class[a]));

solve satisfy;
