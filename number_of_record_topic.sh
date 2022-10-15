#!/bin/bash


KAFKA_TOPIC=$1

[ -v $KAFKA_TOPIC ] && { echo "Please provide kafka topic name you wish to create?" ; exit 1 ; }

CMD_1="kafka.tools.GetOffsetShell --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --topic $KAFKA_TOPIC --time -1"
CMD_2="kafka.tools.GetOffsetShell --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --topic $KAFKA_TOPIC --time -2"

sum_1=$(/kafka/bin/kafka-run-class.sh $CMD_1 | grep -e ':[[:digit:]]*:' | awk -F  ":" '{sum += $3} END {print sum}')

sum_2=$(/kafka/bin/kafka-run-class.sh $CMD_2 | grep -e ':[[:digit:]]*:' | awk -F  ":" '{sum += $3} END {print sum}')


printf "Number of records in topic ${KAFKA_TOPIC} is: "$((sum_1 - sum_2))'\n'
