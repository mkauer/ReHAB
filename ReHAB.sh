#!/bin/bash

##########################################################
# this is a quick and dirty script so that you can send
# mother_reco to the farm manually if you want to.
# 'qsub -q medium ReHAB.sh'
#
# or you can just run this on your system if you want
##########################################################

here=`pwd`
runlist="$here/feb03-dec07_betabeta.list"
reco="$here/mother_reco.pl"
log="${USER}-logfile"

source $here/configReco.sh

$reco $runlist | tee $log

