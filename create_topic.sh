#!/bin/bash

TOPIC=${1?Please Provide Kafka Topic name you wish to create?}

/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --replication-factor 3 --partitions 100 --topic $1
