#!/usr/bin/perl -I/unix/nemo2/n3/soft/ReHAB
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
# Script to check on the reconstructed files.
my $version = '09.08.06';
############################################################
my $rm="/bin/rm -rdf ";

# get my name and directory of where i am
chomp(my $prog=`basename $0`);
chomp(my $topdir=`pwd`);

goodVars || die "\n\tFATAL: variables are not right, please do:
\tsource /unix/nemo2/n3/soft/ReHAB/configReco.sh \n\n";

# print info and global variables being used
info($prog,$version);

# the default command line options
my $match=0; my $exp; $V=0;
my $del=0;
$topdir=$basedir;

# get command line options
for(my $i=0;$i<=$#ARGV;$i++){
    if($ARGV[$i] =~ m/[Hh][Ee][Ll][Pp]/ || $ARGV[$i] =~ m/^-[Hh].*/){
	&usage;
	exit 0;
    }elsif($ARGV[$i] eq "-p"){
	$i++;
	if($ARGV[$i] && $ARGV[$i] !~ m/^-/){
	    $topdir=$ARGV[$i];
	    if($topdir =~ m/^\.+/){
		print "ERROR: no relative paths please (see --help). \n\n";
		exit 1;
	    }
	}else{
	    print "ERROR: must specify a <path> to search (see --help). \n\n";
	    exit 1;
	}
    }elsif($ARGV[$i] eq "-m"){
	$i++;
	if($ARGV[$i] && $ARGV[$i] !~ m/^-/){
	    $exp=${ARGV[$i]};
	    $match=1;
	}else{
	    print "ERROR: must specify <exp> to match (see --help). \n\n";
            exit 1;
	}
    }elsif($ARGV[$i] eq "-D"){
        $del=1;
    }elsif($ARGV[$i] =~ m/^-v/){
	$V=1 if $ARGV[$i] eq "-v";
	$V=2 if $ARGV[$i] eq "-vv";
	print "ARG VERBOSE: $V \n";
    }else{
	print "WARNING: skipping option \"$ARGV[$i]\" (see --help). \n";sleep 1;
    }
}

if(!$match){
    print "\nERROR: '-m' and <exp> were not specified (see --help). \n\n";
    exit 1;
}else{
    print "WARNING: make sure your POSIX regular expression is enclosed \n";
    print "         in single quotes (-m \'match\') on the command line. \n\n";
    print "Here is your expression, make sure it's correct: \n";
    print "\n  --->  ${exp} \n\n";sleep 1;
}

# initiallize the variables and arrays
my(@goodFiles,@badRoot,@badDST,@noRaw);
my($tmp);

my $efile="$topdir/1e_control-$user.dat";
my $eefile="$topdir/ee_control-$user.dat";
open EF, ">$efile";
open EEF, ">$eefile";

printv("\nGoing into here  ==>  $topdir \n");
printv("=========================================================\n");
map{$tmp=$_;
    if($tmp =~ m/${exp}/){
	my $stat=statusID($topdir,$tmp);
	printv("status id -->  $stat  (0 means no errors) \n");
	if($stat==0){
	    push(@goodFiles,$tmp);
	    print EF "$tmp.1e.root\n";
	    print EEF "$tmp.root\n";
	}
	push(@noRaw,$tmp) if $stat>=100;
	push(@badDST,$tmp) if $stat>=10 && $stat<100;
	push(@badRoot,$tmp) if $stat>=1 && $stat<10;
	printv("\n");
    }
}sort(readDir("$topdir","dir"));
close EF;
close EEF;

my $gf=$#goodFiles+1;
my $br=$#badRoot+1;
my $bd=$#badDST+1;
my $nr=$#noRaw+1;

print "\n GOOD = $gf  (both 1e & ee have successful reconstruction) \n";
print "-----------------------------------------------------------\n";
map{print " GOOD: $_ \n"}sort @goodFiles;

print "\n BAD ROOT = $br  (the rootfiles are missing) \n";
print "-----------------------------------------------------------\n";
map{$tmp=$_;
    my $first=firstEvent("$topdir/$tmp");
    my $proc=procEvent("$topdir/$tmp");
    print " BAD ROOT: $tmp --> $first / $proc \n";
    my $doit=0; $doit=1 if $first>=0 && $proc>=0 && $first >= $proc;
    print "\t --> you can delete me \n" if $doit && ! $del;
    if($doit && $del){
	print "\t --> deleting $tmp \n";
	system "$rm $topdir/$tmp";
    }
}sort @badRoot;

print "\n BAD DST = $bd  (the dst files have errors) \n";
print "-----------------------------------------------------------\n";
map{$tmp=$_;
    print " BAD DST: $tmp --> ".nemorLog("$topdir/$tmp")." \n";
    my $first=firstEvent("$topdir/$tmp");
    my $proc=procEvent("$topdir/$tmp");
    my $doit=0; $doit=1 if $first>=0 && $proc>=0 && $first >= $proc;
    print "\t --> you can delete me \n" if $doit && ! $del;
    if($doit && $del){
        print "\t --> deleting $tmp \n";
        system "$rm $topdir/$tmp";
    }
}sort @badDST;

print "\n NO RAW = $nr  (cannot find the raw data/mc file) \n";
print "-----------------------------------------------------------\n";
map{print " NO RAW: $_ \n"}sort @noRaw;


my $failed=$br+$bd+$nr;
print "\n\nTOTAL FAILED: $failed \n\n";
my $success=0;
$success=(int(($gf/($gf+$br+$bd+$nr))*10000))/100 if $gf!=0;
print "SUCCSESS RATE: $success % \n\n\n";


1;

############################################################
#####     FUNCTIONS
############################################################

sub usage{
    print "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
    print "USAGE: $prog -m <exp> [options] \n";
    print "\t -m <exp>     Match to POSIX regular expression <exp> \n";
    print "\t              Must be within single quotes to work \n";
    print "\t              $prog -m \'^\\w\\.[0-9]+\$\' \n";
    print "\t -p <path>    Absolute path to directory to look in \n";
    print "\t              No relative paths allowed \n";
    print "\t              Default path is $basedir \n";
    print "\t -D           Deletes directories where start reco event number is \n";
    print "\t              greater than the number of events in the raw file \n";
    print "\t -v           Verbose information printed out \n";
    print "\t -h,--help    Obviously to give help \n";
    print "  http://www.troubleshooters.com/codecorn/littperl/perlreg.htm  \n";
    print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n\n";
}

