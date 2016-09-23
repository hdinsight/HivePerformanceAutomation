#!/bin/bash
BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd );

BENCHMARK=hive-testbench
if [ $# -eq 0 ]
then
	echo "Usage ./GetVertices.sh RESULTS_DIR PERFDATA_OUTPUTDIR SERVER"
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
mkdir $PERFDATA_OUTPUTDIR/vertices
rm $PERFDATA_OUTPUTDIR/vertices/*

while read -r line
do
        echo "Getting vertices data for $line"
		read -a linearray <<< $line
		outfilename="${linearray[1]/dag/vertices}" 
        curl  $SERVER/TEZ_VERTEX_ID?primaryFilter=TEZ_DAG_ID:${linearray[0]} > $PERFDATA_OUTPUTDIR/vertices/$outfilename.txt
done < $file

