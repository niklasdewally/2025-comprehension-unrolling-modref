
NS = 025 050 075 100 125 150

MODELS = $(shell find models/ -iname '*.eprime')



## run time benchmarks and create figures (requires R + tidyverse libraries)
.PHONY: time-figs
time-figs: output/time_figs/plot.png

## run time benchmarks 
.PHONY: time-data
time-data: output/time-data.csv 

# rules 
# =====

# to generate all the models
$(foreach N,$(NS),$(eval MODELS_WITH_PARAMS+=$(patsubst models/%.eprime,models_with_params/$(N)_%.eprime,$(MODELS))))

define modelrule
models_with_params/$(1)_%.eprime: models/%.eprime | models_with_params
	sed 's/given n.*/letting n be $(1)/g' < $$< > $$@
endef

$(foreach N,$(NS),$(eval $(call modelrule,$(N))))

# download and build the experiment's branch of conjure oxide, which exits
# after unrolling, printing the # of expressions in the unrolled comprehension. 
bin/conjure_oxide:
	mkdir -p bin;
	bin_dir=$$(realpath bin);\
	tmpdir=$$(mktemp -d);\
	cd "$$tmpdir";\
	git clone https://github.com/conjure-cp/conjure-oxide.git --single-branch --branch 'nik/more-comprehensions-experiment-unroll-and-exit' .;\
	git submodule update --init --remote;\
	cargo build --release; \
	cp target/release/conjure_oxide $$bin_dir

# run time benchmarks and concat results into single csv
output/time-data.csv: $(MODELS_WITH_PARAMS) ./scripts/bench_time.sh ./scripts/combine_data.sh | bin/conjure_oxide output/raw_time_data
	./scripts/bench_time.sh
	./scripts/combine_data.sh > output/time-data.csv

output/time_figs/plot.png: output/time-data.csv scripts/plot.R | output/time_figs
	./scripts/plot.R

# folders
# =======

models_with_params: 
	mkdir -p models_with_params

output/raw_time_data: 
	mkdir -p output/raw_time_data

output/time_figs: 
	mkdir -p output/time_figs


.PHONY: clean
clean: 
	rm -rf models_with_params

.PHONY: debug
debug:
	$(foreach N,$(NS),$(info $(call modelrule,$(N))))
