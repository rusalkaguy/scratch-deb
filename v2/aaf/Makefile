AAF_DIR		=  /share/apps/ngs-ccts/aaf-phylogeny/AAF20160831/AAF/
DATA_VER	=  161121
DATA_DIR	=  ../CODING_MOTIFS_ICS728.$(DATA_VER).backtranseq.all_uncoded.fadir
DATA_FILES	=  $(wildcard $(DATA_DIR)/*/*.fa)
K		?= 5
#OUTDIR		=  k$(K)
OUTNAME		=  all_uncoded.$(DATA_VER).k$(K)


CORES=$(SLURM_JOB_CPUS_PER_NODE)
CORES ?= 1

default: $(OUTNAME).nl.tre 

#$(OUTDIR):
#	mkdir -p $@

# run simple test data
#
#
# 4) Kmer counting
$(OUTNAME).pkmer.dat.gz $(OUTNAME).pkmer.dat.wc: $(DATA_DIR) $(DATA_FILES)
	module load aaf-phylogeny/20160831 2> /dev/null ; \
	python $(AAF_DIR)/aaf_phylokmer.py -k $(K) -t $(CORES) -d $(DATA_DIR) -G $$((2*$(CORES))) -o $@; \
	rm *.pkdat.gz
# 5) distance calc/tree construction
$(OUTNAME).tre $(OUTNAME).dist $(OUTNAME)_nshare.csv: $(OUTNAME).pkmer.dat.gz $(OUTNAME).pkmer.dat.wc
	module load aaf-phylogeny/20160831 2> /dev/null; \
	python $(AAF_DIR)/aaf_distance.py -i $< -o $(basename $@ .tre) -t $(CORES) -G $$((2*$(CORES))) -f $(OUTNAME).pkmer.dat.wc

$(OUTNAME).nl.tre: $(OUTNAME).tre
	 perl -pe 's/[(,]/$1\n/g;s/[:]/\n$1/g;' $< > $@

# 6) tip correctoin
tip_$(OUTNAME).tre: test.tre
	module load aaf-phylogeny/20160831 2> /dev/null; \
	python $(AAF_DIR)/aaf_tip.py -i $< -k $(K) --tip=$(AAF_DIR)/tip_info_test.txt -f $(OUTNAME).pkmer.dat.wc

# 7) Non-parametric bootstrap (optional)
out: $(DATA_DIR) $(DATA_FILES)
	module load aaf-phylogeny/20160831 2> /dev/null; \
	python $(AAF_DIR)/nonparametric_bootstrap.py -k $(K) -d $(DATA_DIR) -t $(CORES) --S1 2 --S2 2
#
# 8) Parametric bootstrap (optional)
# Set your working directory to the AAF folder and change the parameters in the “set parameters” section, including nboot, k, filter, info.file and n.table.file.
#
# # itip_test.tre
# k

clean:
	rm -rf $(OUTNAME).*
