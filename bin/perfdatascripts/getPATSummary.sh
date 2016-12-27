#!/bin/bash
#usage: ./getPATSummary.sh PAT_OUTOPUT_FOLDER RESULT_FOLDER

find $1 -name netstat -type f -exec grep -H 'eth0' {}  \; | sed  -r "s#.*tpch_query_([0-9]+)[^:]*:#query\1 #g" > temp;
find $1 -name netstat -type f -exec head -1 {}  \; | uniq | sed 's/%//g' | sed 's:/::g' | sed '1s/^/query /' > header ;
cat header temp > $2/allnet.tsv

find $1 -name cpustat -type f -exec grep -H 'all' {} \; | sed  -r "s#.*tpch_query_([0-9]+)[^:]*:#query\1 #g" > temp;
find $1 -name cpustat -type f -exec head -1 {}  \; | uniq | sed 's/%//g' | sed '1s/^/query /' > header ;
cat header temp > $2/allcpu.tsv

find $1 -name iostat -type f -exec grep -H 'sd' {} \; | sed 's/ \+/,/g'  | sed  -r "s#.*tpch_query_([0-9]+)[^:]*:#query\1,#g" > temp ;
find $1 -name iostat -type f -exec head -1 {} \; | uniq | sed 's#[-|:|%|/]##g' | sed 's/ \+/,/g' | sed '1s/^/query,/' > header ;
cat header temp > $2/allio.csv

sudo csvsql $2/allnet.tsv --query "select query, hostname,avg(rxkbs)/1000 net_avg_rxmBs,avg(txkbs)/1000 net_avg_txmBs,max(rxkbs)/1000 net_max_rxmBs, max(txkbs)/1000 net_max_txmBs from allnet group by query,hostname" > $2/net

sudo csvsql $2/allcpu.tsv --query "select query, hostname, avg(user) avg_user_cpu,avg(system) avg_sys_cpu, avg(iowait) avg_iowait, max(user) max_user_cpu, max(system) max_sys_cpu, max(iowait) max_iowait from allcpu group by query, hostname" > $2/cpu

sudo csvsql $2/allio.csv --query "select query, hostname, device, avg(await-svctm) io_avg_overload, avg(rkBs)/1000 io_avg_rmBs, avg(wkBs)/1000 io_avg_wmBs,avg(avgqusz) io_avg_avgqusz,avg(await) io_avg_await,avg(svctm) avg_svctm, max(rkBs) io_max_rkBs, max(wkBs) io_max_wkBs,max(avgqusz) io_max_avgqusz,max(await) io_max_await,max(svctm) io_max_svctm, avg(util) io_avg_util, sum(rkBs) io_sum_rkBs, sum(wkBs) io_sum_wkBs,sum(await) io_sum_await,sum(svctm) io_sum_svctm from allio group by query,HostName,device" > $2/io

echo "hostname,ip" > $2/node_ip;
while read host ; do
  echo "$host,$(getent hosts $host | awk '{ print $1 }')" >> $2/node_ip
done < <(cut -d ',' -f2 cpu | sed 1d)

sudo csvsql $2/node_ip $2/cpu $2/io $2/net $2/nodetasks.csv --query "select cpu.query,cpu.hostname,count taskcount,cpu.avg_user_cpu,cpu.avg_sys_cpu,cpu.avg_iowait,cpu.max_user_cpu,cpu.max_sys_cpu,cpu.max_iowait, net.net_avg_rxmBs,net.net_avg_txmBs,net.net_max_rxmBs,net.net_max_txmBs, io.io_avg_overload,io.io_avg_rmBs,io.io_avg_wmBs,io.io_avg_avgqusz,io.io_avg_await,avg_svctm,io.io_max_rkBs,io.io_max_wkBs,io.io_max_avgqusz,io.io_max_await,io.io_max_svctm,io.io_avg_util,io.io_sum_rkBs,io.io_sum_wkBs,io.io_sum_await,io.io_sum_svctm from node_ip, nodetasks,cpu,io,net where node_ip.ip=nodetasks.node and cpu.hostname=node_ip.hostname and io.hostname=node_ip.hostname and io.device='sdb' and net.hostname=node_ip.hostname and cpu.query=io.query and io.query=net.query and net.query=nodetasks.query group by nodetasks.query, node_ip.hostname" > $2/node_report.csv
