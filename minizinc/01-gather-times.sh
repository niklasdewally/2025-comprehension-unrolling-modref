#!/bin/bash


parallel --progress --eta --no-notice --joblog joblog --resume --timeout 3600 -j4 minizinc models/{1}.mzn models/{2}.dzn\
  ::: $(find models/ -iname '*.mzn' -exec basename {} .mzn \; | sort) \
  ::: $(find models/ -iname '*.dzn' -exec basename {} .dzn \; | sort)\
  ::: $(seq 1 3)
