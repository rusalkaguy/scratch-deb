#!/usr/bin/awk
# INPUT: TSV; C1=seq_name, C2=seq
# OUTPUT: $DIR/seq_name.fa
#

BEGIN { 
    OFS="\t"; IFS="\t"; 
    if( DIR == "" ) { DIR="fa_dir"};
    print "DIR=" DIR;
}

($1 != "" && $2 != "") {
    # make seq dir
    ODIR = DIR "/" $1 
    cmd = "mkdir -p " ODIR;
    system(cmd); close(cmd);

    OFILE = ODIR "/" $1 ".fa";
    print ">"$1 > OFILE
    print $2 	> OFILE;
    print "wrote " OFILE
}
