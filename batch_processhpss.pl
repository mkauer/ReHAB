#!/usr/bin/perl
use warnings;

############################################################
#
# Matt Kauer
# version:  09.04.21
#
# use this to process file output from rfdir -r from hpss
# this works if your files are in a logical directory structure
# ie ...
# /<...>/topdir
#        |--> exbg11
#               |--> ac228.list
#
# thie script will only search down 1 directory from the "topdir"
# change "$listsuffix" to change the outfiles you're looking for
$listsuffix=".list";
# change the "$filesuffix" to change the hpss file extension
$filesuffix=".ntup";
#
############################################################

if($#ARGV+1 > 1){
    print "USAGE: batch_processhpss.pl [top dir] \n";
    exit 1;
}elsif($#ARGV+1 == 1){
    $topdir=$ARGV[0];
}else{
    $topdir=`pwd`;
    chomp $topdir;
}

opendir TOPDIR, $topdir;
@toplist=readdir(TOPDIR);
chomp @toplist;
closedir TOPDIR;

for $topline(@toplist){
    if(-d "$topdir/$topline" && $topline ne "\." && $topline ne "\.\."){
	print "\n\n IN HERE  ==>  $topline \n";
	print "==================================================\n";
	opendir DIR, "$topdir/$topline";
	@list=readdir(DIR);
	chomp @list;
	closedir DIR;
	mkdir("$topdir/$topline/new");
	system("/bin/rm", "-f", "$topdir/$topline/new/*");
	
	for $line(@list){
	    if(-f "$topdir/$topline/$line" && $line =~ m/($listsuffix)$/){
		print "\n\t FIXING THIS ==>  $topline $line \n";
		print "\t--------------------------------------\n";
		open(INLIST,"$topdir/$topline/$line") || next;
		open(NEWLIST,">$topdir/$topline/new/$topline\_$line");
		print NEWLIST "\n";
		$curdir=0;
		while(<INLIST>){
		    chomp;
		    if($_ =~ s/.*(\/hpss.*):/$1/g){
			$curdir=$1
			}
		    if($curdir ne "0"){
			if($_ =~ s/(\w+$filesuffix)$/$1/g){
			    $file="$curdir\/$1";
			    print NEWLIST "$file\n";
			    print "\t\t $file \n";
			}
		    }
		}
		close INLIST;
		close NEWLIST;
	    }
	}
    }
}

