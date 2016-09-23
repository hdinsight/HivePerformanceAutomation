# This script takes five arguments
# Arguments:
# * Password
# * Workload kick-off script
# * Workload Scalefactor
# * Workload QueryNumber
# * Outputfoldername
# Example usage : ./CollectPatData.sh cluster_ssh_password ./Runquery.sh output_query1
# Assumptions : /etc/hadoop/conf/slaves contains list of worker nodes, one per line

# check if sshpass is installed, if not install it.
which sshpass &> /dev/null || sudo apt-get -y -qq install sshpass
which pdsh &> /dev/null || sudo apt-get -y -qq install pdsh

# Here we check if a keypair already exists in the default location. If not, we create one.
if [ ! -e ~/.ssh/id_rsa ]
then
        echo "Generating keys\n"
        ssh-keygen -f ~/.ssh/id_rsa -P ""
fi

for slave in `cat /etc/hadoop/conf/slaves`
do
        #echo "ssh-copy-id on $slave"
        sshpass -p $1 ssh-copy-id -o StrictHostKeyChecking=no $slave
done

pdsh -R ssh -w ^/etc/hadoop/conf/slaves sudo apt-get -y -qq install linux-tools-common sysstat gawk

if [ ! -d PAT-master ]; then
        echo "Downloading PAT tool"
        wget https://github.com/intel-hadoop/PAT/archive/master.zip
        unzip master.zip
fi

cat <<EOM >PAT-master/PAT/config
ALL_NODES: `cat /etc/hadoop/conf/slaves | tr '\r\n' ' '`

WORKER_SCRIPT_DIR: /tmp/PAT
WORKER_TMP_DIR: /tmp/PAT_TMP
CMD_PATH: `readlink -e $2`
SAMPLE_RATE: 1
INSTRUMENTS: cpustat memstat netstat iostat vmstat jvms perf
EOM

cd PAT-master/PAT/
./pat run $3


