#
#
#

BASE		= CODING_MOTIFS_ICS728.161121.backtranseq
TSV		= $(BASE).all_uncoded.txt
FA		= $(BASE).all_uncoded.fa
FADIR		= $(BASE).all_uncoded.fadir

default: $(FA) $(FADIR)

$(FA): $(TSV)
	awk -f txt2fa.awk $< > $@

$(FADIR): $(TSV)
	awk -v "DIR=$@" -f txt2fadir.awk $<


clean:
	rm -rf $(FA) $(FADIR)
