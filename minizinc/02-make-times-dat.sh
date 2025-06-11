 awk 'NR>1 {print $4, $10, $11}' joblog  | sed 's/models\///g' | sed 's/\.mzn//g' | sed 's/\.dzn//g' > times.dat
