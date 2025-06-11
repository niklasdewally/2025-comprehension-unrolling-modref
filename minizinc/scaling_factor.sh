#!/bin/bash


parallel --progress --eta --no-notice --joblog joblog --resume --timeout 3600 -j4 minizinc {1} {2}\
  ::: $(find -iname 'models/*.mzn' | sort) \
  ::: $(find -name 'models/*.dzn' | sort)\
  ::: $(seq 1 3)
