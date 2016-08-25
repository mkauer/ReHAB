package recoMod;
use v5.8.5;
use strict;
use warnings;
require Exporter;


our $AUTHOR  = 'Matt Kauer (kauer@hep.ucl.ac.uk)';
our $VERSION = '10.10.19';


# PUBLIC FUNCTION AND VARIABLE DECLAIRATIONS!
##################################################
our @ISA = qw(Exporter);
#our %EXPORT_TAGS = ('all'=>[qw()]);
#our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});
our @EXPORT = qw(

$V $T $L
$basedir $indir
$nemosroot $nemorroot $nemorbin $runlist
$goodroots
$user $pc
$cmddir $bbftpdir $logdir $rawdir $scriptdir

new
info
status
goodVars
printGlobals

noWS
cleanStr
size
firstBit
lastBit
subLine
fileName
fileType
mkDirP
checkDirs
linkStuff

createBBFTP
createNemor
createScript
toFarm
toSystem

hpssPath
splitByType
bbftp2farm
bbftpDownload2farm

readDir
file2array
firstEvent
procEvent
nemorLog
errDST
errRoot
errBBFTP
errRawD
errRawH
statusID

perm
permtmp
printv
printvv

);

# PUBLIC VARIABLES
##################################################
chomp(our $V=`echo \${RECO_VERBOSE}`);
chomp(our $T=`echo \${RECO_TESTING}`);
chomp(our $L=`echo \${RECO_LEVEL}`);

chomp(our $basedir=`echo \${OUTPUT_DIR}`);
chomp(our $indir=`echo \${INPUT_DIR}`);

chomp(our $nemosroot=`echo \${NEMOS_DIR}`);
chomp(our $nemorroot=`echo \${NEMOR_DIR}`);
chomp(our $nemorbin=`echo \${NEMOR_BIN}`);
chomp(our $runlist=`echo \${RUN_LIST}`);
chomp(our $goodroots=`echo \${GOOD_ROOTS}`);

chomp(our $user=`echo \${USER}`);
chomp(our $pc=`echo \${MYPC}`);

# PUBLIC VARIABLES
##################################################
# BBFTP scripts and logfiles will be put here
our $cmddir     = "$basedir/tmp_cmds";
# batchfarm logfiles for bbftp will be put here
our $bbftpdir   = "$basedir/tmp_bbftp";
# logfiles from the batchfarm will be put here
our $logdir     = "$basedir/tmp_logs";
# raw betabeta and MC files will be put here
our $rawdir     = "$basedir/tmp_raw";
# temp scripts will be put in here
our $scriptdir  = "$basedir/tmp_scripts";

# PRIVATE VARIABLES
##################################################
# name of the h11 --> h10 root macro
my $h10fix     = "hfix.cxx";
# mysql server name
my $server     = "db1.hep.ucl.ac.uk";
# mysql port to use
my $port       = 0; #was 3306
# laser time correction version to use
my $ltc_ver    = 12; #was 5
# how many bunches to split MC into
my $bunches    = 1; #was 10
# how many events per bunch to reconstruct
my $recobunch  = 1000000; #was 100000
# how many times to attempt downloading from Lyon
my $bbftpretry = 3;
##################################################

sub new{
    my $package=shift;
    return bless({},$package);
}

sub info($$){
    my($prog,$version)=@_;
    print "\n----------------------------------------------\n";
    print "  program:  $prog \n";
    print "  author:   $AUTHOR \n";
    print "  version:  $version \n";
    print "  you are:  $user \n";
    print "----------------------------------------------\n\n";
}

sub status{
    print "\n====================================================================\n";
    print "  Testing mode $T --> scripts being created, and sent to farm \n" if $T==0;
    print "  Testing mode $T --> scripts being created, but not sent to farm \n" if $T==1;
    print "  Testing mode $T --> no scripts created, nothing sent to farm \n" if $T==2;
    print " Level of reco $L --> files will only be downloaded \n" if $L==0;
    print " Level of reco $L --> only files being downloaded will be reco\'d \n" if $L==1;
    print " Level of reco $L --> the full reconstruction will be done \n" if $L==2;
    print " Level of reco $L --> only already existing files will be reco\'d \n" if $L==3;
    print "====================================================================\n\n";
    sleep 2;
}

