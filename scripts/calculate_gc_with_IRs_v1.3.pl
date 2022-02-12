#!/usr/bin/perl
#The seqkit software is required.

use strict;
use List::MoreUtils qw(any uniq);
use List::Util 'max';
use List::Util 'min';

my $IRfile;
my $source;

sub get_gc {
  my $seq=shift;
  my $Gnum=($seq =~ s/g/G/ig);
  my $Cnum=($seq =~ s/c/C/ig);
  my $Anum=($seq =~ s/a/A/ig);
  my $Tnum=($seq =~ s/t/T/ig);
  if($seq =~ /n/i){
    print "Warnning: Gap charcter N found in one of the sequences!";
    }
  my $gc_per=($Gnum+$Cnum)/($Gnum+$Cnum+$Anum+$Tnum)*100;
  $gc_per=sprintf("%.2f",$gc_per);

  return $gc_per;
  }

if(@ARGV==2){
  $IRfile=$ARGV[0];
  $source=$ARGV[1];  
  }
  else{
    print "    Get the GC% of IRs defined by IR result file, which obtained by identify_all_IRs.pl\n\n    Usage: perl perl_file_name.pl <IRfile> <Source_fasta>\n\n";
    print "    IRfile        IR result file which obtained as result of the identify_all_IRs.pl\n";
    print "    Source_fasta  A multi-fasta file containing DNA sequences, which have the same IDs with that in IRfile\n\n";
    print "    Writtern by He W. (nongke2\@163.com) at Huazhong Agricultural University (HZAU), August, 2019. \n\n";
    exit(0);
    }
chomp($IRfile);
chomp($source);

open(IRregion,$IRfile) || die"Cannot open the corresponding IR_region file: $IRfile\n";
open(source,$source) || die"Cannot open the souce_fasta file: $source\n";
close source;

$IRfile=(split(/\//,$IRfile))[-1];

my @IRregion=<IRregion>;
chomp(@IRregion);
close IRregion;

open out,">out_GC_".$IRfile;
print out "fa_ID\tContigs_num\tAll_GC_%\tLSC_GC_%\tIRA_GC_%\tSSC_GC_%\n";

shift @IRregion;
foreach my $each(@IRregion){
  my ($label,undef,$L_s,$L_e,$A_s,$A_e,$S_s,$S_e,undef,undef)=split(/\t/,$each);

  my $temp_command0="seqkit subseq -w 0 --chr ".$label." -r 1:-1 ".$source;
  my @result0=`$temp_command0`;
  my $all_gc=get_gc($result0[-1]);

  my $temp_command1="seqkit subseq -w 0 --chr ".$label." -r ".$L_s.":".$L_e." ".$source;
  my @result1=`$temp_command1`;
  my $L_gc=get_gc($result1[-1]);

  my $temp_command2="seqkit subseq -w 0 --chr ".$label." -r ".$A_s.":".$A_e." ".$source;
  my @result2=`$temp_command2`;
  my $A_gc=get_gc($result2[-1]);

  my $temp_command3="seqkit subseq -w 0 --chr ".$label." -r ".$S_s.":".$S_e." ".$source;
  my @result3=`$temp_command3`;
  my $S_gc=get_gc($result3[-1]);
  
  my $contig_num;
  if($result1[0] =~ /\(/){  
    chomp($result1[0]);
    my @contigs=split(/ /,(split(/:/,$result1[0]))[-1]);
    my @uni_contigs = uniq((map {$_ =~ s/[FR\(\)]+//g;$_} @contigs));
    $contig_num=@uni_contigs;
    print "uni contigs: @uni_contigs \n";#test
    }
    else{
      $contig_num=0;
      }
  
  print out $label."\t".$contig_num."\t${all_gc}\t".$L_gc."\t".$A_gc."\t".$S_gc."\n";
  print "finished about: ${label} \n";
  }
close out;
