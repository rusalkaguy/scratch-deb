#
# ggtree
#
# https://bioconductor.org/packages/devel/bioc/vignettes/ggtree/inst/doc/treeImport.html

library("ggplot2")
# library("ggtree") not yet availble
# source("https://bioconductor.org/biocLite.R")
# biocLite("ggtree")
library(ggtree)
library(phylobase)

#
# load annotation
#

brilesGroups = read.delim("CODING_MOTIFS_ICS728.161121.groups.txt", sep="\t", header=TRUE, stringsAsFactors=F)
#bg = brilesGroups[,c(-1,-2)]
#row.names(bg) = brilesGroups$name
bg = data.frame(row.names=brilesGroups$name, grp=brilesGroups$ColorCode)
#
# iterate over K
#
for( k in seq(9,45,by=3) ) {
# load file
  file<-paste0("aaf/all_uncoded.161121.k",k,".tre")
  tree = read.tree(file)
  comment(tree) =c(filename=file)

# graph
# ggtree(tree) + geom_tiplab() + geom_point(aes(color=isTip), size=5, alpha=.5)
  #+ geom_text(aes(label=branch.length, x=branch), vjust=-.5)


#
# annotate tree
#
# annoTree = tree %<+% brilesGroups
# Error in fix.by(by.x, x) : 'by' must specify a uniquely valid column

# need rownamesAsLabels in order not to interpret numeric rownames as rowNUMBERS!
dbat = phylo4d(tree,bg, rownamesAsLabels=T)

# display 
#ggtree(dbat) + geom_tiplab() + geom_point(aes(color=grp),size=5, alpha=0.5)


pdffile<-paste0("aaf/all_uncoded.161121.k",k,".tre.ggtree.pdf")
pdf(pdffile,width=8,height=10)
# 
# with Group
#
p =ggtree(dbat)
pp = (p +geom_treescale(x=.02) + geom_tiplab(align=T, aes(color=grp), size=2))
ppp=gheatmap(pp, bg, offset=0.02, width =0.2)
print(ppp)

# display with AA
seqs = BStringSet(brilesGroups$seq, start=1)
names(seqs)=brilesGroups$name
print(msaplot(pp, seqs, offset=0.03))

dev.off()

}
#
# convert TREE to DATA.FRAME
#
#tree_data = fortify(tree)
#head(tree_data)

