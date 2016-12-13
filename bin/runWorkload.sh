#!/bin/bash

if [ -z $1 ]
then
    echo "usage runWorkload.sh WORKLOAD [REPEAT_COUNT]"
    exit 1
else
    WORKLOAD_NAME=$1
fi

set -a
export WORKLOAD=${WORKLOAD_NAME}
export RUN_ID=${STARTTIME}
source ./globalConfig.sh
source ${WORKLOAD_HOME}/config.sh
set +a

./setup.sh

if [ ${SKIP_PRERUN} !=  true ]
then
    ${WORKLOAD_HOME}/setup.sh >> ${RUN_LOG_FILE}
    ${WORKLOAD_HOME}/prerun.sh >> ${RUN_LOG_FILE}
fi

./runQueries.sh ${WORKLOAD_NAME}



