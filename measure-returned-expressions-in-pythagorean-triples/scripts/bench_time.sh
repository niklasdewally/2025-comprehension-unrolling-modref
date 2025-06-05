#!/bin/bash


# Run using makefile!

export runs=2
export mem_ulimit_gb=100
export workers=5
export warmups=1

# parallelised for each pair of model/parameter

# use custom version of conjure oxide that terminates after model was rewritten
export conjure_oxide="$(realpath bin/conjure_oxide)"

function do_parallel() {
  model="$1"
  hyperfine --runs=${runs} --warmup ${warmups} \
    -n conjureoxide_expand_simple "ulimit -Sv ${mem_ulimit_gb}000000 && exec ${conjure_oxide} --no-use-expand-ac solve $model"\
    -n conjureoxide_expand_ac     "ulimit -Sv ${mem_ulimit_gb}000000 && exec ${conjure_oxide} solve $model"\
    --export-csv output/raw_time_data/"$(basename $model)_results.csv" 
}


function main() {
  find models_with_params/ -iname '*.eprime' | sort | parallel -j${workers} --eta do_parallel
}


export -f do_parallel
export -f main 


# if on school server, undo ulimits as i set my own ulimits above.
if [ -x "$(command -v nolimit)" ]; then

  # copied from nolimit, as nolimit doesnt want to run the function..
  ulimit -v hard # virtual memory
  ulimit -t hard # CPU usage
  ulimit -u hard # number of processes
fi

if ! [ -x "${conjure_oxide}" ]; then
  echo "Fatal: conjure_oxide not installed" >&2
  exit 1
fi

main
