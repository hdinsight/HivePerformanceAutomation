#!/bin/bash
#usage: TpchQueryExecute.sh SCALE_FACTOR QUERY_NUMBER [RUN_ID]
# This script runs the hive queries on the data generated from the tpch suite and reports query execution times

if [ $# -lt 2 ]
then
	echo "Usage: ./TpchQueryExecute.sh SCALE_FACTOR QUERY_NUMBER [RUN_ID]"	
	exit 1
else
	SCALE="$1"
fi

STARTTIME="`date +%s`"

if [ -z "$3" ]
then
        RUN_ID=$STARTTIME
else
        RUN_ID=$3
fi

# get home path
BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd );
echo "\$BENCH_HOME is set to $BENCH_HOME";

BENCHMARK=hive-testbench
# Set path to the hive settings
HIVE_SETTING=$BENCH_HOME/$BENCHMARK/sample-queries-tpch/testbench.settings
# Set path to tpc-h queries
QUERY_DIR=$BENCH_HOME/$BENCHMARK/sample-queries-tpch

RESULT_DIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/results/

PLAN_DIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/plans/

LOG_DIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/logs/

if [ ! -d "$RESULT_DIR" ]; then
mkdir $BENCH_HOME/$BENCHMARK/run_$RUN_ID/
mkdir $RESULT_DIR
fi

if [ ! -d "$PLAN_DIR" ]; then
mkdir $PLAN_DIR
fi

if [ ! -d "$LOG_DIR" ]; then
mkdir $LOG_DIR
fi

LOG_FILE_EXEC_TIMES="$LOG_DIR/query_times.csv"
EXPLAIN_FILE_EXEC_TIMES="$PLAN_DIR/explain_times.csv"

if [ ! -e "$LOG_FILE_EXEC_TIMES" ]
  then
	touch "$LOG_FILE_EXEC_TIMES"
	echo "QUERY,DURATION_IN_SECONDS,STARTTIME,STOPTIME,BENCHMARK,DATABASE,SCALE_FACTOR,FILE_FORMAT,STATUS" >> "${LOG_FILE_EXEC_TIMES}"
fi

if [ ! -e "$EXPLAIN_FILE_EXEC_TIMES" ]
  then
	touch "$EXPLAIN_FILE_EXEC_TIMES"
	echo "QUERY,DURATION_IN_SECONDS,STARTTIME,STOPTIME,BENCHMARK,DATABASE,SCALE_FACTOR,FILE_FORMAT" >> "${EXPLAIN_FILE_EXEC_TIMES}"
fi

if [ ! -w "$LOG_FILE_EXEC_TIMES" ]
  then
    echo "ERROR: cannot write to: $LOG_FILE_EXEC_TIMES, no permission"
    return 1
fi

if test $SCALE -lt 1000; then 
	DATABASE=tpch_flat_orc_$SCALE
else
	DATABASE=tpch_partitioned_orc_$SCALE
fi

FILE_FORMAT=orc
TABLES="part partsupp supplier customer orders lineitem nation region"
RETRY_COUNT=1
RETURN_VAL=1
EXECUTION_COUNT=0
STATUS=FAIL
TIMEOUT="3h"

# Execute query
	ENGINE=hive
	printf -v j "%02d" $2
	echo "Hive query: ${2}"
	while [ $RETURN_VAL -ne 0 -a $EXECUTION_COUNT -lt $RETRY_COUNT ]
	do	
		EXPLAIN_STARTTIME="`date +%s`"
		hive -i ${HIVE_SETTING} --database ${DATABASE} -d EXPLAIN="explain formatted" -f ${QUERY_DIR}/tpch_query${2}.sql > ${PLAN_DIR}/plan_${DATABASE}_query${j}.json 2>> ${PLAN_DIR}/debug.log
		EXPLAIN_ENDTIME="`date +%s`"
		#Measure time for query execution
		STARTTIME="`date +%s`" # seconds since epochstart

		timeout ${TIMEOUT} hive -i ${HIVE_SETTING} --database ${DATABASE} -d EXPLAIN="" -f ${QUERY_DIR}/tpch_query${2}.sql > ${RESULT_DIR}/${DATABASE}_query${j}.txt 2>&1
		RETURN_VAL=$?
		((EXECUTION_COUNT++))
		
		echo "Execution count is $EXECUTION_COUNT and return val is $RETURN_VAL"

		if [ $RETURN_VAL = 0 ]
		then
			STATUS=SUCCESS
		fi
			
		# Calculate the time
		STOPTIME="`date +%s`" # seconds since epoch
		EXPLAIN_DIFF_IN_SECONDS="$(($EXPLAIN_ENDTIME - $EXPLAIN_STARTTIME))"
		DIFF_IN_SECONDS="$(($STOPTIME - $STARTTIME))"
		DIFF_ms="$(($DIFF_IN_SECONDS * 1000))"
		DURATION="$(($DIFF_IN_SECONDS / 3600 ))h $((($DIFF_IN_SECONDS % 3600) / 60))m $(($DIFF_IN_SECONDS % 60))s"
		# log the times in query_times.csv file
		echo "query${j},${DIFF_IN_SECONDS},${STARTTIME},${STOPTIME},${BENCHMARK},${DATABASE},${SCALE},${FILE_FORMAT},${STATUS}" >> ${LOG_FILE_EXEC_TIMES}
		# log the explain times in explain_times.csv file
		echo "query${j},${EXPLAIN_DIFF_IN_SECONDS},${EXPLAIN_STARTTIME},${EXPLAIN_ENDTIME},${BENCHMARK},${DATABASE},${SCALE},${FILE_FORMAT}" >> ${EXPLAIN_FILE_EXEC_TIMES}
	 done
