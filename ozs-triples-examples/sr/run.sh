
rm *.param
parallel 'echo letting N be {} > {}.param' ::: $(seq -w 10 10 200)
parallel --no-notice --joblog log --timeout 600 -j4 savilerow -O0 ::: *.eprime ::: *.param
cat log | sort -n | cut -f 4,7,9- > log-sorted.txt
