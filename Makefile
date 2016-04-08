BASE	= CODING_MOTIFS_ICS728.20160401
SRC_CODED	= $(BASE).coded_lc.txt
SRC_UNCODED	= $(BASE).uncoded.txt
SRC_RECODE_TABLE =$(BASE).map.txt
DEST_RECODED	= $(BASE).recoded.fa
BOTH	= $(BASE).both.txt
FREQS	= motifs_freq.txt aa_freq.txt

TEST_BOTH	= test.both.txt


default: $(FREQS) $(BOTH) $(DEST_RECODED)


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

#
# apply a re-coding
#
$(DEST_RECODED): $(SRC_CODED) $(SRC_RECODE_TABLE)
	awk -v DEBUG=0 -v MAP=CODING_MOTIFS_ICS728.20160401.map.txt -f recode.awk $< > $@
	cat $@
# 
# TEST
#
$(TEST_BOTH): $(BOTH)
	head -1 $< > $@

test: $(TEST_BOTH)
	 awk -v DEBUG=0 -v MAP=CODING_MOTIFS_ICS728.20160401.map.txt -f recode.awk $<

#
# INFO
#
info: 
	echo "BOTH=$(BOTH)"
	echo "CODED=$(SRC_CODED:.txt=.sorted)"
	echo "UNCODED=$(SRC_UNCODED:.txt=.sorted)"

