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
set -o pipefail

info() {
  echo " -- info: $*" >/dev/stderr
}

err() {
    echo " -- fatal: $*" >/dev/stderr
}

# parameters

n_cores=${BENCH_N_CORES:-5}
repeats=${BENCH_REPEATS:-3}
ns=${BENCH_N_VALUES:-"25 50 75 100 125"}
# max_mem_gb=${BENCH_MAX_MEM_GB:-50}
unroll_then_exit_data_path=$(realpath -m "output/unroll_then_exit_time_data.csv"})
time_data_path=$(realpath -m "output/time_data.csv"})

# max_mem_kb="${max_mem_gb}000000"
conjure_oxide_unroll_then_exit_branch="modref25-unroll-then-exit"
conjure_oxide_branch="modref25"

info "using ${n_cores} cores"
# info "using maximum ${max_mem_gb}gb RAM per conjure_oxide proces"
info "values of n: ${ns}"
info "doing ${repeats} repeats"
info "writing unroll then exit results to: ${unroll_then_exit_data_path}"
info "writing standard results to: ${time_data_path}"


cd "$(dirname $0)"

# prepare intermediate folders
rm -rf output/models_with_params output/co_unroll_then_exit_build output/co_build
mkdir -p output/models_with_params output/co_unroll_then_exit_build output/co_build

info "building latest conjure oxide (unroll then exit) build from branch ${conjure_oxide_unroll_then_exit_branch}"
git clone "https://github.com/conjure-cp/conjure-oxide.git" --branch "${conjure_oxide_unroll_then_exit_branch}" --single-branch output/co_unroll_then_exit_build

pushd output/co_unroll_then_exit_build
git submodule update --init --remote 
if ! [[ -x "$(command -v rustup)" ]]; then
  err "could not find rustup!"
  exit 1
fi
cargo build --release
popd

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
echo "model,n,bench,realtime_s,n_exprs_in_expansion" > ${unroll_then_exit_data_path}
echo "model,n,bench,realtime_s_to_first_solution" > ${time_data_path}

realtime () {
  command time -f "%e" "$@"
}

benchone() {
  model=${1}
  n=${2}
  type=${3}

  model_file="output/models_with_params/${model}-${n}.eprime"

  case ${type} in 
    "simple_uta") 
      # times go to stderr, conjure oxide output (expr count) to stdout
      tmp_stderr=$(mktemp)
      tmp_stdout=$(mktemp)
      realtime output/co_unroll_then_exit_build/target/release/conjure_oxide --no-expand-ac solve "$model_file" > "$tmp_stdout" 2> "$tmp_stderr"
      n_exprs=$(sed -n 's/number of expressions returned in the expansion: \(.*\)/\1/p' "$tmp_stdout")
      time_s=$(cat "$tmp_stderr")
      echo "${model},${n},simple,${time_s},${n_exprs}" >> "$unroll_then_exit_data_path"
      ;;
    "expand_ac_uta")
      tmp_stderr=$(mktemp)
      tmp_stdout=$(mktemp)
      realtime output/co_unroll_then_exit_build/target/release/conjure_oxide solve "$model_file" > "$tmp_stdout" 2> "$tmp_stderr"
      n_exprs=$(sed -n 's/number of expressions returned in the expansion: \(.*\)/\1/p' "$tmp_stdout")
      time_s=$(cat "$tmp_stderr")
      echo "${model},${n},expand_ac,${time_s},${n_exprs}" >> "$unroll_then_exit_data_path"
      ;;

    "simple") 
      time_s=$(realtime out/co_build/target/release/conjure_oxide solve --no-expand-ac -n1 "$model_file")
      echo "${model},${n},co_simple,${time_s}" >> "$time_data_path"
      ;;

    "expand_ac") 
      time_s=$(realtime out/co_build/target/release/conjure_oxide solve -n1 "$model_file" )
      echo "${model},${n},co_simple,${time_s}" >> "$time_data_path"
      ;;

    "sr_O0")
      time_s=$(realtime savilerow -O0 -run-solver "$model_file")
      echo "${model},${n},sr_O0,${time_s}" >> "$time_data_path"
      ;;

    "sr_O3")
      time_s=$(realtime savilerow -O3 -run-solver "$model_file")
      echo "${model},${n},sr_O3,${time_s}" >> "$time_data_path"
      ;;

    *)
      err "unknown benchmark type ${type}"
      exit 1
      ;;
  esac
}

export unroll_then_exit_data_path time_data_path
export -f realtime benchone err

# TODO: better way to deal with timeouts?
parallel --progress --no-notice --joblog output/job_log --timeout 3600 -j$n_cores benchone {1} {2} {3}\
  ::: $(find models/ -iname '*.eprime' -exec basename {} .eprime \;)\
  ::: $ns\
  ::: expand_ac_uta simple_uta expand_ac simple sr_00 sr_\
  ::: $(seq 1 $repeats)
