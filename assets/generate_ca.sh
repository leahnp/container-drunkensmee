#!/bin/sh

openssl genrsa -out /output/ca-key.pem 2048
openssl req -x509 -new -nodes -key /output/ca-key.pem -days 7300 -out /output/ca.pem -subj "/CN=kraken-ca"
