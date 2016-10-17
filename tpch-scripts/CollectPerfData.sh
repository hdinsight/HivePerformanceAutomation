#!/bin/bash
BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd );
echo "\$BENCH_HOME is set to $BENCH_HOME";

BENCHMARK=hive-testbench

if [ $# -eq 0 ]
then
	echo "Usage ./CollectPerfData.sh RESULTS_DIR PERFDATA_OUTPUTDIR SERVER"
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
echo "Running Scripts for Perf Data Collection ..."

mkdir $PERFDATA_OUTPUTDIR

./GetHiveQueryIds.sh $RESULTS_DIR $PERFDATA_OUTPUTDIR $SERVER
 
./GetATSDAG.sh $PERFDATA_OUTPUTDIR

cp -R $BENCH_HOME/$BENCHMARK/tpch-scripts/PAT-master/PAT/results $PERFDATA_OUTPUTDIR/pat

echo "Completed Running PerfData Collection Scripts"

zip -r $BENCH_HOME/$BENCHMARK/PerfData.zip $PERFDATA_OUTPUTDIR

echo "zipped Perfdata to $BENCH_HOME/$BENCHMARK/PerfData.zip"
