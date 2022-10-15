#!/bin/bash


KAFKA_TOPIC=$1

[ -v $KAFKA_TOPIC ] && { echo "Please provide kafka topic name you wish to produce message to?" ; exit 1 ; }

CMD="--broker-list kafka1:9092,kafka2:9092,kafka3:9092 --topic $KAFKA_TOPIC"

/kafka/bin/kafka-console-producer.sh $CMD
