#!/bin/bash

if [ -z $1 ]
then
    echo "usage runQueries.sh WORKLOAD [REPEAT_COUNT]"
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

while [ ${COUNTER} -lt ${REPEAT_COUNT} ] ;
do
    let COUNTER=COUNTER+1
    echo "Running Iteration ${COUNTER}" >> ${RUN_LOG_FILE}

    STARTTIME="`date +%s`"

    set -a
    export WORKLOAD=${WORKLOAD_NAME}
    export RUN_ID=${STARTTIME}
    source ./globalConfig.sh
    source ${WORKLOAD_HOME}/config.sh
    set +a
    
    if [ ! -d ${WORKLOAD_HOME} ]
    then
        echo "The workload folder $WORKLOAD_HOME does not exist" >> ${RUN_LOG_FILE}
        exit 1
    fi
    
    echo "WORKLOAD is $WORKLOAD" >> ${RUN_LOG_FILE}
    echo "RUN_ID is $RUN_ID" >> ${RUN_LOG_FILE}
    echo "RESULT_DIR is $RESULTS_DIR" >> ${RUN_LOG_FILE}
    mkdir -p ${RESULTS_DIR}
    mkdir -p ${PLANS_DIR}
    mkdir -p ${QUERY_TIMES_DIR}
    touch ${QUERY_TIMES_FILE}
    touch ${PLAN_TIMES_FILE}

    echo "$EXEC_TIMES_HEADER" > ${QUERY_TIMES_FILE}
    echo "$EXEC_TIMES_HEADER" > ${PLAN_TIMES_FILE}

    for file in ${WORKLOAD_HOME}/queries/*.{sql,hql}
    do
        name=${file##*/}
        basename=${name%.sql}
        basename=${basename%.hql}
        
        if ${COLLECT_PATDATA};
            then
                ./getPatData.sh ${CLUSTER_SSH_PASSWORD} ./queryExecutor.sh ${file} ${RUN_ID} ${WORKLOAD}/run_${RUN_ID}/${basename} >> ${RUN_LOG_FILE}
            else    
                ./queryExecutor.sh ${file} ${RUN_ID} >> ${RUN_LOG_FILE}
        fi
    done
        
    if ${COLLECT_PERFDATA};
        then
            ${CURRENT_DIR}/perfdatascripts/collectPerfData.sh ${RUN_ID} ${RESULTS_DIR} ${PERFDATA_OUTPUTDIR} >> ${RUN_LOG_FILE}
        fi
        
done

