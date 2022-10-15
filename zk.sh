#!/bin/bash

export ZOOKEEPER_VERSION=3.7.1

apt install default-jdk -y

mkdir -p /zk && useradd -r -d /zk -s /usr/sbin/nologin zoo

mkdir -p /opt/zookeeper && \
    curl "https://dlcdn.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz" \
    -o /opt/zookeeper/zookeeper.tar.gz && \
    mkdir -p /zk && cd /zk && \
    tar -xvzf /opt/zookeeper/zookeeper.tar.gz --strip 1

chown -R zoo:zoo /zk

sudo -u zoo mkdir -p /zk/data
sudo -u zoo mkdir -p /zk/data-log
sudo -u zoo mkdir -p /zk/logs

cat > /etc/systemd/system/zookeeper.service << EOF
[Unit]
Description=Zookeeper Daemon
Documentation=http://zookeeper.apache.org
Requires=network.target
After=network.target

[Service]
Type=forking
WorkingDirectory=/zk
User=zoo
Group=zoo
ExecStart=/bin/sh -c '/zk/bin/zkServer.sh start /zk/conf/zoo.cfg > /zk/logs/start-zk.log 2>&1'
ExecStop=/zk/bin/zkServer.sh stop /zk/conf/zoo.cfg
ExecReload=/zk/bin/zkServer.sh restart /zk/conf/zoo.cfg
TimeoutSec=30
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable zookeeper


case $(hostname) in
zk1)
cat > /zk/data/myid << EOF
1
EOF
cp /tmp/zk1.cfg /zk/conf/zoo.cfg 
;;
zk2)
cat > /zk/data/myid << EOF
2
EOF
cp /tmp/zk2.cfg /zk/conf/zoo.cfg
;;
zk3)
cat > /zk/data/myid << EOF
3
EOF
cp /tmp/zk3.cfg /zk/conf/zoo.cfg
;;
esac

sleep 5

service zookeeper start
