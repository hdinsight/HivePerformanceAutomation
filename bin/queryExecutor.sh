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

