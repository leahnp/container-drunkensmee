#!/bin/sh
echo "Use one of the following:

 Please map /etc to /output ( -v /etc:/output )

 /assets/generate_ca.sh : Generates CA

 Requires /input to have ca.pem and ca-key.pem ( -v /path/to/cafolder:/input )

 /assets/generate_apiserver.sh : Generates API certificates
 /assets/generate_etcd.sh : Generates etcd certificates
 /assets/generate_worker.sh : Generates node (worker) certificates
"