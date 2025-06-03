
N = 1000

# print([(a, b, c) for a in range(1, 1+N)
#        for b in range(1, 1+N)
#        for c in range(1, 1+N)
#        if a < b
#        if b < c
#        if a ** 2 + b ** 2 == c ** 2
#        ])

# print([(a, b, c) for a in range(1, 1+N)
#        for b in range(1, 1+N)
#        if a < b
#        for c in range(1, 1+N)
#        if b < c
#        if a ** 2 + b ** 2 == c ** 2
#        ])

print([(a, b, c) for a in range(1, 1+N)
       for b in range(a+1, 1+N)
       for c in range(b+1, 1+N)
       if a ** 2 + b ** 2 == c ** 2
       ])
