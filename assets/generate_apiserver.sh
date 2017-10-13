#!/bin/sh
#
# Assumes /input/ has ca.pem and ca-key.pem

mkdir -p /output/kubernetes/ssl
mkdir -p /output/etcd/ssl

# Variables are:
# SERVICE_DNS_NAME - defaults to localhost
# SERVICE_SHORT_NAME - defaults to localhost
# CUSTOM_API_DNS - defaults to localhost
# SERVICE_IP - defaults to 127.0.0.1
# HOST_IP - defaults to 127.0.0.1

if [ -z "$SERVICE_DNS_NAME" ]; then
  export SERVICE_DNS_NAME=localhost
  echo "Did not find Service DNS Name - defaulting to ${SERVICE_DNS_NAME}";
else
  echo "Found Service DNS Name - ${SERVICE_DNS_NAME}";
fi
SERVICE_SHORT_NAME=${SERVICE_DNS_NAME%%.*}

if [ -z "$CUSTOM_API_DNS" ]; then
  export CUSTOM_API_DNS=localhost
  echo "Did not find a custom ELB DNS Name for the API Server - defaulting to ${CUSTOM_API_DNS}";
else
  echo "Found custom ELB DNS Name for the API Server - ${CUSTOM_API_DNS}";
fi

if [ -z "$SERVICE_IP" ]; then
  export SERVICE_IP=127.0.0.1
  echo "Did not find Service IP - defaulting to ${SERVICE_IP}";
else
  echo "Found Service IP - ${SERVICE_IP}";
fi

if [ -z "$KUBE_SERVICE_IP" ]; then
  export KUBE_SERVICE_IP=127.0.0.1
  echo "Did not find Service IP - defaulting to ${KUBE_SERVICE_IP}";
else
  echo "Found Service IP - ${KUBE_SERVICE_IP}";
fi

if [ -z "$HOST_IP" ]; then
  export HOST_IP=127.0.0.1
  echo "Did not find Host IP - defaulting to ${HOST_IP}";
else
  echo "Found Host IP - ${HOST_IP}";
fi

cp /input/ca.pem /output/kubernetes/ssl/ca.pem
openssl genrsa -out /output/kubernetes/ssl/apiserver-key.pem 2048
openssl req -new -key /output/kubernetes/ssl/apiserver-key.pem -out /output/kubernetes/ssl/apiserver.csr -subj "/O=system:nodes,/CN=system:node:${SERVICE_SHORT_NAME}" -config /assets/apiserver.conf
openssl x509 -req -in /output/kubernetes/ssl/apiserver.csr -CA /output/kubernetes/ssl/ca.pem -CAkey /input/ca-key.pem -CAcreateserial -out /output/kubernetes/ssl/apiserver.pem -days 3650 -extensions v3_req -extfile /assets/apiserver.conf

cp /input/ca.pem /output/etcd/ssl/client-ca.pem
openssl genrsa -out /output/etcd/ssl/client-key.pem 2048
openssl req -new -key /output/etcd/ssl/client-key.pem -out /output/etcd/ssl/client.csr -subj "/CN=etcd-client" -config /assets/etcd_client.conf
openssl x509 -req -in /output/etcd/ssl/client.csr -CA /output/etcd/ssl/client-ca.pem -CAkey /input/ca-key.pem -CAcreateserial -out /output/etcd/ssl/client.pem -days 3650 -extensions v3_req -extfile /assets/etcd_client.conf
