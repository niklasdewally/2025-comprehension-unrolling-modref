
rm *.param
parallel --no-notice 'echo letting n be {} > {}.param' ::: $(seq -w 10 10 200)
parallel --no-notice --eta --progress --joblog joblog --timeout 3600 -j4 savilerow -O0 {1} {2} ::: *.eprime ::: *.param ::: $(seq 1 3)
