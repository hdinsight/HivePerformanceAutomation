#!/bin/bash

if [ -z $1 ]
then
    echo "usage RunQueries.sh WORKLOAD [REPEAT_COUNT]"
    exit 1
else
    WORKLOAD_NAME=$1
fi

if [ -z $2 ]
then
    REPEAT_COUNT=1
else
    REPEAT_COUNT=$2
fi

set -x

COUNTER=0

while [ $COUNTER -lt $REPEAT_COUNT ] ;
do
    let COUNTER=COUNTER+1
    echo "Running Iteration $COUNTER"

    STARTTIME="`date +%s`"

    set -a
    export WORKLOAD=$WORKLOAD_NAME
    export RUN_ID=$STARTTIME
    source ./globalconfig.sh
    source ${WORKLOAD_HOME}/config.sh
    set +a
    
    if [ ! -d $WORKLOAD_HOME ]
    then
        echo "The workload folder $WORKLOAD_HOME does not exist"
        exit 1
    fi
    
    echo "WORKLOAD is $WORKLOAD"
    echo "RUN_ID is $RUN_ID"
    echo "RESULT_DIR is $RESULTS_DIR"
    mkdir -p $RESULTS_DIR
    mkdir -p $PLANS_DIR
    mkdir -p $QUERY_TIMES_DIR
    touch $QUERY_TIMES_FILE
    touch $PLAN_TIMES_FILE

    echo "$EXEC_TIMES_HEADER" > $QUERY_TIMES_FILE
    echo "$EXEC_TIMES_HEADER" > $PLAN_TIMES_FILE

    chmod 777 -R $OUTPUT_DIR

    for file in $WORKLOAD_HOME/queries/*
    do
    name=${file##*/}
    basename=${name%.sql}
    basename=${basename%.txt}
    
    if $COLLECT_PATDATA;
        then
            ./GetPatData.sh $CLUSTER_SSH_PASSWORD ./QueryExecutor.sh $file $RUN_ID $WORKLOAD/run_$RUN_ID/$basename >> $BUILD_LOG_FILE
        else    
            ./QueryExecutor.sh $file $RUN_ID >> $BUILD_LOG_FILE
    fi
    done
    
    if $COLLECT_PERFDATA;
        then
            ${CURRENT_DIR}/perfdatascripts/CollectPerfData.sh $RUN_ID $RESULTS_DIR $PERFDATA_OUTPUTDIR >> $BUILD_LOG_FILE
        fi

done

