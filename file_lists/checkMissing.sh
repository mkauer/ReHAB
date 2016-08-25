#!/bin/sh
toDoFile=$1
doneFile=$2
prodInputFile=$3
stillToDo=$4

if [ `ls --color=none $stillToDo | wc -l` != 0 ]; then 
    rm $stillToDo
fi

touch $stillToDo

toDoList=`cat $toDoFile`

for theRun in $toDoList 
do
    echo "Checking for run " $theRun
    if [ `grep $theRun $doneFile | wc -l` == 0 ]; then
	echo "    $theRun is missing"
	grep $theRun $prodInputFile >> $stillToDo
    fi
done
