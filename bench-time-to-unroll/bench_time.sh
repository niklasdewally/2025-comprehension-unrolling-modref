#!/usr/bin/env bash
#
# ./bench_time
#
# Measure time until unrolled for the triples problem for varying n.
#
# Author: niklasdewally
# Date: 2025/06/06

# if something fails, exit immediately
set -e 
set -x
set -o pipefail

info() {
  echo " -- info: $*" >/dev/stderr
}

err() {
    echo " -- fatal: $*" >/dev/stderr
}

# parameters

n_cores=${BENCH_N_CORES:-5}
ns=${BENCH_N_VALUES:-"25 50 75 100"}
max_mem_gb=${BENCH_MAX_MEM_GB:-50}
time_data_path=$(realpath -m ${BENCH_TIME_DATA_PATH:-"$(dirname $0)/output/time_data.csv"})

max_mem_kb="${max_mem_gb}000000"
conjure_oxide_branch="nik/more-comprehensions-experiment-unroll-and-exit"

info "using ${n_cores} cores"
info "using maximum ${max_mem_gb}gb RAM per conjure_oxide proces"
info "values of n: ${ns}"
info "writing results to: ${time_data_path}"


cd "$(dirname $0)"

# prepare intermediate folders
rm -rf output/models_with_params output/co_build 
mkdir -p output/models_with_params output/co_build 

info "building latest conjure oxide build from branch ${conjure_oxide_branch}"
git clone "https://github.com/conjure-cp/conjure-oxide.git" --branch "${conjure_oxide_branch}" --single-branch output/co_build

pushd output/co_build
git submodule update --init --remote 
if ! [[ -x "$(command -v rustup)" ]]; then
  err "could not find rustup!"
  exit 1
fi
cargo build --release
popd

info "building models"

for model in $(find models -iname "*.eprime"); do 
  for n in $ns; do
    model_name="$(basename ${model} .eprime)"
    ./scripts/substitute_n "${model}" $n > "./output/models_with_params/${model_name}-${n}.eprime"
  done
done


info "running it!"
echo "model,n,bench,realtime_s,n_exprs_in_expansion" > ${time_data_path}


realtime () {
  command time -f "%e" "$@"
}

benchone() {
  model=${1}
  n=${2}
  type=${3}

  model_file="output/models_with_params/${model}-${n}.eprime"

  case ${type} in 
    "simple") 
      output=$(realtime output/co_build/target/release/conjure_oxide --no-use-expand-ac solve "$model_file")
      n_exprs=$(echo "$output" | sed -n 's/number of expressions returned in the expansion: \(.*\)/\1/p')
      time_s=$(tail -1 output)
      echo "${model},${n},${type},${time_s},${n_exprs}" >> "$time_data_path"
      ;;
    "expand_ac")
      output=$(realtime output/co_build/target/release/conjure_oxide --no-use-expand-ac solve "$model_file")
      n_exprs=$(echo "$output" | sed -n 's/number of expressions returned in the expansion: \(.*\)/\1/p')
      time_s=$(tail -1 output)
      echo "${model},${n},${type},${time_s},${n_exprs}" >> "$time_data_path"
      ;;
    *)
      err "unknown benchmark type ${type}"
      exit 1
      ;;
  esac
}

export time_data_path
export -f realtime benchone err

# TODO: better way to deal with timeouts?
parallel --progress --no-notice --joblog output/job_log --timeout 600 -j$n_cores benchone {1} {2} {3}\
  ::: $(find models/ -iname '*.eprime' -exec basename {} .eprime \;)\
  ::: $ns\
  ::: expand_ac simple\
  ::: repeat $(seq 1 2 1)
