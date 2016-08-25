#!/bin/bash
source /home/torre/NEMO3/ReHAB/configReco.sh

RECO_FILE_LIST=$1

if [ "$#" -eq 5 ]; then
    export RECO_BUNCHES=$2
    export RECO_EVT_PER_BUNCH=$3
    export RECO_LEVEL=$4
    SAMPLE_NAME=$5
else
    set_reconstruction_parameters $2
    SAMPLE_NAME=$3
fi

if [ `wc -l $RECO_FILE_LIST | cut -d' ' -f1` -eq 0 ]; then
    exit
fi

echo "---- processing : $RECO_FILE_LIST "

print_reconstruction_parameters

CRON_JOB_DIR=$INPUT_DIR/cronjobs

if [ -e $CRON_JOB_DIR/${USER}_RUNNING ]; then
    echo "-- $CRON_JOB_DIR/${USER}_RUNNING exists -> abort job "
    exit
else
    touch $CRON_JOB_DIR/${USER}_RUNNING
fi



JOBS_RUNNING=`qstat -u ${USER} | grep ${USER} | wc -l`
JOBS_PER_SUBMISSION=60
FILE_PER_SUBMISSION=$[ $JOBS_PER_SUBMISSION / $RECO_BUNCHES ]

if [ "$JOBS_RUNNING" -lt 440 ]; then
    echo "-- $JOBS_RUNNING jobs running"
    echo "-- Submitting reconstruction for $FILE_PER_SUBMISSION files"
    N_JOBS_IN_FILE=`wc -l $RECO_FILE_LIST | cut -d' ' -f1`
    echo "-- The job list $RECO_FILE_LIST contains $N_JOBS_IN_FILE file to be processed"

    if [ "$N_JOBS_IN_FILE" -gt "$FILE_PER_SUBMISSION" ]; then
	echo "-- Processing $FILE_PER_SUBMISSION files: "
	head -$FILE_PER_SUBMISSION $RECO_FILE_LIST > $CRON_JOB_DIR/${USER}_this_submit.list
    else
	echo "-- Processing the last $N_JOBS_IN_FILE files"
	cat $RECO_FILE_LIST > $CRON_JOB_DIR/${USER}_this_submit.list
    fi

    cat $CRON_JOB_DIR/${USER}_this_submit.list

    $INPUT_DIR/mother_reco.pl $CRON_JOB_DIR/${USER}_this_submit.list
    comm -3 $RECO_FILE_LIST $CRON_JOB_DIR/${USER}_this_submit.list > $CRON_JOB_DIR/${USER}_remaining.list
    mv $CRON_JOB_DIR/${USER}_remaining.list $RECO_FILE_LIST

    rm $CRON_JOB_DIR/${USER}_this_submit.list

    echo "-- Files still to be processed: `wc -l $RECO_FILE_LIST`"
    echo "---- end processing : $RECO_FILE_LIST"
fi

rm $CRON_JOB_DIR/${USER}_RUNNING