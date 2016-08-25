#!/usr/bin/perl
use v5.8.5;
use warnings;
use strict;
use recoMod;
############################################################
# MAKE SURE THAT YOU RUN THIS COMMAND FIRST:
# 'source /unix/nemo2/n3/soft/ReHAB/configReco.sh'
# OR
# YOU WILL GET A BIG NASTY ERROR THAT LOOKS LIKE THIS:
# Can't locate recoMod.pm in @INC (@INC contains: <....> .)
############################################################
# a test script to hack around and test our functions
my $version = "09.07.21";
############################################################

# get my name and directory of where i am
chomp(my $prog=`basename $0`);
chomp(my $topdir=`pwd`);

goodVars || die "\n\tFATAL: variables are not right, please do:
\tsource /unix/nemo2/n3/soft/ReHAB/configReco.sh \n\n";

# print info and global variables being used
info($prog,$version);
$T=2; print "\n--> 'testing' is being forced to = $T \n\n";
status;
printGlobals;

my(@LINES,@tmp);
for(my $i=0;$i<=$#ARGV;$i++){
    system "dos2unix --quiet $ARGV[$i]" if -f "$ARGV[$i]";
    open(INFILE,"$ARGV[$i]") || next;
    @tmp=<INFILE>;
    close INFILE;
    chomp @tmp;
    map{push(@LINES,"$_") if $_ ne "" && $_ !~ m/^\#/}@tmp;
}

my($line,$filename,$fullname,$tmp,@tmps,$stat);
$tmp=0;
map{$line=$_;
############################################################
# hack around in here
    
    $filename=fileName($line);
    $fullname=lastBit($line);
    #@tmps=readDir("$basedir/$filename","f");
    
    #map{print "$_ \n"}@tmps;
    #print "\n";
    
    #$tmp=statRoot("$basedir/$filename","1e");
    #$tmp=statRoot("$basedir/$filename","2e");
    #print "$tmp \n";
    
    $stat=statBBFTP($line);
    #map{print "line: $_ \n"}@tmps;
    #$tmp++ if $#tmps!=-1;
    print "$fullname --> $stat \n\n";
    #print "$fullname --> $stat \n\n" if $stat==0;
    
    
############################################################
}@LINES;










print "\n\n\t DONE \n\n\n";

1;

