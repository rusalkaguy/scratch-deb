# qsub compatibility
NSLOTS		?= 1


# base inputs and requirements
BASE	= CODING_MOTIFS_ICS728.20160401
LOAD_TCOFFEE 	= module load ngs-ccts/t-coffee/11.00.8cbe486

# motif/aa scors
SCORE_AA	?= 5
SCORE_MOTIF	?= 10
SCORE_ABBR	?= $(SCORE_AA).$(SCORE_MOTIF)

# intermediate and output files
SRC_UNCODED	= $(BASE).uncoded.txt
SRC_CODED	= $(BASE).coded_lc.txt
SRC_RECODE_TABLE =$(BASE).id_map.txt
RECODED_FA	= $(BASE).recoded.fa
RECODED_FREQ	= $(BASE).recoded.freq.txt
RECODED_MATRIX	= $(BASE).recoded.$(SCORE_ABBR).matrix

# alignment
RECODED_ALN	= $(BASE).recoded.$(SCORE_ABBR).aln
RECODED_DND	= $(BASE).recoded.$(SCORE_ABBR).dnd

# combined src/recoding tabular files
BOTH	= $(BASE).both.txt
TEST_BOTH	= test.both.txt
FREQS	= motifs_freq.txt aa_freq.txt



default: $(FREQS) $(BOTH) $(RECODED_FA) $(RECODED_MATRIX)

matrix: $(RECODED_MATRIX)

motifs_freq.txt: $(SRC_CODED)
	cut -f 2 $< | perl -pe 's/5/e/g;s/[A-Z]//g;s/(.)/$$1\n/g' | sort | uniq -c > $@
	@echo "------ $@ -----"
	@cat $@

aa_freq.txt: $(SRC_CODED)
	cut -f 2 $< | perl -pe 's/5/e/g;s/[a-z]//g;s/(.)/$$1\n/g' | sort | uniq -c > $@
	@echo "------ $@ -----"
	@cat $@

%.sorted: %.txt
	sort -k1,1 $< > $@

$(BOTH): $(SRC_CODED:.txt=.sorted) $(SRC_UNCODED:.txt=.sorted)
	join -t "	" $^ > $@


#---------------------------------------------------------------------- 
# apply a re-coding
#---------------------------------------------------------------------- 

$(RECODED_FA): $(SRC_CODED) $(SRC_RECODE_TABLE)
	awk -v DEBUG=0 -v MAP=$(SRC_RECODE_TABLE) -f recode.awk $< > $@
	cat $@
# 
# TEST
#
$(TEST_BOTH): $(BOTH)
	head -1 $< > $@

test: $(TEST_BOTH)
	 awk -v DEBUG=0 -v MAP=$(SRC_RECODE_TABLE) -f recode.awk $<

#---------------------------------------------------------------------- 
# alignment
#---------------------------------------------------------------------- 
align: $(RECODED_ALN) $(RECODED_DND)

%.freq.txt: %.fa
	grep -v "^>" $< | perl -pe 's/(.)/$$1\n/g' | sort | uniq -c | awk 'BEGIN{OFS="\t"}($$2!=""){print $$2,$$1}' > $@

%.$(SCORE_ABBR).matrix: %.freq.txt
	awk -v SCORE_AA=$(SCORE_AA) -v SCORE_MOTIF=$(SCORE_MOTIF) -f freq2matrix.awk $<  > $@

# -matrix=$(RECODED_MATRIX)
$(RECODED_ALN) $(RECODED_DND): $(RECODED_FA) $(RECODED_MATRIX)
	$(LOAD_TCOFFEE); \
	t_coffee $< \
		-matrix=$(RECODED_MATRIX) \
		-debug \
		-multi_core jobs -n_core=$(NSLOTS) \
		-output aln,score_html,score_pdf

#
# INFO
#
info: 
	@echo "BOTH=$(BOTH)"
	@echo "CODED=$(SRC_CODED:.txt=.sorted)"
	@echo "UNCODED=$(SRC_UNCODED:.txt=.sorted)"
	@echo "MATRIX=$(RECODED_MATRIX)"
	@echo "ALN=$(RECODED_ALN)"

# 
# Clean
#
clean: clean_aln

clean_aln: 
	rm -rf $(RECODED_ALN) $(RECODED_DND) $(RECODED_MATRIX)