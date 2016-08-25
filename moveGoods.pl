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
my $version = '09.08.05';
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
my $force="--reply=no"; my $del=0;
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
    }elsif($ARGV[$i] eq "-f"){
	print "\nFORCING: an overwrite to rootfiles if they already exist \n";
        $force="--reply=yes";
    }elsif($ARGV[$i] eq "-D"){
        $del=1;
    }elsif($ARGV[$i] =~ m/^-v/){
	$V=1 if $ARGV[$i] eq "-v";
	$V=2 if $ARGV[$i] eq "-vv";
    }else{
	print "WARNING: skipping option \"$ARGV[$i]\" (see --help). \n";sleep 1;
    }
}

if(!$match){
    print "\nERROR: '-m' and <exp> were not specified (see --help). \n\n";
    exit 1;
}else{
    print "\nWARNING: make sure your POSIX regular expression is enclosed \n";
    print "         in single quotes (-m \'match\') on the command line. \n\n";
    print "Here is your expression, make sure it's correct: \n";
    print "\n  --->  ${exp} \n\n";sleep 1;
}

# initiallize the variables and arrays
my(@hpss);
my($tmp,$fullpath);
my $count=0;
printv("\nGoing into here  ==>  $topdir \n");
printv("=========================================================\n");
map{$tmp=$_;
    if($tmp =~ m/${exp}/){
	@hpss=file2array("$topdir/$tmp/hpss.path");
	if($#hpss==2){
	    $fullpath=$goodroots.$hpss[2];
	    my $stat=statusID($topdir,$tmp);
	    printv("status id -->  $stat  (0 means no errors) \n");
	    if($stat==0){
		if(-f "$topdir/$tmp/hpss.path"){
		    printv("copy to   -->  $fullpath \n");
		    if(mkDirP("$fullpath")){
			printv("copying   -->  $tmp rootfiles \n");
			system "/bin/cp $force -p --target-directory=$fullpath $topdir/$tmp/*\.root";
			if(size("$fullpath/$tmp.1e.root") && size("$fullpath/$tmp.root")){ 
			    print "SUCCESS   ==>  copy of $tmp \n";
			    if($del){
				print "DELETING  ==>  $topdir/$tmp \n";
				system "$rm $topdir/$tmp";
			    }
			}else{
			    print "FAILED    ==>  copy of $tmp \n";
			    $count++;
			}
		    }else{
			print "FAILED    ==>  mkdir of $fullpath \n";
			$count++;
		    }
		}else{
		    print "FAILED    ==>  $tmp/hpss.path : does not exist \n";
		    $count++;
		}
	    }else{
		print "FAILED    ==>  bad rootfiles in $tmp \n";
		$count++;
		if(size("$fullpath/$tmp.1e.root") && size("$fullpath/$tmp.root")){
		    print "SUCCESS   ==>  good rootfiles already exist for $tmp \n";
		    if($del){
			print "DELETING  ==>  $topdir/$tmp \n";
			system "$rm $topdir/$tmp";
		    }
		}
	    }
	}else{
	    print "FAILED    ==>  $tmp/hpss.path : in the wrong format \n";
	    $count++;
	}
	printv("\n");
    }
}sort(readDir("$topdir","dir"));


print "\n\nTOTAL FAILED: $count \n\n\n";


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
    print "\t -f           Forces a copy overwrite if the file already exists \n";
    print "\t -D           Deletes all temp files if a successful copy of files \n";
    print "\t -v           Verbose information printed out \n";
    print "\t -h,--help    Obviously to show this help \n";
    print "  http://www.troubleshooters.com/codecorn/littperl/perlreg.htm  \n";
    print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n\n";
}

