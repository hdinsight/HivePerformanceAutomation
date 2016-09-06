#!/bin/bash
#usage: TpchQueryExecute.sh SCALE_FACTOR QUERY_NUMBER
# This script runs the hive queries on the data generated from the tpch suite and reports query execution times

if [ $# -ne 2 ]
then
	echo "Usage: ./TpchQueryExecute.sh SCALE_FACTOR QUERY_NUMBER"
	exit 1
else
	SCALE="$1"
fi

# get home path
BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd );
echo "\$BENCH_HOME is set to $BENCH_HOME";

BENCHMARK=hive-testbench
# Set path to the hive settings
HIVE_SETTING=$BENCH_HOME/$BENCHMARK/sample-queries-tpch/testbench.settings
# Set path to tpc-h queries
QUERY_DIR=$BENCH_HOME/$BENCHMARK/sample-queries-tpch

RESULT_DIR=$BENCH_HOME/$BENCHMARK/results_query_$2/
if [ ! -d $RESULT_DIR ]; then
mkdir $RESULT_DIR
chmod -R 777 $RESULT_DIR
fi

LOG_DIR=$BENCH_HOME/$BENCHMARK/logs_query_$2/
if [ ! -d $LOG_DIR ]; then
mkdir $LOG_DIR
chmod -R 777 $LOG_DIR
fi

LOG_FILE_EXEC_TIMES="${BENCH_HOME}/${BENCHMARK}/logs_query_$2/query_times.csv"

if [ ! -e "$LOG_FILE_EXEC_TIMES" ]
  then
	touch "$LOG_FILE_EXEC_TIMES"
	chmod 777 $LOG_FILE_EXEC_TIMES
    echo "QUERY,DURATION_IN_SECONDS,STARTTIME,STOPTIME,BENCHMARK,DATABASE,SCALE_FACTOR,FILE_FORMAT" >> "${LOG_FILE_EXEC_TIMES}"
fi

if [ ! -w "$LOG_FILE_EXEC_TIMES" ]
  then
    echo "ERROR: cannot write to: $LOG_FILE_EXEC_TIMES, no permission"
    exit 1
fi

if test $SCALE -lt 1000; then 
	DATABASE=tpch_flat_orc_$SCALE
else
	DATABASE=tpch_partitioned_orc_$SCALE
fi

FILE_FORMAT=orc
TABLES="part partsupp supplier customer orders lineitem nation region"

#Measure time for query execution
# Start timer to measure data loading for the file formats
STARTDATE="`date +%Y/%m/%d:%H:%M:%S`"
STARTTIME="`date +%s`" # seconds since epochstart
# Execute query
	ENGINE=hive
	printf -v j "%02d" $2
	echo "Hive query: ${2}"
	hive -i ${HIVE_SETTING} --database ${DATABASE} -f ${QUERY_DIR}/tpch_query${2}.sql > ${RESULT_DIR}/${DATABASE}_query${j}.$STARTTIME.txt 2>&1
	# Calculate the time
	STOPDATE="`date +%Y/%m/%d:%H:%M:%S`"
	STOPTIME="`date +%s`" # seconds since epoch
	DIFF_IN_SECONDS="$(($STOPTIME - $STARTTIME))"
	DIFF_ms="$(($DIFF_IN_SECONDS * 1000))"
	DURATION="$(($DIFF_IN_SECONDS / 3600 ))h $((($DIFF_IN_SECONDS % 3600) / 60))m $(($DIFF_IN_SECONDS % 60))s"
	# log the times in load_time.csv file
	echo "Query${j},${DIFF_IN_SECONDS},${STARTTIME},${STOPTIME},${BENCHMARK},${DATABASE},${SCALE},${FILE_FORMAT}" >> ${LOG_FILE_EXEC_TIMES}

