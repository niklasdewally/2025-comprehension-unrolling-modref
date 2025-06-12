
rm *.param
parallel --no-notice 'echo letting n be {} > {}.param' ::: $(seq -w 25 25 300)
parallel --no-notice --eta --progress --joblog log --timeout 3600 -j4 savilerow -O0 {1} {2} ::: *.eprime ::: *.param ::: $(seq 1 3)
cat log | sort -n | cut -f 4,7,9- > times.dat
