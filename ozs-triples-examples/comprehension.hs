n :: Int
n = 5000

-- # print([(a, b, c) for a in range(1, 1+N)
-- #        for b in range(1, 1+N)
-- #        for c in range(1, 1+N)
-- #        if a < b
-- #        if b < c
-- #        if a ** 2 + b ** 2 == c ** 2
-- #        ])

-- # print([(a, b, c) for a in range(1, 1+N)
-- #        for b in range(1, 1+N)
-- #        if a < b
-- #        for c in range(1, 1+N)
-- #        if b < c
-- #        if a ** 2 + b ** 2 == c ** 2
-- #        ])
main =
  print
    [ (a, b, c)
    | a <- [1 .. n]
    , b <- [a + 1 .. n]
    , c <- [b + 1 .. n]
    , a ^ 2 + b ^ 2 == c ^ 2
    ]
