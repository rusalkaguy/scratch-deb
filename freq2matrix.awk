#!/bin/awk
#
# transform letters in first column of input file into an 
# BLSAT_MATRIX formatted identity matrix
# 
# see http://www.tcoffee.org/Documentation/t_coffee/t_coffee_technical.htm#_Toc256781676
#

# https://www.gnu.org/software/gawk/manual/html_node/Controlling-Array-Traversal.html#Controlling-Array-Traversal
function comp_func(i1, v1, i2, v2)
{
#  print "cmp[" i1 "," i2 "] = "
  if( i1 >= "A" && i1 <= "Z" ) {
    # i1 in A-Z
    if( i2 >= "A" && i2 <= "Z" ) {
      # i2 & i1 in A-Z
      if( i1 < i2 ) {
	return( -1 )
      } else {
	return( i1 != i2 )
      }
    } else {
      # i1 in A-Z; i2 NOT A-Z
      return( -1 )
    }
  } else {
    # i1 not A-Z
    if( i2 >= "A" && i2 <= "Z" ) {
      # i2 in A-Z
      return 1
    } else {
      if( i1 < i2 ) {
	return( -1 )
      } else {
	return( i1 != i2 )
      }
    }
  }
}

BEGIN {
  IGNORECASE = 0;
  print "# BLAST_MATRIX FORMAT";
#  if( AA_LIST == "" ) { AA_LIST="ADEKLPQRSTV" }  # 10 uncoded AAs
  if( AA_LIST == "" ) { AA_LIST="ADKLPQSTV" } # 10 reduced to 8 using Vasiliky groups: E->D, R->K
  if( SCORE_AA == "" ) { SCORE_AA=5 };
  if( SCORE_MOTIF == "" ) { SCORE_MOTIF=10 };
  split(AA_LIST,iaa_arr,"")
  for( i in  iaa_arr) { aa_arr[iaa_arr[i]]=i  }
}
{
  abet[$1] = $1;
}

END {
  # alphabet directive
  PROCINFO["sorted_in"] = "comp_func"
  printf "# ALPHABET="
  for (code in abet) {
    printf code
  }
  print "";

  # alphabet matrix header
  printf " "
  for (code in abet) {
    printf " " code
  }
  print ""

  # lines of alphabet matrix
  for (row_code in abet) {
    printf row_code;
    for (col_code in abet) {
      score=0
      if( row_code == col_code ) {
#	if( toupper(row_code) == row_code && (row_code >= "A" && row_code <= "Z") ) { 
	if( aa_arr[row_code] > 0 ) {
	  # AA letters
	  score = SCORE_AA
	} else {
	  # motif symbols
	  score = SCORE_MOTIF
	}
      }
      printf " "  score
    }
    print ""
  }

  # credits
  #print "# created on " strftime("%Y-%m-%d") " by: awk -v SCORE_AA="SCORE_AA" -v SCORE_MOTIF="SCORE_MOTIF" -f freq2matrix.awk " FILENAME
}


XEND {
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
	if( toupper(sbet[i]) == sbet[i] && (sbet[i] >= "A" && sbet[i] <= "Z") ) { 
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


