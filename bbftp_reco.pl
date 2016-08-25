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
# Script to take a runlist and begin the reconstruction
my $version = '10.10.19';
############################################################

# get my name and directory of where i am
chomp(my $prog=`basename $0`);
chomp(my $topdir=`pwd`);

goodVars || die "\n\tFATAL: variables are not right, please do:
\tsource /unix/nemo2/n3/soft/ReHAB/configReco.sh \n\n";

# print info and global variables being used
info($prog,$version);
printGlobals;

my $ctime=0; my $iter=0; my $num=0;
for(my $i=0;$i<$#ARGV;$i++){
    if($ARGV[$i] eq "-time"){
        $i++;
        $ctime=$ARGV[$i];
    }
    if($ARGV[$i] eq "-num"){
        $i++;
        $iter=$ARGV[$i];
	$iter=int($iter);
	$num=1;
    }
}
die "\nERROR: no command line input for <-time> \n\n" if ! $ctime;
die "\nERRIR: must specify the iteration <-num> of the download attempt \n\n" if ! $num;

my @tmp=file2array("$bbftpdir/$ctime.bbftp");
die "\nAWESOME: no files to download, so quiting \n\n" if @tmp==-1;

perm("$bbftpdir");

my($bigline,@line,$nowtime);
#my $killtime=$ctime+(60*60*8); # cpu=8hr - wall=24hr for medium queue
my $killtime=$ctime+(60*60*72); # cpu=72hr - wall=96hr for long queue
printv("\nBBFTP: time to do the downloads \n");
printv("-----------------------------------------------------\n");
printv("create at -->  $ctime \n");
my $timesup=0;
my $created=0;
my @failed;
my @outime;
map{$bigline=$_;
    perm("$bbftpdir");
    $nowtime=time;
    if($nowtime<$killtime){
        printv("nowtime   -->  $nowtime \n");
	printv("killtime  -->  $killtime \n");
	@line=split(':NEXT:',$bigline);
	if($line[0] && $line[1]){
	    printv("DOWNLOADING: $line[0] \n");
	    system "$line[0]";
	    if(! errBBFTP("$line[1]")){
		splitByType($line[1]) if $L>0; ### added $L>0 for download only mode
	    }else{
		print "\nWARNING: failed download for $line[1] \n\n";
		$created=1 if ! $created;
		push(@failed,"$bigline");
	    }
	    printv("\n\n");
	}else{
	    print "\nWARNING: skipping invalid line $bigline \n\n";
	}
    }else{
	print "\nWARNING: my batchfarm time is up, resubmitting \n\n";
	$timesup=1 if ! $timesup;
	$created=1 if ! $created;
	push(@outime,"$bigline");
    }
}@tmp;

if($created){
    my $count=0;
    my $newctime=time;
    open LIST,">$bbftpdir/$newctime.bbftp";
    map{print LIST "$_\n";$count++;}@outime if $#outime!=-1;
    map{print LIST "$_\n";$count++;}@failed if $#failed!=-1;
    close LIST;
    perm("$bbftpdir/$newctime.bbftp");
    print "\nNOTE: $count downloads left to do \n\n";
    $iter++ if ! $timesup;
    bbftp2farm($newctime,$iter);
}

perm("$bbftpdir");

1;

