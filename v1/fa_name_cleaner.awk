#!/bin/awk -f 
# replace FASTA sequence names with Seq#
#
BEGIN {
  SQ_CT=1
  FS=">"
}
/^>/ {
  print FS "Seq" SQ_CT
  SQ_CT++
  next
}
{ 
  print $0
}
