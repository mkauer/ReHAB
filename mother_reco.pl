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
# This script will take any arbitrary number of filelists
# and download the needed files and reconstruct them.
my $version = '10.10.19';
############################################################

# get my name and directory of where i am
chomp(my $prog=`basename $0`);
chomp(my $topdir=`pwd`);

goodVars || die "\n\tFATAL: variables are not right, please do:
\tsource /unix/nemo2/n3/soft/ReHAB/configReco.sh \n\n";

# print info and global variables being used
info($prog,$version);
status;
printGlobals;

my(@LINES,@tmp);
my $force=0; my $exp='.*';
if($#ARGV >= 0){
    for(my $i=0;$i<=$#ARGV;$i++){
	if($ARGV[$i] =~ m/[Hh][Ee][Ll][Pp]/ || $ARGV[$i] =~ m/^-[Hh].*/){
	    &usage;
	    exit 0;
	}elsif($ARGV[$i] eq "-m"){
	    $i++;
	    if($ARGV[$i] && $ARGV[$i] !~ m/^-/){
		$exp=${ARGV[$i]};
	    }else{
		print "ERROR: must specify <exp> to match (see --help). \n\n";
		&usage;
		exit 1;
	    }
	}elsif($ARGV[$i] eq "-f"){
	    $force=1;
	}else{
	    system "dos2unix --quiet $ARGV[$i]" if -f "$ARGV[$i]";
	    open(INFILE,"$ARGV[$i]") || next;
	    @tmp=<INFILE>;
	    close INFILE;
	    chomp @tmp;
	    map{push(@LINES,"$_") if $_ ne "" && $_ !~ m/^\#/}@tmp;
	}
    }
}else{
    print "ERROR: must specify a filelist (see --help). \n\n";
    &usage;
    exit 1;
}

my $ctime=0;
my $created=0;
my($line,$dstat,$script);
map{$line=$_;
    if($line =~ m/${exp}/){
	$dstat=createBBFTP($line);
	if($dstat ne "doit" && $dstat ne "error"){
	    if(! $created){
		$ctime=time;
		$script="$bbftpdir/$ctime.bbftp";
		open LIST,">$script";
		printv("\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
		printv("creating  -->  $script \n");
		printv("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n\n");
		$created=1;
	    }
	    print LIST "$dstat:NEXT:$line\n";
	}
	splitByType($line) if $dstat eq "doit" && $L>1; ### was $L>0 but changed for download only mode
    }
}@LINES;

if($created && $ctime){
    close LIST;
    perm("$script");
    bbftp2farm($ctime,0);
}

print "\n\t finished running $prog \n\n\n";

1;

############################################################                         
#####     FUNCTIONS                                                                  
############################################################                         

sub usage{
    print "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
    print "USAGE: $prog [-m <exp>] filelist \n";
    print "\t -m <exp>     Match to POSIX regular expression <exp> \n";
    print "\t              Must be within single quotes to work \n";
    print "\t              $prog -m \'^\\w\\.[0-9]+\$\' \n";
#    print "\t -p <path>    Absolute path to directory to look in \n";
#    print "\t              No relative paths allowed \n";
#    print "\t              Default path is $basedir \n";
#    print "\t -D           Deletes directories where start reco event number is \n";
#    print "\t              greater than the number of events in the raw file \n";
#    print "\t -v           Verbose information printed out \n";
    print "\t -h,--help    Obviously to show this help \n";
    print "  http://www.troubleshooters.com/codecorn/littperl/perlreg.htm  \n";
    print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n\n";
}

