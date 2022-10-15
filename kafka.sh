#!/bin/bash


check_zk () {
HOST=$1
PORT=$2
echo "Waiting for $HOST to launch on port $PORT..."
while ! timeout 1 bash -c "echo > /dev/tcp/$HOST/$PORT"; do
  sleep 1
done
echo "$HOST is up on port $PORT"
}

SERVER=""
[[ -z $SERVER ]] && { echo "Please provide Zookeeper server details" ; }

if [[ -n $SERVER ]];then
IFS=','; for name in $SERVER; do
    IFS=':' read -a NAME <<< "$name"
    check_zk ${NAME[0]} ${NAME[1]}
   done
fi


export KAFKA_VERSION=3.2.0

apt install default-jdk -y

mkdir -p /kafka && useradd -r -d /kafka -s /usr/sbin/nologin kafka

mkdir -p /opt/kafka && \
    curl "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz" \
    -o /opt/kafka/kafka.tar.gz && \
    mkdir -p /kafka && cd /kafka && \
    tar -xvzf /opt/kafka/kafka.tar.gz --strip 1

chown -R kafka:kafka /kafka

sudo -u kafka mkdir -p /kafka/log

sudo -u kafka mkdir -p /kafka/logs

cat > /etc/systemd/system/kafka.service << EOF
[Unit]
Description=Apache Kafka Server
Documentation=http://kafka.apache.org/documentation.html
Requires=network.target
After=network.target

[Service]
Type=simple
WorkingDirectory=/kafka
User=kafka
Group=kafka
ExecStart=/bin/sh -c '/kafka/bin/kafka-server-start.sh /kafka/config/server.properties > /kafka/logs/start-kafka.log 2>&1'
ExecStop=/kafka/bin/kafka-server-stop.sh
TimeoutSec=30
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kafka

case $(hostname) in
kafka1)
cp /tmp/kafka1.properties /kafka/config/server.properties
;;
kafka2)
cp /tmp/kafka2.properties /kafka/config/server.properties
;;
kafka3)
cp /tmp/kafka3.properties /kafka/config/server.properties
;;
esac

sleep 5
service kafka start