sub testVars{
    print "\n\tRECO_VERBOSE   variable is not set" if $V ne 0 && $V ne 1 && $V ne 2;
    print "\n\tRECO_TESTING   variable is not set" if $T ne 0 && $T ne 1 && $T ne 2;
    print "\n\tRECO_LEVEL     variable is not set" if $L ne 0 && $L ne 1 && $L ne 2 && $L ne 3;
    print "\n\tOUTPUT_DIR     Variable is not set" if ! -d $basedir;
    print "\n\tINPUT_DIR      variable is not set" if ! -d $indir;
    print "\n\tNEMOS_DIR      variable is not set" if ! -d $nemosroot;
    print "\n\tNEMOR_DIR      variable is not set" if ! -d $nemorroot;
    print "\n\tNEMOR_BIN      variable is not set" if ! -f "$nemorroot/$nemorbin";
    print "\n\tRUN_LIST       variable is not set" if ! -f $runlist;
    print "\n\tGOOD_ROOTS     variable is not set" if ! -d $goodroots;
    print "\n\tMYPC           variable is not set" if $pc eq "";
    print "\n";
    return 1;
}

sub goodVars{
    if(testVars()){
	return 0 if $V ne 0 && $V ne 1 && $V ne 2;
	return 0 if $T ne 0 && $T ne 1 && $T ne 2;
	return 0 if $L ne 0 && $L ne 1 && $L ne 2 && $L ne 3;
	return 0 if ! -d $basedir;
	return 0 if ! -d $indir;
	return 0 if ! -d $nemosroot;
	return 0 if ! -d $nemorroot;
	return 0 if ! -f "$nemorroot/$nemorbin";
	return 0 if ! -f $runlist;
	return 0 if ! -d $goodroots;
	return 0 if $pc eq "";
	return 1;
    }else{
	return 0;
    }
}

sub printGlobals{
    print "\n GLOBAL VARIABLES \n";
    print "======================================================================\n";
    print "verbose     = $V \n";
    print "testing     = $T \n";
    print "level       = $L \n";
    print "\n";
    print "basedir     = $basedir \n";
    print "indir       = $indir \n";
    print "nemosroot   = $nemosroot \n";
    print "nemorroot   = $nemorroot \n";
    print "nemorbin    = $nemorbin \n";
    print "runlist     = $runlist \n";
    print "goodroots   = $goodroots \n";
    print "user        = $user \n";
    print "pc          = $pc \n";
    print "======================================================================\n\n";
}


sub noWS($){
    my($string)=@_;
    #$string =~ s/(\f|\a|\e|\r|\n)//;
    $string =~ s/^(\s|\t)*//;
    $string =~ s/(\s|\t)*$//;
    return $string;
}

sub cleanStr($){
    my($string)=@_;
    $string =~ s/(\f|\a|\e|\r|\n)//;
    $string =~ s/^(\s|\t)*//;
    $string =~ s/(\s|\t)*$//;
    return $string;
}

sub size($){
    my($file)=@_;
    if(! -f $file){
	printv("filesize  -->  does not exist \n");
	return 0;
    }
    my $size= -s $file;
    printv("filesize  -->  $size \n");
    return $size;
}

sub firstBit($){
    my($line)=@_;
    my(@tmp,$bit);
    @tmp=split('\/',$line);
    if($tmp[0] eq "" && $tmp[1]){
	$bit=$tmp[1];
    }else{
	$bit=$tmp[0];
    }
    return noWS($bit);
}

