#!/bin/bash

if [ $# -ne 3 ]
then
	echo "Usage ./RunSuiteLoop REPEAT_COUNT SCALE_FACTOR CLUSTER_SSH_PASSWORD"
	exit 1
fi

counter=11
while [ $counter -lt $1 ]; do
STARTDATE="`date +%Y/%m/%d:%H:%M:%S`"
STARTTIME="`date +%s`"
REPEAT_COUNT=$1
let counter=counter+1
echo "Running Iteration $counter"
RUN_ID=$counter
for i in {1..22}
do
./GetPatData.sh $3 ./TpchQueryExecute.sh $2 $i $RUN_ID $RUN_ID/tpch_query_$i
done
done
