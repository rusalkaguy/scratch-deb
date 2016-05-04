#!/bin/awk
#
# transform letters in first column of input file into an 
# BLSAT_MATRIX formatted identity matrix
# 
# see http://www.tcoffee.org/Documentation/t_coffee/t_coffee_technical.htm#_Toc256781676
#
BEGIN {
  IGNORECASE = 0;
  print "# BLAST_MATRIX FORMAT";
  if( SCORE_AA == "" ) { SCORE_AA=5 };
  if( SCORE_MOTIF == "" ) { SCORE_MOTIF=10 };
}
{
  abet[$1] = $1;
}

END {
  # alphabet directive
  n = asorti(abet, sbet)
  printf "# ALPHABET="
  for (i=1; i<=n; i++) {
    printf sbet[i]
  }
  print "";

  # alphabet matrix header
  printf " "
  for (i=1; i<=n; i++) {
    printf " " sbet[i];
  }
  print ""

  # lines of alphabet matrix
  for (i=1; i<=n; i++) {
    printf sbet[i];
    for (j=1; j<=n; j++) {
      score=0
      if( i==j ) {
	if( toupper(sbet[i]) == sbet[i] ) { 
	  # AA letters
	  score = SCORE_AA
	} else {
	  # motif symbols
	  score = SCORE_MOTIF
	}
      }
      printf " " score
    }
    print ""
  }

  # credits
  #print "# created on " strftime("%Y-%m-%d") " by: awk -v SCORE_AA="SCORE_AA" -v SCORE_MOTIF="SCORE_MOTIF" -f freq2matrix.awk " FILENAME
}


