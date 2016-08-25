#!/bin/bash

############################################################
# This script sets the global parameters for ReHAB!
# This must be sourced before running 'mother_reco.pl'.
# 'mother_reco.pl' will warn you if this file has not yet
# been sourced when you try to run her.
#
# version: 10.10.19
# author:  Matt Kauer
############################################################

#####  Must be the absolute path to where recoMod.pm is located.
#####  This is a standard environmental variable that Perl
#####  uses to find to user definded modules.
#export PERL5LIB=/home/kauer/NEMO/soft/ReHAB
export PERL5LIB=/unix/nemo2/n3/soft/ReHAB

#####  How much output to you want printed to std:out?
#export RECO_VERBOSE=0    # only warnings and errors are printed
export RECO_VERBOSE=1    # much information is printed
#export RECO_VERBOSE=2    # very much information is printed

#####  Are you testing or do you want to run the real deal?
export RECO_TESTING=0    # scripts created, and sent to farm
#export RECO_TESTING=1    # scripts created, nothing sent to farm
#export RECO_TESTING=2    # no scripts created, nothing sent to farm

#####  What level of reconstruction do you want to do?
#export RECO_LEVEL=0    # files will ONLY be downloaded
#export RECO_LEVEL=1    # only files needing downloading will get reco'd
export RECO_LEVEL=2    # full reconstrunction
#export RECO_LEVEL=3    # only already existing files will get reco'd

#####  Output dir where the scripts, logfiles, and reconstruced
#####  rootfiles will be placed.
export OUTPUT_DIR=/unix/nemo2/ktmp

#####  Directory where all the reco scripts, config files, 
#####  ssh-start.sh, ssh-stop.sh, hfix.cxx ect... are located.
#export INPUT_DIR=/home/kauer/NEMO/soft/ReHAB
export INPUT_DIR=/unix/nemo2/n3/soft/ReHAB

#####  Basedir of the N3Nemos package being used.
export NEMOS_DIR=/unix/nemo2/n3/soft/N3Nemos

#####  Binary directory for the 'nemor_1e+.x'.
export NEMOR_DIR=$NEMOS_DIR/analy/prog/bin.Linux

#####  Name of the binary
#export NEMOR_BIN=nemor_1e+.x
export NEMOR_BIN=nemor.x

#####  THIS IS NOT THE LIST OF RUNS YOU WANT RECONSTRUCTED!
#####  This is the list of betabeta runs that the MC will be
#####  reconstructed for.
#export RUN_LIST=$INPUT_DIR/feb03-dec07.runs
export RUN_LIST=$INPUT_DIR/feb03-jul10.runs

#####  The pc thats IP has been authorized by the BBFTP admin.
export MYPC=pc122.hep.ucl.ac.uk

#####  The location where successfully reconstructed files we be copied.
#export GOOD_ROOTS=/unix/nemo2/n3/reco_09.07.01
export GOOD_ROOTS=/unix/nemo2/n3/reco_ver_12

#####  Sources the paths and libs needed for the reconstruction.
source $INPUT_DIR/nemo3-env.sh

