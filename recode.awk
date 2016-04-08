#
# recode motifs in a tabular file, produce a FASTA
#
BEGIN {
  FS="\t";
  # ----------------------------------------------------------------------
  # 
  # load tab-separated mapping file with mapping
  #
  # ----------------------------------------------------------------------
  # creates associative arrays:
  #     src[character] = mapped_character
  if(!MAP) {
    print "ERROR: MAP must be set to the filename of the mapping file";
    print "mapping file should contain tab-separated pairs: src_letter dest_symbol"
    exit(1);
  }
  if(DEBUG){print "##### loading mapping file" MAP};
  while (getline < MAP) {
    if(DEBUG){print "line ", $0};
    # skip comments
    if( $0 ~ /^#/ ) { continue; } 
    # parse mapping file line
    ct=split($0,a,"\t");
    if( NF >= 2 ) {
      # PARSE -----------------
      # (doubles): id gene_name
      src_char=a[1];
      dest_char=a[2];
      if(MAP_CHAR[src_char]) {
	print "ERROR: src_char mapped twice: [" MAP_CHAR[src_char] "] ["dest_char"] on "FILENAME":"NR;
	exit 1;
      }
      MAP_CHAR[src_char]=dest_char
      if(DEBUG){print src_char "=>" dest_char}
      if( NF == 3 ) {
	# (tripples): src dest seq
	dest_seq=a[3];
	MAP_SEQ[src_char]=dest_seq
	if(DEBUG){print "\t" src_char "=>" dest_seq }
      }
    }
  }
  if(DEBUG){print "##### mapping file loaded"}

  #
  # column mappings for FPKM file
  #
  cSEQ_NAME  = 1
  cCODED = 2
  cUNCODED  = 3
}
# skip comments
($0 ~ /^#/ || $1 == "" ) { next; }

# re-map motif coded seq and emit fasta
{
  coded=$cCODED;
  recoded="";
  if(DEBUG){ print "["NR"]"$cSEQ_NAME":"coded}
  for(i=1; i< length(coded); i++) {
    # extract and remap i-th char
    src_char=substr(coded,i,1);
    dest_char=MAP_CHAR[src_char];
    # preserve chars not present in map file
    if(dest_char=="") { dest_char=src_char }
    # build mapped string
    recoded=recoded dest_char;
    if(DEBUG){print "\t recode " i " " src_char " " dest_char " " recoded}
  }
  # output as a FASTA
  print ">"$cSEQ_NAME
  print recoded
}