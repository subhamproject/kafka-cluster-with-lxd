#!/bin/bash

KAFKA_TOPIC=${1?Please provide topic name you wish to describe?}

/kafka/bin/kafka-topics.sh --describe --topic $KAFKA_TOPIC --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092
