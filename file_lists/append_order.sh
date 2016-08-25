#!/bin/bash

inputFile=$1
outputFile=`echo "numbered_$inputFile"`

if [ -e $outputFile ]; then
    rm $outputFile
fi

touch $outputFile

nLines=`wc -l $inputFile | cut -f 1 -d ' '`
for (( line=1; line<=$nLines; line++ ))
do
    #echo "executing: head -$line $inputFile | tail -1"
    myLine=`head -$line $inputFile | tail -1`
    echo "$line $myLine" >> $outputFile
done