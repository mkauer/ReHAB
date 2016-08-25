#!/bin/sh
listOfMissingRuns=$1
prodInputFile=$2
stillToDo=$3

if [ `ls --color=none $stillToDo | wc -l` != 0 ]; then 
    rm $stillToDo
fi

touch $stillToDo

toDoList=`cat $listOfMissingRuns`

for theRun in $toDoList
do
    echo "Getting position of run " $theRun
    grep $theRun $prodInputFile >> $stillToDo
done


