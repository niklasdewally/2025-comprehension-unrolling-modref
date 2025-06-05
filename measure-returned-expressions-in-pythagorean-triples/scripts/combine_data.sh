#!/bin/bash


echo "n,model,command,mean,stddev,median,user,system,min,max"
for data_file in $(find output/raw_time_data -iname '*.csv' | sort); do
  n=$(echo $data_file | sed 's/data\/\([0-9]*\)_.*/\1/')
  model=$(echo $data_file | sed 's/data\/[0-9]*_\(.*\).eprime.*/\1/')
  #echo "n=${n}, file = ${model}"

  while read -r line ; do
    echo "${n},${model},${line}"
done <<< $(tail -n +2 ${data_file}) 

done
