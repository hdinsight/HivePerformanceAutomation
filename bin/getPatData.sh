# This script takes five arguments
# Arguments:
# * Password
# * Workload kick-off script
# * Workload Scalefactor
# * Workload QueryNumber
# * Outputfoldername
# Example usage : ./GetPatData.sh cluster_ssh_password ./TpchQueryExecute 1000 1 tpch_query_i
# Assumptions : /etc/hadoop/conf/slaves contains list of worker nodes, one per line

# Here we check if a keypair already exists in the default location. If not, we create one.
if [ ! -e ~/.ssh/id_rsa ]
then
        echo "Generating keys\n"
        ssh-keygen -f ~/.ssh/id_rsa -P ""
fi

set -x

cat <<EOM > ${OUTPUT_PATH}/PAT-master/PAT/config
ALL_NODES: `cat /etc/hadoop/conf/slaves | tr '\r\n' ' '`

WORKER_SCRIPT_DIR: /tmp/PAT
WORKER_TMP_DIR: /tmp/PAT_TMP
CMD_PATH: `readlink -e $2` $3 $4
SAMPLE_RATE: 1
INSTRUMENTS: cpustat memstat netstat iostat vmstat jvms perf
EOM

cd ${OUTPUT_PATH}/PAT-master/PAT/
./pat run $5


