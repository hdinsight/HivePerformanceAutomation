#!/bin/bash
export BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd );
echo "\$BENCH_HOME is set to $BENCH_HOME";

export BENCHMARK=hive-testbench

if [ $# -eq 0 ]
then
	echo "Usage ./CollectPerfData.sh RUN_ID RESULTS_DIR PERFDATA_OUTPUTDIR SERVER"
	echo "Default Values will be used if you do not provide command line parameters. RUN_ID is mandatory"
fi

if [ -z $1 ]
then
	echo "Please enter RUN_ID"
	exit 1
else
	RUN_ID=$1
fi

if [ -z $2 ]
then
	RESULTS_DIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/results/
else
	RESULTS_DIR=$2
fi

if [ -z $3 ]
then
	PERFDATA_OUTPUTDIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/PerfData/
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

./GetATSDAG.sh $PERFDATA_OUTPUTDIR

./getStoreLatency.sh ${BENCH_HOME}/${BENCHMARK}/run_$RUN_ID/logs/query_times.csv

./getTaskNodeAssignment.sh $PERFDATA_OUTPUTDIR node_assignment_report.csv

./getCounters.sh $PERFDATA_OUTPUTDIR dag_counters.csv

cp -R $BENCH_HOME/$BENCHMARK/tpch-scripts/PAT-master/PAT/results/$RUN_ID $PERFDATA_OUTPUTDIR/pat

echo "Completed Running PerfData Collection Scripts"

zip -r $BENCH_HOME/$BENCHMARK/run_$RUN_ID/PerfData.zip $PERFDATA_OUTPUTDIR

echo "zipped Perfdata to $BENCH_HOME/$BENCHMARK/run_$RUN_ID/PerfData.zip"
