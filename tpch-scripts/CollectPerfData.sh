#!/bin/bash
BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd );
echo "\$BENCH_HOME is set to $BENCH_HOME";

BENCHMARK=hive-testbench

if [ $# -eq 0 ]
then
	echo "Usage ./CollectPerfData.sh RUN_ID RESULTS_DIR PERFDATA_OUTPUTDIR SERVER"
	echo "Default Values will be used if you do not provide command line parameters"
fi

if [ -z $1 ]
then
	RUN_ID=1
else
	RUN_ID=$1
fi

if [ -z $2 ]
then
	RESULTS_DIR=$BENCH_HOME/$BENCHMARK/results_$RUN_ID/
else
	RESULTS_DIR=$2
fi

if [ -z $3 ]
then
	PERFDATA_OUTPUTDIR=$BENCH_HOME/$BENCHMARK/PerfData_$RUN_ID/
else
	PERFDATA_OUTPUTDIR=$3
fi

if [ -z $4 ]
then
	SERVER=http://headnodehost:8188/ws/v1/timeline
else
	SERVER=$4
fi

echo "RESULTS_DIR is set to $RESULTS_DIR"
echo "PERFDATA_OUTPUTDIR is set to $PERFDATA_OUTPUTDIR"
echo "SERVER is set to $SERVER"
echo "Running Scripts for Perf Data Collection ..."

mkdir $PERFDATA_OUTPUTDIR
		
./GetHiveQueryIds.sh $RESULTS_DIR $PERFDATA_OUTPUTDIR $SERVER

./GetTezDags.sh $RESULTS_DIR $PERFDATA_OUTPUTDIR $SERVER

./GetTezDagIds.sh $RESULTS_DIR $PERFDATA_OUTPUTDIR $SERVER

./GetTasks.sh $RESULTS_DIR $PERFDATA_OUTPUTDIR $SERVER

./GetVertices.sh $RESULTS_DIR $PERFDATA_OUTPUTDIR $SERVER

./GetTezApplication.sh $RESULTS_DIR $PERFDATA_OUTPUTDIR $SERVER

./GetATSDAG.sh $PERFDATA_OUTPUTDIR

cp -R $BENCH_HOME/$BENCHMARK/tpch-scripts/PAT-master/PAT/results/$RUN_ID $PERFDATA_OUTPUTDIR/pat

echo "Completed Running PerfData Collection Scripts"

zip -r $BENCH_HOME/$BENCHMARK/PerfData_$RUN_ID.zip $PERFDATA_OUTPUTDIR

echo "zipped Perfdata to $BENCH_HOME/$BENCHMARK/PerfData.zip"
