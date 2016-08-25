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
my $version = "09.08.05";
############################################################
my $startime=time;

# get my name and directory of where i am
chomp(my $prog=`basename $0`);
chomp(my $topdir=`pwd`);

goodVars || die "\n\tFATAL: variables are not right, please do:
\tsource /unix/nemo2/n3/soft/ReHAB/configReco.sh \n\n";

# print info and global variables being used
info($prog,$version);
printGlobals;

my($filename);
for(my $i=0;$i<$#ARGV;$i++){
    if($ARGV[$i] eq "-file"){
	$i++;
	$filename=$ARGV[$i];
    }
}

print "\nFILENAME: $filename \n\n";

my $outdir="$basedir/$filename";
my $workdir="$outdir/work";
my $analy="$workdir/analyresul";

if(-d $workdir){
    chdir $workdir;
    if( ! -f "$outdir/RUNNING"){
	system "echo -e 'RUNNING\ndo not delete this file\n' > $outdir/RUNNING";
	if(errDST($outdir,"1e") || errDST($outdir,"2e")){    
	    print "\nRECONSTRUCTION: beginning \n\n";
	    system "/bin/rm -fv $analy/*";
            perm("$workdir/$nemorbin");
	    system "$workdir/$nemorbin 10 >$workdir/nemor.log 2>&1";
	    print "\nRECONSTRUCTION: finished \n\n";
	}else{
            print "\nRECONSTRUCTION: bypassed : dst files are large \n\n";
        }
	if(! errDST($outdir,"1e") && ! errDST($outdir,"2e")){    
	    print "\nH2ROOT: beginning \n\n";
	    system "/bin/rm -fv $workdir/*\.root";
	    system "h2root $analy/nemor10.dst $analy/$filename.root >$workdir/root.log";
	    system "h2root $analy/nemor101e.dst $analy/1e.root >>$workdir/root.log";
	    system "root -l -b -q hfix.cxx >>$workdir/root.log";
	    system "mv -fv $analy/$filename.root $outdir/$filename.root";
	    system "mv -fv $analy/1e1.root $outdir/$filename.1e.root";
	    system "/bin/rm -fv $analy/1e.root";
	    print "\nH2ROOT: finished \n\n";
	}else{
	    print "\nRECONSTRUCTION: failed : dst files are small \n\n";
	    print "\nH2ROOT: bypassed : failed reconstruction \n\n";
	}
	perm("$outdir");
	system "/bin/rm -fv $outdir/RUNNING";
    }else{
	print "\nERROR: someone else is already running this \n\n";
    }
}else{
    print "\nERROR: could not find $workdir \n\n";
}

permtmp();

my $endtime=time;
my $runtime=($endtime-$startime)/60;
print "\nRUNTIME: $runtime minutes \n\n";

1;

