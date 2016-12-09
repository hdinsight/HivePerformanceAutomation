#!/bin/bash

if [ $# -ne 2 ]
then
    echo "usage queryExecutor.sh FULLFILEPATH RUN_ID"
    exit 1
fi

set -x

FILE=$1
RUN_ID=$2

CONNECTION_STRING=${CONNECTION_STRING}/${QUERY_DATABASE}";transportMode=http"
DATABASE=${QUERY_DATABASE}

name=${FILE##*/}
basename=${name%.sql}
basename=${basename%.txt}

if ${GENERATE_PLANS};
then

    querytext=$(cat $FILE | tac | sed '0,/select/s/select/explain select/I' | tac)
    PLANSTARTTIME="`date +%s`"
    if ! [[ $RUN_ID =~  ^[0-9]+$ ]]
    then
        FILENAME_EXTENSION=_${PLANSTARTTIME}
    fi
    beeline -u ${CONNECTION_STRING} -i ${HIVE_SETTING} --hivevar DB=${DATABASE} -e "$querytext" > ${PLANS_DIR}/plan_${DATABASE}_${basename}${FILENAME_EXTENSION}.json 2>&1
    RETURN_VAL=$?
    PLANENDTIME="`date +%s`"

    if [ $RETURN_VAL = 0 ]
    then
        STATUS=SUCCESS
    else
        STATUS=FAIL
    fi

    DIFF_IN_SECONDS="$(($PLANENDTIME - $PLANSTARTTIME))"
    echo "$basename,${DIFF_IN_SECONDS},${PLANSTARTTIME},${PLANENDTIME},${WORKLOAD},${QUERY_DATABASE},${STATUS}" >> ${PLAN_TIMES_FILE}
fi

QUERYSTARTTIME="`date +%s`"
beeline -u ${CONNECTION_STRING} -i ${HIVE_SETTING} --hivevar DB=${DATABASE} -f $FILE > ${RESULTS_DIR}/${DATABASE}_${basename}${FILENAME_EXTENSION}.txt 2>&1
RETURN_VAL=$?
QUERYENDTIME="`date +%s`"

if [ $RETURN_VAL = 0 ]
then
    STATUS=SUCCESS
else
    STATUS=FAIL
fi

DIFF_IN_SECONDS="$(($QUERYENDTIME- $QUERYSTARTTIME))"
echo "${basename},${DIFF_IN_SECONDS},${QUERYSTARTTIME},${QUERYENDTIME},${WORKLOAD},${QUERY_DATABASE},${STATUS}" >> ${QUERY_TIMES_FILE}

