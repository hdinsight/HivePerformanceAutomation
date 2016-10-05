
#home path
BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd );
BENCHMARK=hive-testbench

echo "\$BENCH_HOME is set to $BENCH_HOME";
STATS_DIR=$BENCH_HOME/$BENCHMARK/stats
DATABASE=$1

if [ ! -d "$STATS_DIR" ]; then
mkdir $STATS_DIR
chmod -R 777 $STATS_DIR
fi

>${STATS_DIR}/tableinfo_${DATABASE}.txt;

hive -d DB=${DATABASE} -f gettpchtablecounts.sql > ${STATS_DIR}/tablecounts_${DATABASE}.txt ;
hive -d DB=${DATABASE} -f gettpchtableinfo.sql >> ${STATS_DIR}/tableinfo_${DATABASE}.txt ;

