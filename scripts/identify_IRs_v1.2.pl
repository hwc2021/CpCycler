#!/usr/bin/perl
#Mummer3 software is required.

use strict;

if(@ARGV != 2){
  print "perl this.pl </path/dir_name> 1 | perl this.pl <file1,file2..> 2 \n";
  exit(0);
  }
my ($a1,$a2)=@ARGV;
my $file_list;
my @files;
if($a2 == 1){
  $file_list=`ls $a1/*fasta`;
  @files=split(/\s+/,$file_list);
  }
  elsif($a2 == 2){
  $file_list=$a1;
   @files=split(/,/,$file_list);
  }
  else{
  die "Errors: Your input options were not defined! \n";
  }

open out,">out_all_IRs.txt";
print out "fa_ID\tTotal_length\tLSC_start\tLSC_end\tIRA_start\tIRA_end\tSSC_start\tSSC_end\tIRB_start\tIRB_end\n";
foreach my $each(@files){
  my $mummer_result=`mummer -r -L -l 1000 ${each} ${each}`;
  my @mummer=split(/\n/,$mummer_result);
  my ($label,$total_length)=(split(/\s+/,$mummer[0]))[1,4];
  my (undef,$IRA_start,$IRB_start,$IR_len)=split(/\s+/,$mummer[2]);
  my $L_s=1;
  my $L_e=$IRA_start-1;
  my $A_e=$IRA_start+$IR_len-1;
  my $B_s=$total_length-($IR_len-1);
  my $B_e=$total_length;
  my $S_s=$A_e+1;
  my $S_e=$B_s-1;
  print out $label."\t".$total_length."\t".$L_s."\t".$L_e."\t".$IRA_start."\t".$A_e."\t".$S_s."\t".$S_e."\t".$B_s."\t".$B_e."\n";
  print "finished about: ${label} \n";
  }
