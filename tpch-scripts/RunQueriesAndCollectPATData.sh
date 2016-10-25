#!/bin/bash
#Script Usage : ./RunQueriesAndCollectPATData.sh SCALE_FACTOR CLUSTER_SSH_PASSWORD
if [ $# -lt 2 ]
then
	echo "usage:./RunQueriesAndCollectPATData.sh SCALE_FACTOR CLUSTER_SSH_PASSWORD [RUN_ID]"
	exit 1
fi

STARTTIME="`date +%s`"

if [ -z "$3" ]
then
	RUN_ID=$STARTTIME
else
	RUN_ID=$3
fi

BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd );
echo "\$BENCH_HOME is set to $BENCH_HOME";

BENCHMARK=hive-testbench

RESULT_DIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/results/

mkdir $BENCH_HOME/$BENCHMARK/run_$RUN_ID/
mkdir $RESULT_DIR
#chmod -R 777 $RESULT_DIR

LOG_DIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/logs/
mkdir $LOG_DIR

# Initialize log file for data loading times
LOG_FILE_EXEC_TIMES="${BENCH_HOME}/${BENCHMARK}/run_$RUN_ID/logs/query_times.csv"
if [ ! -e "$LOG_FILE_EXEC_TIMES" ]
  then
	touch "$LOG_FILE_EXEC_TIMES"
	chmod 777 $LOG_FILE_EXEC_TIMES
    echo "QUERY,DURATION_IN_SECONDS,STARTTIME,STOPTIME,BENCHMARK,DATABASE,SCALE_FACTOR,FILE_FORMAT" >> "${LOG_FILE_EXEC_TIMES}"
fi

if [ ! -w "$LOG_FILE_EXEC_TIMES" ]
  then
    echo "ERROR: cannot write to: $LOG_FILE_EXEC_TIMES, no permission"
    return 1
fi

for i in 1
do
./GetPatData.sh $2 ./TpchQueryExecute.sh $1 $i $RUN_ID $RUN_ID/tpch_query_$i 
done

echo "collecting perf data"
./CollectPerfData.sh $RUN_ID $RESULT_DIR
