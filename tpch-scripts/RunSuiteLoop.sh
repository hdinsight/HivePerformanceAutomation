#!/bin/bash

if [ $# -ne 3 ]
then
	echo "Usage ./RunSuiteLoop REPEAT_COUNT SCALE_FACTOR CLUSTER_SSH_PASSWORD"
	exit 1
fi

BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd );
echo "\$BENCH_HOME is set to $BENCH_HOME";
BENCHMARK=hive-testbench

counter=0
while [ $counter -lt $1 ]; do
STARTDATE="`date +%Y/%m/%d:%H:%M:%S`"
STARTTIME="`date +%s`"
REPEAT_COUNT=$1
let counter=counter+1
echo "Running Iteration $counter"
RUN_ID=$counter
mkdir $BENCH_HOME/$BENCHMARK/run_$RUN_ID/
RESULT_DIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/results/

for i in {1..22}
do
./GetPatData.sh $3 ./TpchQueryExecute.sh $2 $i $RUN_ID $RUN_ID/tpch_query_$i
done

echo "collecting perf data"
./CollectPerfData.sh $RUN_ID $RESULT_DIR

done