sub lastBit($){
    my($line)=@_;
    my(@tmp,$bit);
    @tmp=split('\/',$line);
    $bit=$tmp[$#tmp];
    return noWS($bit);
}

sub subLine($$$){
    my($line,$foward,$backward)=@_;
    my(@tmp,$end);
    my $bit="";
    @tmp=split('\/',$line);
    $end=$#tmp-$backward;
    for(my $i=$foward;$i<=$end;$i++){
	$bit=$bit."/".$tmp[$i];
    }
    return noWS($bit);
}

sub fileName($){
    my($line)=@_;
    my(@tmp,$bit);
    $bit=lastBit($line);
    @tmp=split('\.',$bit);
    if($tmp[0] eq "" && $tmp[1]){
        $bit=$tmp[1];
    }else{
        $bit=$tmp[0];
    }
    return noWS($bit);
}

sub fileType($){
    my($line)=@_;
    my(@tmp,$bit,$bit1,$bit2);
    $bit=lastBit($line);
    @tmp=split('\.',$bit);
    $bit1=$tmp[$#tmp-1];
    $bit2=$tmp[$#tmp];
    
    return 'MTCA'  if $bit2 =~ m/ntup/;
    return 'MTCAZ' if $bit1 =~ m/ntup/ && $bit2 =~ m/gz/;
    return 'REAL'  if $bit2 =~ m/rz/;
    return 'BA'    if $bit2 =~ m/ba/;
}

sub mkDirP($){
    my($fullpath)=@_;
    my(@tmp); my $bit="";
    @tmp=split('\/',$fullpath);
    for(my $i=1;$i<=$#tmp;$i++){
	$bit=$bit."/".$tmp[$i];
	if(! -d $bit){
	    system "/bin/mkdir --mode=0770 $bit";
	}
    }
    return 0 if ! -d $fullpath;
    return 1 if -d $fullpath;
}

sub checkDirs{
    mkDirP("$cmddir") if ! -d $cmddir;
    mkDirP("$bbftpdir") if ! -d $bbftpdir;
    mkDirP("$logdir") if ! -d $logdir;
    mkDirP("$rawdir") if ! -d $rawdir;
    mkDirP("$scriptdir") if ! -d $scriptdir;
}

sub linkStuff($){
    my($filedir)=@_;
    checkDirs();
    my $workdir="$basedir/$filedir/work";
    mkDirP("$workdir/analyresul");
    system "cp -f $nemorroot/$nemorbin $workdir";
    system "cp -f $indir/hfix.cxx $workdir";
    symlink "$nemosroot/simul/geom","$workdir/simulgeom";
    symlink "$rawdir","$workdir/nemodata";
}

sub createBBFTP($){
    my($hpssline)=@_;
    my($script,$bbftp,$ssh,$log,@sshlist);
    my $longname=lastBit($hpssline);
    my $shortname=fileName($hpssline);
    my $thisUser;
    if(${user} eq "af") {
      $thisUser = "freshvil";
    } else {
      $thisUser = ${user}
    }
    if($hpssline =~ m/hpss\/in2p3.fr/ && ! -f "$rawdir/$longname"){
	printv("\n$hpssline \n");
	printv("------------------------------------------------------------\n");
	if(errBBFTP($hpssline)){
	    $script="$cmddir/$shortname.cmd";
	    if($T<2){	
		printv("creating  -->  $script \n");
		open BBFTPCMD, ">$script";
		print BBFTPCMD "setoption remoterfio \n";
		#print BBFTPCMD "get $hpssline $rawdir/$longname \n";
		print BBFTPCMD "get cchpssnemo.in2p3.fr:$hpssline $rawdir/$longname \n";
		close BBFTPCMD;
		perm($script);
	    }else{
		printv("no create -->  $script \n");
	    }
	    $log="$bbftpdir/$shortname.bbftp.log";
	    $bbftp="bbftp -V -m -i $script -u $thisUser -s ccbbftp.in2p3.fr -r 3 -p 3 >$log 2>&1";
	    printv("\n");
	    return "$bbftp";
	}else{
	    print "\nReHAB-ERROR: i cannot find $rawdir/$longname \n\n";
	    return "error";
	}
    }elsif(-f $hpssline && ! -f "$rawdir/$longname"){
	printv("linking   -->  $hpssline \n");
	symlink "$hpssline","$rawdir/$longname";
	return "doit";
    }elsif(-f "$rawdir/$longname"){
	print "\nAWESOME   ==>  $rawdir/$longname already exists ";
	return "doit";
    }else{
	print "\nReHAB-ERROR: cannot find $hpssline \n\n";
	return "error";
    }    
}

sub createNemor($$$$$){
    my($filedir,$datatype,$nfirst,$nlast,$mcfile)=@_;
    my $workdir="$basedir/$filedir/work";
    my $flis=1;
    $flis=0 if $datatype eq "REAL" || $datatype eq "BA";
    my $script="$workdir/nemor.dat";
    if($T<2){
	printv("creating  -->  $script \n");
	open NDAT, ">$script";
	print NDAT "LIST \n";
	print NDAT "JUMP      $nfirst \n";   # starting event number you want reco'd
	print NDAT "TRIGGERS  $nlast \n";    # ending event number you want reco'd
	print NDAT "DEBUG     0 0 1000 \n";
	print NDAT "SWIT      0 0 0 0 0 0 0 0 0 0 \n";
	print NDAT "TIME      2=10. 3=-10000000 \n";
	print NDAT "TVER      $ltc_ver \n";  # laser time corrections version
	print NDAT "GET       'INIT','NTUP' \n";
	#print NDAT "SAVE      'INIT' \n";   # generate new 'NEMO_P2.INIT' binary
	print NDAT "SAVE      'NTUP' \n";
	print NDAT "DATA      '$datatype' \n";
	print NDAT "FILE      '$filedir' \n";
	#print NDAT "TSRV      44 1 \n";
	print NDAT "MCLIS     'YES' \n";     # points to the rawfile you want reco'd
	if($flis!=0){
	    symlink "$runlist","$workdir/list10.files";
	    symlink "$runlist","$workdir/list.files";
	    print NDAT "FLIS      'YES' \n"; # use betabeta runlist for MC reco
	}
	print NDAT "SERVER    '$server' \n"; # MySQL server name/ip
	if($port!=0){
	    print NDAT "PORT      $port \n"; # MySQL server port
	}
	print NDAT "META      'YES' \n";
	#print NDAT "DRAW      'YES' \n";    # gives an error
	print NDAT "END \n\n";
	close NDAT;
	symlink "$workdir/nemor.dat","$workdir/fort.4";
	symlink "/unix/nemo2/n3/soft/N3Nemos_10.09.27/db/prog/input_db_peak.dat","$workdir/input_db_peak.dat";
	perm($script);
    }else{
        printv("no create -->  $script \n");
    }
    $script="$workdir/mclist.files";
    if($T<2){
	printv("creating  -->  $script \n");
	open MCFILE,">$script";
	#############################################
	#print MCFILE "$workdir/nemodata/$mcfile \n";
	# to make pathnames less 80 characters
	print MCFILE "$rawdir/$mcfile \n";
	#############################################
	close MCFILE;
	perm($script);
    }else{
        printv("no create -->  $script \n");
    }
    perm("$rawdir/$mcfile");
}


sub createScript($){
    my($filename)=@_;
    my $script="$scriptdir/$filename.sh";
    if($T<2){
	printv("creating  -->  $script \n");
	open OUTF, ">$script";
	print OUTF "\#!/bin/bash \n\n";
	print OUTF "source $indir/configReco.sh \n";
	print OUTF "$indir/child_reco.pl -file $filename \n\n";
	print OUTF "\n\n";
	close OUTF;
	perm($script);
    }else{
        printv("no create -->  $script \n");
    }

    return $script;
}

sub toFarm($$){
    my($script,$que)=@_;
    if($T==0){
	printv("toFarm    -->  $que  $script \n");
	system "qsub -p 100 -q $que -j oe -o $logdir $script";
    }else{
	printv("no toFarm -->  $que  $script \n");
    }
}

sub toSystem($){
    my($script)=@_;
    printv("toSystem  -->  $script \n");
    system "$script" if $T==0;
}

sub hpssPath($$){
    my($line,$filedir)=@_;
    mkDirP("$basedir/$filedir");
    my $script="$basedir/$filedir/hpss.path";
    if($line =~ /hpss\/in2p3.fr/){
	my $subpath=subLine($line,6,1);
	if($T<3){
	    printv("creating  -->  $script \n");
	    open HPSS, ">$script";
	    print HPSS "$filedir\n";
	    print HPSS "$line\n";
	    print HPSS "$subpath\n";
	    close HPSS;
	    perm($script);
	}else{
	    printv("no create -->  $script \n");
	}
    }else{
	if(! -f $script){
	    print "\nReHAB-WARNING: no hpss.path created in $filedir because your runlist \n";
	    print   "      is not in /hpss/in2p3.fr/... format. Please submit a runlist with \n";
	    print   "      the full /hpss/in2p3.fr/... paths. Do not worry, ReHAB will not \n";
	    print   "      re-download any files already located in $rawdir \n\n";
	}    
    }
}

sub splitByType($){
    my($line)=@_;
    my($firstbit,$rawfile,$name,$type);
    my($i,$j,$nfirst,$nlast,$newname,$script);
    $firstbit=firstBit($line);
    $rawfile=lastBit($line);
    $name=fileName($line);
    $type=fileType($line);
    printv("\n$firstbit .... $rawfile  ==>  $type   \n");
    printv("------------------------------------------------------------\n");
    if($type eq "MTCA" || $type eq "MTCAZ"){
        for($i=0;$i<$bunches;$i++){
            $nfirst = $i*$recobunch;
            $nlast  = $nfirst+$recobunch;
            $j=$i+1;
            $j=sprintf("%02d",$j);
            $newname=$name."_".$j;
            printv("newname   -->  $newname \n");
            hpssPath($line,$newname);
	    if(errRoot("$basedir/$newname","1e") || errRoot("$basedir/$newname","2e")){
		linkStuff($newname);
		createNemor($newname,$type,$nfirst,$nlast,$rawfile);
		$script=createScript($newname);
		toFarm($script,"medium");
	    }else{
		print "AWESOME   ==>  $newname rootfiles are good! \n";
	    }
	    printv("\n");
        }
    }
    if($type eq "REAL" || $type eq "BA"){
        $nfirst = 0;
        $nlast  = 1000000;
	hpssPath($line,$name);
        if(errRoot("$basedir/$name","1e") || errRoot("$basedir/$name","2e")){
	    linkStuff($name);
	    createNemor($name,$type,$nfirst,$nlast,$rawfile);
	    $script=createScript($name);
	    toFarm($script,"medium");
	}else{
	    print "AWESOME   ==>  $name rootfiles are good! \n";
	}
    }
    printv("\n\n");
}

sub bbftp2farm($$){
    my($ctime,$iter)=@_;
    $iter=int($iter);
    $iter=0 if $iter<0;
    if($iter<$bbftpretry){    
	my $que="medium";
	my $ssh="ssh -Av -i /home/${user}/.ssh/bbftp-key ${user}\@${pc}";
	my $bbftp="$indir/bbftp_reco.pl -time $ctime -num $iter | tee $bbftpdir/$user-current.log";
	my $source="source $indir/configReco.sh";
	my $log="$bbftpdir/$ctime.ssh.log";
	my $script="$bbftpdir/${ctime}-bbftp.sh";
	printv("\n\nTHE DOWNLOAD SCRIPT  ==>  $script  \n");
	printv("============================================================\n");
	if($T<2){
	    printv("creating  -->  $script \n");
	    open OUTF, ">$script";
	    print OUTF "\#!/bin/bash \n\n";
	    print OUTF "source $indir/configReco.sh \n";
	    print OUTF "source $indir/ssh-start.sh $user \n\n";
	    print OUTF "$ssh \'$source;$bbftp\' >$log 2>&1 \n";
	    print OUTF "source $indir/ssh-stop.sh \n";
	    print OUTF "\n\n";
	    close OUTF;
	    perm($script);
	}else{
	    printv("no create -->  $script \n");
	}
	if($T==0 && $L<3){  ### was $L<2 but changed for download only mode
	    printv("toFarm    -->  $que  $script \n");
	    system "qsub -p 1000 -q $que -j oe -o $bbftpdir $script";
	}else{
	    printv("no toFarm -->  $que  $script \n");
	}
    }
    my $left=$bbftpretry-$iter;
    print "\n\n+++++++++++++++++++++++++++++++++++++++++++++\n";
    print "ReHAB-WARNING: $left download retries remaining. \n" if $left>0;
    print "FATAL: no more download retries. \n" if $left==0;
    print "+++++++++++++++++++++++++++++++++++++++++++++\n\n\n";
}

sub readDir($$){
    my($dir2read,$type)=@_;
    my(@keep,$entry);
    if($type =~ m/^d/){
	$type=1;
    }elsif($type =~ m/^f/){
	$type=2;
    }elsif($type =~ m/^a/ || $type =~ m/^e/){
	$type=3;
    }else{
	$type=0;
    }    
    die "\nReHAB-ERROR: invalid type option for readDir() \n\n" if $type==0;
    opendir DIR,$dir2read;
    while($entry=readdir(DIR)){
	push(@keep,"$entry") if $type==1 && -d "$dir2read/$entry" && "$entry" !~ m/^\.+$/;
	push(@keep,"$entry") if $type==2 && -f "$dir2read/$entry" && "$entry" !~ m/^\.+$/;
	push(@keep,"$entry") if $type==3 && -e "$dir2read/$entry" && "$entry" !~ m/^\.+$/;
    }
    closedir DIR;
    return @keep;
}

sub firstEvent($){
    my($dir)=@_;
    my(@lines,$tmp,@words);
    my $here=0;
    $here="$basedir/$dir" if -f "$basedir/$dir/work/nemor.log";
    $here="$dir" if -f "$dir/work/nemor.log";
    if($here){
        my $first=-1;
        chomp(@lines=`head -n 60 "$here/work/nemor.log"`);
        map{$tmp=cleanStr($_);
            if($tmp =~ m/DATA CARD CONTENT.*JUMP/i){
                @words=split('JUMP',$tmp);
		$first=cleanStr($words[1]);
		return $first;
	    }
	}reverse(@lines);
	return $first;
    }else{
	#print "\nReHAB-WARNING: did not find nemor.log \n\n";
        return -1;
    }
}

sub procEvent($){
    my($dir)=@_;
    my(@lines,$tmp,@words);
    my $here=0;
    $here="$basedir/$dir" if -f "$basedir/$dir/work/nemor.log";
    $here="$dir" if -f "$dir/work/nemor.log";
    if($here){
	my $processed=-1;
	chomp(@lines=`head -n 260 "$here/work/nemor.log"`);
        map{$tmp=cleanStr($_);
            if($tmp =~ m/TOTAL NUMBER OF EVENTS IN NTUPLES/i){
                @words=split('-',$tmp);
                $processed=cleanStr($words[0]);
		return $processed;
	    }
	    if($tmp =~ m/START ANALYSIS OF RUN.*it contains.*events/i){
                @words=split(' ',$tmp);
                $processed=cleanStr($words[7]);
		return $processed;
	    }
	}reverse(@lines);
	return $processed;
    }else{
	#print "\nReHAB-WARNING: did not find nemor.log \n\n";
	return -1;
    }
}

sub nemorLog($){
    my($dir)=@_;
    my($tmp);
    my $here=0;
    $here="$basedir/$dir" if -f "$basedir/$dir/work/nemor.log";
    $here="$dir" if -f "$dir/work/nemor.log";
    if($here){
	my $first=firstEvent($here);
	my $proc=procEvent($here);
	return "$first / $proc" if $first >= 0 && $proc >= 0
	    && $first >= $proc;
	chomp(my @lines=`tail -n 60 "$here/work/nemor.log"`);
        for(my $i=$#lines;$i>=0;$i--){
            $tmp=cleanStr($lines[$i]);
            return 0 if $tmp =~ m/20 HIGZ/;
            return $tmp if $tmp =~ m/error to read piedestal/i;
            return $tmp if $tmp =~ m/can not connect data base/i;
            return $tmp if $tmp =~ m/file is not found/i;
            return $tmp if $tmp =~ m/file .* does not exist/i;
            return $tmp if $tmp =~ m/error to read laser time correction/i;
	    return $tmp if $tmp =~ m/MaxNumberOfSegments exceeds/i;
	}
        return "---UNKNOWN---";
    }else{
        return "ReHAB-WARNING: did not find the nemor.log";
    }
}

sub errDST($$){
    my($dir2read,$type)=@_;
    my($file,$tmp);
    if($type eq "e" || $type eq "1e"){
        $type=1;
    }elsif($type eq "ee" || $type eq "2e"){
        $type=2;
    }else{
        $type=0;
    }
    die "\nReHAB-ERROR: invalid type option for errDST() \n\n" if $type==0;
    $file="notafile";
    my $dstdir="$dir2read/work/analyresul";
    for $tmp(readDir("$dstdir","file")){
        $file="$tmp" if $type==1 && $tmp =~ m/101e\.dst$/;
        $file="$tmp" if $type==2 && $tmp =~ m/10\.dst$/;
    }
    my $status=3;
    $status=2 if -f "$dstdir/$file";
    #$status=1 if $status==2 && -s "$dstdir/$file" <= 49152;
    $status=0 if $status==2 && ! nemorLog($dir2read);
    
    printv("dstfile   -->  1e not found \n") if $status==3 && $type==1;
    printv("dstfile   -->  2e not found \n") if $status==3 && $type==2;
    printv("dstfile   -->  $file : exists but errors \n") if $status==2;
    #printv("dstfile   -->  $file : exists but 0 events \n") if $status==1;
    printv("dstfile   -->  $file : good \n") if $status==0;
    
    return $status;
}

sub errRoot($$){
    my($dir2read,$type)=@_;
    my($file,$tmp);
    if($type eq "e" || $type eq "1e"){
	$type=1;
    }elsif($type eq "ee" || $type eq "2e"){
	$type=2;
    }else{
	$type=0;
    }    
    die "\nReHAB-ERROR: invalid type option for errRoot() \n\n" if $type==0;
    $file="notafile";
    for $tmp(readDir("$dir2read","file")){
	$file="$tmp" if $type==1 && $tmp =~ m/1e\.root$/;
	$file="$tmp" if $type==2 && $tmp =~ m/\.root$/ && $tmp !~ m/1e\.root$/;
    }
    my $status=3;
    $status=2 if -f "$dir2read/$file";
    #$status=1 if $status==2 && $type==1 && -s "$dir2read/$file" <= 6402;
    #$status=1 if $status==2 && $type==2 && -s "$dir2read/$file" <= 6956;
    $status=0 if $status==2 && ! nemorLog($dir2read);
    
    printv("rootfile  -->  1e not found \n") if $status==3 && $type==1;
    printv("rootfile  -->  2e not found \n") if $status==3 && $type==2;
    printv("rootfile  -->  $file : exists but errors \n") if $status==2;
    #printv("rootfile  -->  $file : exists but 0 events \n") if $status==1;
    printv("rootfile  -->  $file : good \n") if $status==0;
    
    return $status;
}

sub errBBFTP($){
    my($hpssline)=@_;
    my $file=lastBit($hpssline);
    my(@errors);
    my $status=3;
    if(-f "$bbftpdir/$file.bbftp.log"){
	map{push(@errors,$_) if $_ =~ m/BBFTP-ERROR/ || $_ =~ m/permission denied \(publickey,password\)/i}file2array("$cmddir/$file.ssh.log");
    }
    $status=0 if -f "$rawdir/$file";
    map{print "$_ \n"}@errors if $status>0 && $#errors>=0 && $V>0;
    return $status;
}

sub errRawH($){
    my($hpssline)=@_;
    my $file=lastBit($hpssline);
    my $status=3;
    $status=0 if -f "$rawdir/$file";
    printv("rawfile   -->  cannot find $file \n") if $status==3;
    printv("rawfile   -->  $file : exists \n") if $status==0;
    return $status;
}

sub errRawD($){
    my($dir2read)=@_;
    my(@lines,@look,$here);
    my $status=3; my $file="none";
    push(@look,"$dir2read/work/mclist.files");
    push(@look,"$dir2read/hpss.path");
    my $i=0;
    while($look[$i] && $status){
	$here=$look[$i];
	if(-f $here){
	    printvv("checking  -->  $here \n");
	    @lines=file2array($here);
	    $status=2;
	    $file="none";
	    map{
		$file=lastBit("$_");
		$status=0 if -f "$rawdir/$file";
	    }@lines;
	}else{
	    printv("filelist  -->  $here : does not exist \n");
	}
	$i++;
    }
    print "\nReHAB-WARNING: cannot find mclist.files or hpss.path \n\n" if $status==3;
    print "\nReHAB-WARNING: error reading mclist.files or hpss.path \n\n" if $status==2;
    printv("rawfile   -->  $file : exists \n") if $status==0;
    return $status;
}

sub statusID($$){
    my($topdir,$dir)=@_;
    my $here="$topdir/$dir";
    printv("Scanning  ==>  $dir \n");
    printv("------------------------------------------\n");
    my $badraw=0; my $baddst=0; my $badroot=0;
    $badraw=100 if errRawD($here);
    $baddst=10 if errDST($here,"1e");
    $baddst=20 if errDST($here,"2e");
    $badroot=1 if errRoot($here,"1e");
    $badroot=2 if errRoot($here,"2e");
    my $status=$badraw+$baddst+$badroot;
    return $status;
}

sub checkGood($){
    my($hpssline)=@_;
    
    return 0;    
}

sub file2array($){
    my($file)=@_;
    my @tmps;
    if(-f "$file"){
	system "dos2unix --quiet $file";
	open(INFILE,"$file");
	@tmps=<INFILE>;
	close INFILE;
	chomp @tmps;
    }else{
	die "\nReHAB-ERROR: $file : does not exist \n\n";
    }
    return @tmps;
}

sub perm($){
    my($file)=@_;
    if(-f $file){
	system "chmod -v 0770 $file" if $V>2;
	system "chown -v :nemo $file" if $V>2;
	system "chmod --silent 0770 $file" if $V<3;
	system "chown --silent :nemo $file" if $V<3;
    }elsif(-d $file){
	system "chmod -Rv 0770 $file" if $V>2;
        system "chown -Rv :nemo $file" if $V>2;
	system "chmod -R --silent 0770 $file" if $V<3;
        system "chown -R --silent :nemo $file" if $V<3;
    }else{
	print "\nReHAB-ERROR: $file : does not exist \n\n";
    }
}

sub permtmp{
    perm("$cmddir");
    perm("$bbftpdir");
    perm("$logdir");
    perm("$rawdir");
    perm("$scriptdir");
}

sub printv($){
    my($stuff)=@_;
    print "$stuff" if $V>0;
}

sub printvv($){
    my($stuff)=@_;
    print "$stuff" if $V>1;
}


1;
__END__

