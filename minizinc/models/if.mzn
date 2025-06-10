
int: n;

array[1..n] of var 1..2: class;

constraint forall(a,b,c in 1..n)(if (a^2 + b^2 = c^2) then (class[a] != class[b] \/ 
  class[b] != class[c] \/
  class[c] != class[a]) else true endif);

solve satisfy;
