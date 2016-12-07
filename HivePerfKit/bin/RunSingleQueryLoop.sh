#!/bin/bash

if [ $# -lt 2 ]
then
    echo "usage RunSingleQueryLoop.sh WORKLOAD FILENAME [REPEAT_COUNT]"
    exit 1
fi

if [ -z $3 ]
then
        REPEAT_COUNT=1
else
        REPEAT_COUNT=$3
fi

WORKLOAD_NAME=$1
FILENAME=$2
basename=${FILENAME%.sql}
basename=${basename%.txt}

set -x

COUNTER=0

set -a
export WORKLOAD=$WORKLOAD_NAME
export RUN_ID=$basename
source ./globalconfig.sh
source ${WORKLOAD_HOME}/config.sh
set +a

echo "WORKLOAD is $WORKLOAD"
echo "RUN_ID is $RUN_ID"
echo "RESULT_DIR is $RESULTS_DIR"
mkdir -p $RESULTS_DIR
mkdir -p $QUERY_TIMES_DIR
touch $QUERY_TIMES_FILE

chmod 777 -R $OUTPUT_DIR
        
file=${WORKLOAD_HOME}/queries/${FILENAME}

if [ ! -f $file ]
then
	echo "The file $file does not exist"
	exit 1
fi

while [ $COUNTER -lt $REPEAT_COUNT ];
do
    let COUNTER=COUNTER+1
    
    if $COLLECT_PATDATA;
    then
        ./GetPatData.sh $CLUSTER_SSH_PASSWORD ./QueryExecutor.sh $file $RUN_ID $WORKLOAD/run_$RUN_ID/$basename >> $BUILD_LOG_FILE
    else

        ./QueryExecutor.sh $file $RUN_ID >> $BUILD_LOG_DIR/build.log
    fi
done

if $COLLECT_PERFDATA;
then
    ${CURRENT_DIR}/perfdatascripts/CollectPerfData.sh $RUN_ID $RESULTS_DIR $PERFDATA_OUTPUTDIR >> $BUILD_LOG_FILE
fi

