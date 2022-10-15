#!/bin/bash

shopt -s xpg_echo

function log_msg {
current_time=$(date "+%Y-%m-%d %H:%M:%S.%3N")
log_level=$1
log_msg="${@:2}"
if [[ $1 == WARNING ]];then
echo "[$current_time] $log_level - $log_msg"
else
echo -n "[$current_time] $log_level - $log_msg"
fi
}

function log_error {
log_msg "ERROR" "$@"
}

function log_info {
log_msg "INFO " "$@"
}

function log_warn {
log_msg "WARNING" "$@"
}

RED="\033[0;31m"
GREEN="\033[0;32m"
CLEAR="\033[0m"
YELLOW="\033[0;33m"

log_info "${GREEN} Installing LXD Using Snap.. ${CLEAR}"
sudo snap install lxd --channel=4.0/stable
sudo snap start lxd
sleep 5
echo " OK!"

log_info "${GREEN} Create Preseed File.. ${CLEAR}"

CONFIG="/tmp/config.yaml"

cat > $CONFIG << EOF
    config: {}
    networks:
    - config:
             ipv4.address: auto
             ipv6.address: auto
      description: "Custom Profile for Ansible Client Machine"
      managed: false
      name: lxdbr0
      type: bridge
    storage_pools:
    - config:
      description: ""
      name: default
      driver: dir
    profiles:
    - config: {}
      description: "Custom Profile for Ansible Client Machine"
      devices:
              eth0:
                name: eth0
                nictype: bridged
                parent: lxdbr0
                type: nic
              root:
                path: /
                pool: default
                type: disk
      name: default
    cluster: null
EOF

sudo chmod +x $CONFIG
echo " OK!"

log_info "${GREEN} Initialise LXD Using Preseed File.. ${CLEAR}"
sleep 2
sudo lxd init --preseed <$CONFIG
sleep 5
sudo snap restart lxd
sleep 300
#sudo systemctl reload snap.lxd.daemon
echo " OK!"

log_info "${GREEN} LXD setup Done!!  ${CLEAR}"
echo " OK!"

log_info "${GREEN} LXC Installed version $(lxc version).. ${CLEAR}"
echo " OK!"

select_random() {
    printf "%s\0" "$@" | shuf -z -n1 | tr -d '\0'
}


image_list=("ubuntu:22.04" "ubuntu:22.04")

function spin_server() {
sleep 15
while [ $(lxc list|wc -l) -lt 1 ];do
log_info "${GREEN} Waiting for LXC service to Start and Settled.. ${CLEAR}"
sleep 1
done
log_info "*** ${GREEN} PLEASE WAIT SPINNING UP ALL THE SERVERS MAY TAKE A WHILE *** ${CLEAR}"
echo -e "\n"
sleep 60
for server in kafka1 kafka2 kafka3 zk1 zk2 zk3
do
sleep 15
image=$(select_random "${image_list[@]}")
log_info "${GREEN} Starting Server $server with Image ${image} - Please Wait.. ${CLEAR}"
sudo lxc launch "${image}" $server </dev/null
sleep 10
[ $(sudo lxc ls -c ns --format csv $server|grep RUNNING|cut -f1 -d,|wc -l) -lt 1 ] && sudo lxc start $server </dev/null
echo " OK!"
done
}

function run_script() {
server=$1
log_info "${GREEN} Adding ansible user to $server server - Please Wait.. ${CLEAR}"
case $server in
kafka*)
sudo lxc exec $server -- bash /tmp/kafka.sh  </dev/null
;;
zk*)
sudo lxc exec $server -- bash /tmp/zk.sh  </dev/null
;;
esac
echo " OK!"
}


function copy_script() {
for server in  kafka1 kafka2 kafka3 zk1 zk2 zk3
do
sleep 10
if [[  $(sudo lxc ls -c ns --format csv $server |grep RUNNING|cut -f1 -d,|wc -l) -ge 1 ]];then
log_info "${GREEN} Copying Script in $server Server - Please Wait.. ${CLEAR}"
sudo lxc exec $server -- useradd vagrant </dev/null
case $server in
kafka1)
sudo lxc file push /tmp/kafka.sh $server/tmp/ </dev/null
sudo lxc file push /tmp/configs/kafka1.properties $server/tmp/ </dev/null && run_script $server
;;
kafka2)
sudo lxc file push /tmp/kafka.sh $server/tmp/ </dev/null
sudo lxc file push /tmp/configs/kafka2.properties $server/tmp/ </dev/null && run_script $server
;;
kafka3)
sudo lxc file push /tmp/kafka.sh $server/tmp/ </dev/null
sudo lxc file push /tmp/configs/kafka3.properties $server/tmp/ </dev/null && run_script $server
;;
zk1)
sudo lxc file push /tmp/zk.sh $server/tmp/ </dev/null
sudo lxc file push /tmp/configs/zk1.cfg  $server/tmp/ </dev/null && run_script $server
;;
zk2)
sudo lxc file push /tmp/zk.sh $server/tmp/ </dev/null
sudo lxc file push /tmp/configs/zk2.cfg  $server/tmp/ </dev/null && run_script $server
;;
zk3)
sudo lxc file push /tmp/zk.sh $server/tmp/ </dev/null
sudo lxc file push /tmp/configs/zk3.cfg  $server/tmp/ </dev/null && run_script $server
;;
esac
echo " OK!"
fi
done
}

spin_server
copy_script

for server in kafka1 kafka2 kafka3 zk1 zk2 zk3;do
[ $(sudo lxc ls -c ns --format csv $server|grep RUNNING|cut -f1 -d,|wc -l) -lt 1 ] && sudo lxc start $server </dev/null
case $server in
kafka*)
sudo lxc exec $server -- service kafka stop </dev/null
sleep 5
sudo lxc exec $server -- service kafka start </dev/null
;;
zk*)
sudo lxc exec $server -- service zookeeper start </dev/null
;;
esac
done
