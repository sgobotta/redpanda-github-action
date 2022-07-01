#!/bin/sh

NODE_ID=$INPUT_NODE_ID
HOSTNAME=redpanda-$INPUT_NODE_ID
REDPANDA_NETWORK=$INPUT_REDPANDA_NETWORK
KAFKA_API_PORT=$INPUT_KAFKA_API_PORT
ADMIN_API_PORT=$INPUT_ADMIN_API_PORT
PANDA_PROXY_PORT=$INPUT_PANDA_PROXY_PORT
SCHEMA_REGISTRY_PORT=$INPUT_SCHEMA_REGISTRY_PORT
RPC_PORT=$INPUT_RPC_PORT

if [ -z "${INPUT_REDPANDA_SEEDS}" ]; then
  REDPANDA_SEEDS=""
else
  REDPANDA_SEEDS="--seeds \"$INPUT_REDPANDA_SEEDS\""
fi

echo "Starting Redpanda '$INPUT_VERSION' with.."
echo "NODE_ID: $NODE_ID"
echo "HOSTNAME: $HOSTNAME"
echo "REDPANDA_NETWORK: $REDPANDA_NETWORK"
echo "REDPANDA_SEEDS: $REDPANDA_SEEDS"
echo "KAFKA_API_PORT: $KAFKA_API_PORT"
echo "ADMIN_API_PORT: $ADMIN_API_PORT"
echo "PANDA_PROXY_PORT: $PANDA_PROXY_PORT"
echo "SCHEMA_REGISTRY_PORT: $SCHEMA_REGISTRY_PORT"
echo "RPC_PORT: $RPC_PORT"

echo "Creating Redpanda network.."
sh -c "docker network create -d bridge $REDPANDA_NETWORK || true"

run_redpanda="docker run -d --name=$HOSTNAME --hostname=$HOSTNAME --net=$REDPANDA_NETWORK -p $KAFKA_API_PORT:9092 -p $ADMIN_API_PORT:9644 -p $PANDA_PROXY_PORT:8082 -p $SCHEMA_REGISTRY_PORT:8081 -v $HOSTNAME:/var/lib/redpanda/data docker.vectorized.io/vectorized/redpanda:$INPUT_VERSION redpanda start --overprovisioned --smp 1 --memory 1G --reserve-memory 0M --node-id $NODE_ID $REDPANDA_SEEDS --kafka-addr INSIDE://0.0.0.0:29092,OUTSIDE://0.0.0.0:$KAFKA_API_PORT --advertise-kafka-addr INSIDE://$HOSTNAME:29092,OUTSIDE://localhost:$KAFKA_API_PORT --pandaproxy-addr INSIDE://0.0.0.0:28082,OUTSIDE://0.0.0.0:$PANDA_PROXY_PORT --advertise-pandaproxy-addr INSIDE://$HOSTNAME:28082,OUTSIDE://localhost:$PANDA_PROXY_PORT --rpc-addr 0.0.0.0:$RPC_PORT --advertise-rpc-addr $HOSTNAME:$RPC_PORT"

echo "Running: $run_redpanda"

sh -c "$run_redpanda"
