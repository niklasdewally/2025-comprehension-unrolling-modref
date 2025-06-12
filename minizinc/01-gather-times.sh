#!/bin/bash

ns=$(seq 10 10 200)

for i in $ns; do
  echo "n = $i;" > "models/$i.dzn"
done

parallel --progress --eta --no-notice --joblog joblog --resume --timeout 3600 -j4 minizinc -c --solver chuffed models/{1}.mzn models/{2}.dzn\
  ::: $(find models/ -iname '*.mzn' -exec basename {} .mzn \; | sort) \
  ::: $(find models/ -iname '*.dzn' -exec basename {} .dzn \; | sort)\
  ::: $(seq 1 3)
