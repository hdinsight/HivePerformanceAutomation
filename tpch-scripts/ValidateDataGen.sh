#!/bin/bash
#home path
BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd );
BENCHMARK=hive-testbench

echo "\$BENCH_HOME is set to $BENCH_HOME";
STATS_DIR=$BENCH_HOME/$BENCHMARK/stats
DATABASE=$1

if [ ! -d "$STATS_DIR" ]; then
mkdir $STATS_DIR
fi

>${STATS_DIR}/tableinfo_${DATABASE}.txt;

CONNECTION_STRING="jdbc:hive2://localhost:10001/${DATABASE};transportMode=http"

beeline -u ${CONNECTION_STRING} --hivevar DB=${DATABASE} -f $BENCH_HOME/$BENCHMARK/tpch-scripts/gettpchtablecounts.sql > ${STATS_DIR}/tablecounts_${DATABASE}.txt ;
beeline -u ${CONNECTION_STRING} --hivevar DB=${DATABASE} -f $BENCH_HOME/$BENCHMARK/tpch-scripts/ gettpchtableinfo.sql >> ${STATS_DIR}/tableinfo_${DATABASE}.txt ;

