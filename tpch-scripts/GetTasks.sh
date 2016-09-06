#!/bin/bash
BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd );

BENCHMARK=hive-testbench

if [ $# -eq 0 ]
then
	echo "Usage ./GetTasks.sh RESULTS_DIR PERFDATA_OUTPUTDIR SERVER"
	echo "Default Values will be used if you do not provide command line parameters"
fi

if [ -z $1 ]
then
	RESULTS_DIR=$BENCH_HOME/$BENCHMARK/results/
else
	RESULTS_DIR=$1
fi

if [ -z $2 ]
then
	PERFDATA_OUTPUTDIR=$BENCH_HOME/$BENCHMARK/PerfData/
else
	PERFDATA_OUTPUTDIR=$2
fi

if [ -z $3 ]
then
	SERVER=http://headnodehost:8188/ws/v1/timeline
else
	SERVER=$3
fi

echo "RESULTS_DIR is set to $RESULTS_DIR"
echo "PERFDATA_OUTPUTDIR is set to $PERFDATA_OUTPUTDIR"
echo "SERVER is set to $SERVER"

file="$PERFDATA_OUTPUTDIR/dagids.txt"
mkdir $PERFDATA_OUTPUTDIR/tasks
rm $PERFDATA_OUTPUTDIR/tasks/*
mkdir $PERFDATA_OUTPUTDIR/taskattempts
rm $PERFDATA_OUTPUTDIR/taskattempts/*

while read -r line
do
        echo "Getting tasks data for $line"
		read -a linearray <<< $line
		outfilename="${linearray[1]/dag/tasks}"
		curl  $SERVER/TEZ_TASK_ID?primaryFilter=TEZ_DAG_ID:${linearray[0]} > $PERFDATA_OUTPUTDIR/tasks/$outfilename.txt
        echo "Getting task attempts data for $line"
		outfilename="${linearray[1]/dag/taskattempts}"
		curl  $SERVER/TEZ_TASK_ATTEMPT_ID?primaryFilter=TEZ_DAG_ID:${linearray[0]} > $PERFDATA_OUTPUTDIR/taskattempts/$outfilename.txt
done < $file
