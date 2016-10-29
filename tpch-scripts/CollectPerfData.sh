#!/bin/bash
export BENCH_HOME=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd );
echo "\$BENCH_HOME is set to $BENCH_HOME";

export BENCHMARK=hive-testbench

if [ $# -eq 0 ]
then
	echo "Usage ./CollectPerfData.sh RUN_ID RESULTS_DIR PERFDATA_OUTPUTDIR SERVER"
	echo "Default Values will be used if you do not provide command line parameters. RUN_ID is mandatory"
fi

if [ -z $1 ]
then
	echo "Please enter RUN_ID"
	exit 1
else
	RUN_ID=$1
fi

if [ -z $2 ]
then
	RESULTS_DIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/results/
else
	RESULTS_DIR=$2
fi

if [ -z $3 ]
then
	PERFDATA_OUTPUTDIR=$BENCH_HOME/$BENCHMARK/run_$RUN_ID/PerfData/
else
	PERFDATA_OUTPUTDIR=$3
fi

if [ -z $4 ]
then
	SERVER=http://headnodehost:8188/ws/v1/timeline
else
	SERVER=$4
fi

echo "RESULTS_DIR is set to $RESULTS_DIR"
echo "PERFDATA_OUTPUTDIR is set to $PERFDATA_OUTPUTDIR"
echo "SERVER is set to $SERVER"
echo "Running Scripts for Perf Data Collection ..."

mkdir $PERFDATA_OUTPUTDIR

./GetHiveQueryIds.sh $RESULTS_DIR $PERFDATA_OUTPUTDIR $SERVER

./GetTezDagsIds.sh $RESULTS_DIR $PERFDATA_OUTPUTDIR $SERVER

./GetATSDAG.sh $PERFDATA_OUTPUTDIR

./getStoreLatency.sh ${BENCH_HOME}/${BENCHMARK}/run_$RUN_ID/logs/query_times.csv $PERFDATA_OUTPUTDIR

./getTaskNodeAssignment.sh $PERFDATA_OUTPUTDIR $PERFDATA_OUTPUTDIR/nodetasks.csv

./getCounters.sh $PERFDATA_OUTPUTDIR $PERFDATA_OUTPUTDIR/dag_counters.csv

cp -R $BENCH_HOME/$BENCHMARK/tpch-scripts/PAT-master/PAT/results/$RUN_ID $PERFDATA_OUTPUTDIR/pat

./getPATSummary.sh $PERFDATA_OUTPUTDIR/pat $PERFDATA_OUTPUTDIR 

sudo csvsql ${BENCH_HOME}/${BENCHMARK}/run_$RUN_ID/logs/query_times.csv $PERFDATA_OUTPUTDIR/node_report.csv $PERFDATA_OUTPUTDIR/dag_counters.csv $PERFDATA_OUTPUTDIR/latency_summary.csv --query "select node_report.query,STATUS,DURATION_IN_SECONDS,TOTAL_LAUNCHED_TASKS, NUM_SUCCEEDED_TASKS,IFNULL(NUM_KILLED_TASKS,0) NUM_KILLED_TASKS,IFNULL(NUM_FAILED_TASKS,0) NUM_FAILED_TASKS,round(avg(taskcount),2) tasks_avg_host,max(taskcount) tasks_max_host,min(taskcount) tasks_min_host,round(avg(avg_user_cpu),2) cpu_avg_user,round(max(avg_user_cpu),2) cpu_max_user,round(min(avg_user_cpu),2) cpu_min_user,round(avg(avg_sys_cpu),2) cpu_avg_sys,round(max(avg_sys_cpu),2) cpu_max_sys,round(min(avg_sys_cpu),2) cpu_min_sys,round(avg(avg_iowait),2) cpu_avg_iowait,round(max(max_user_cpu),2) cpu_max_user,round(max(max_sys_cpu),2) cpu_max_sys,round(max(max_iowait),2) cpu_max_iowait,WASB_BYTES_READ/1000000000 wasb_bytes_read_gb,size_GB sum_getblob_gb,total_requests_count total_store_request_count,total_getblob_count,round(sucessful_count*100/total_getblob_count,2) sucessful_store_request_percentage,round(throttelled_count*100/total_getblob_count,2) throttelled_store_request_percentage, E2E99th E2E99th_store_latency_ms,E2E999th E2E999th_store_latency_ms,round(E2E_avg,2) avg_store_latency_ms,E2E_max max_store_latency_ms,round(E2E_server_avg,2) avg_store_server_latency_ms,E2E_server_max max_store_server_latency_ms,round(avg(net_avg_rxmBs),2) net_avg_receive_MBps,round(avg(net_avg_txmBs),2) net_avg_send_MBps,round(max(net_max_rxmBs),2) net_max_receive_MBps,round(max(net_max_txmBs),2) net_max_send_MBps,FILE_BYTES_READ,FILE_BYTES_WRITTEN,round(avg(io_avg_overload),2) io_avg_overload,round(avg(io_avg_rmBs),2) io_avg_read_MBps ,round(avg(io_avg_wmBs),2) io_avg_write_MBps,round(avg(io_avg_avgqusz)) io_avg_queue_size,round(avg(io_avg_await),2) io_avg_await_ms, round(avg(avg_svctm),2) io_avg_service_time_ms,round(max(io_max_rkBs)/1000,2) io_max_read_MBps,round(max(io_max_wkBs)/1000,2) io_max_write_MBps,max(io_max_avgqusz) io_max_queue_size,max(io_max_await) io_max_await,max(io_max_svctm) io_max_service_time,round(avg(io_avg_util),2) io_avg_util,round(sum(io_sum_rkBs)/1000,2) io_sum_read_MBps,round(sum(io_sum_wkBs)/1000,2) io_sum_write_MBps,sum(io_sum_await) io_sum_await,sum(io_sum_svctm) io_sum_service_time from query_times, node_report,dag_counters, latency_summary where lower(query_times.query)=node_report.query and dag_counters.query=node_report.query and latency_summary.query=node_report.query group by node_report.query"
echo "Completed Running PerfData Collection Scripts"

zip -r $BENCH_HOME/$BENCHMARK/run_$RUN_ID/PerfData.zip $PERFDATA_OUTPUTDIR

echo "zipped Perfdata to $BENCH_HOME/$BENCHMARK/run_$RUN_ID/PerfData.zip"
