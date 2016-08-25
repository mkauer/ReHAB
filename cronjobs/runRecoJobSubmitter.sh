#!/bin/bash
RECOJOBLIST=$1

N_RECOJOBS=`wc -l $RECOJOBLIST | cut -d' ' -f1`
LOGTAG="`date` -- ${RECOJOBLIST} --"
echo "${LOGTAG} processing ${N_RECOJOBS} jobs"

this_job=1
while [ ${this_job} -le ${N_RECOJOBS} ]; do
    line=`head -${this_job} ${RECOJOBLIST} | tail -1`
    sample_name=`echo $line | cut -d' ' -f5` 
    if [ -z "$sample_name" ]; then 
	sample_name=`echo $line | cut -d' ' -f3`
    fi 
    echo "${LOGTAG} processing $line"
    touch /home/torre/NEMO3/ReHAB/cronjobs/${USER}_${sample_name}_reco.log
    /home/torre/NEMO3/ReHAB/cronjobs/recoJobSubmitter.sh ${line} >> /home/torre/NEMO3/ReHAB/cronjobs/${USER}_${sample_name}_reco.log 2>&1
    this_job=$[$this_job+1]
done