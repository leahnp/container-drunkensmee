#!/bin/sh
#
# Assumes /input/ has ca.pem and ca-key.pem

mkdir -p /output/kubernetes/ssl
mkdir -p /output/etcd/ssl

# Variables are:
# HOST_NAME - defaults to localhost
# WORKER_IP - defaults to 127.0.0.1
# HOST_IP - defaults to 127.0.0.1

if [ -z "$HOST_NAME" ]; then
  HOST_NAME=localhost
  echo "Did not find host name - defaulting to ${HOST_NAME}";
else
  echo "Found host name - ${HOST_NAME}";
fi

if [ -z "$WORKER_IP" ]; then
  WORKER_IP=127.0.0.1
  echo "Did not find Node IP - defaulting to ${WORKER_IP}";
else
  echo "Found Node IP - ${NODE_IP}";
fi

if [ -z "$HOST_IP" ]; then
  HOST_IP=127.0.0.1
  echo "Did not find Host IP - defaulting to ${HOST_IP}";
else
  echo "Found Host IP - ${HOST_IP}";
fi

export HOST_NAME WORKER_IP HOST_IP

cp /input/ca.pem /output/kubernetes/ssl/ca.pem
openssl genrsa -out /output/kubernetes/ssl/worker-key.pem 2048
openssl req -new -key /output/kubernetes/ssl/worker-key.pem -out /output/kubernetes/ssl/worker.csr -subj "/O=system:nodes/CN=system:node:${HOST_NAME}" -config /assets/worker.conf
openssl x509 -req -in /output/kubernetes/ssl/worker.csr -CA /output/kubernetes/ssl/ca.pem -CAkey /input/ca-key.pem -CAcreateserial -out /output/kubernetes/ssl/worker.pem -days 3650 -extensions v3_req -extfile /assets/worker.conf

openssl genrsa -out /output/kubernetes/ssl/proxy-key.pem 2048
openssl req -new -key /output/kubernetes/ssl/proxy-key.pem -out /output/kubernetes/ssl/proxy.csr -subj "/O=system:node-proxier/CN=system:kube-proxy" -config /assets/worker.conf
openssl x509 -req -in /output/kubernetes/ssl/proxy.csr -CA /output/kubernetes/ssl/ca.pem -CAkey /input/ca-key.pem -CAcreateserial -out /output/kubernetes/ssl/proxy.pem -days 3650 -extensions v3_req -extfile /assets/worker.conf

cp /input/ca.pem /output/etcd/ssl/client-ca.pem
openssl genrsa -out /output/etcd/ssl/client-key.pem 2048
openssl req -new -key /output/etcd/ssl/client-key.pem -out /output/etcd/ssl/client.csr -subj "/CN=etcd-client" -config /assets/etcd_client.conf
openssl x509 -req -in /output/etcd/ssl/client.csr -CA /output/etcd/ssl/client-ca.pem -CAkey /input/ca-key.pem -CAcreateserial -out /output/etcd/ssl/client.pem -days 3650 -extensions v3_req -extfile /assets/etcd_client.conf
