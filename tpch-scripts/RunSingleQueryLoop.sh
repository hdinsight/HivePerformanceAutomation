#!/bin/bash
#usage: ./RunSingleQueryLoop QUERY_NUMBER REPEAT_COUNT SCALCE_FACTOR CLUSTER_SSH_PASSWORD

if [ $# -ne 4 ]
then
	echo "Usage ./RunSingleQueryLoop QUERY_NUMBER REPEAT_COUNT SCALCE_FACTOR CLUSTER_SSH_PASSWORD"
	exit 1
fi

counter=0
while [ $counter -lt $2 ]; do
STARTDATE="`date +%Y/%m/%d:%H:%M:%S`"
STARTTIME="`date +%s`"
let counter=counter+1
echo "Running Iteration $counter"
./GetPatData.sh $4 ./TpchQueryExecute.sh $3 $1 $counter $counter/tpch_query_$(printf %02d $1) 

RUN_ID=$counter
RESULT_DIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/results/

echo "collecting perf data"
./CollectPerfData.sh $RUN_ID $RESULT_DIR

done
