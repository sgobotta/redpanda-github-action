#!/bin/sh

if [ -z "${INPUT_REDPANDA_NETWORK}" ]; then
  NETWORK_FLAG=""
else
  NETWORK_FLAG="--net=$INPUT_REDPANDA_NETWORK"
fi

KAFKA_API_PORT=$INPUT_KAFKA_API_PORT
ADMIN_API_PORT=$INPUT_ADMIN_API_PORT
PANDA_PROXY_PORT=$INPUT_PANDA_PROXY_PORT
SCHEMA_REGISTRY_PORT=$INPUT_SCHEMA_REGISTRY_PORT
RPC_PORT=$INPUT_RPC_PORT
NODE_ID=$INPUT_NODE_ID

echo "echoing... $NETWORK_FLAG"
echo "echoing... $KAFKA_API_PORT"
echo "echoing... $ADMIN_API_PORT"
echo "echoing... $PANDA_PROXY_PORT"
echo "echoing... $SCHEMA_REGISTRY_PORT"
echo "echoing... $RPC_PORT"
echo "echoing... $NODE_ID"

HOSTNAME=redpanda-$INPUT_NODE_ID

docker_run="docker run"

run_redpanda="$docker_run -d --name=$HOSTNAME --hostname=$HOSTNAME $NETWORK_FLAG -p $KAFKA_API_PORT:9092 -p $ADMIN_API_PORT:9644 -p $PANDA_PROXY_PORT:8082 -p $SCHEMA_REGISTRY_PORT:8081 docker.vectorized.io/vectorized/redpanda:$INPUT_VERSION redpanda start --overprovisioned --smp 1 --memory 1G --reserve-memory 0M --node-id $NODE_ID --kafka-addr INSIDE://0.0.0.0:29092,OUTSIDE://0.0.0.0:$KAFKA_API_PORT --advertise-kafka-addr INSIDE://$HOSTNAME:29092,OUTSIDE://0.0.0.0:$KAFKA_API_PORT --pandaproxy-addr INSIDE://0.0.0.0:28082,OUTSIDE://0.0.0.0:$PANDA_PROXY_PORT --advertise-pandaproxy-addr INSIDE://$HOSTNAME:28082,OUTSIDE://0.0.0.0:$PANDA_PROXY_PORT --rpc-addr 0.0.0.0:$RPC_PORT --advertise-rpc-addr $HOSTNAME:$RPC_PORT"

echo "echoing... $run_redpanda"

sh -c "$run_redpanda"
