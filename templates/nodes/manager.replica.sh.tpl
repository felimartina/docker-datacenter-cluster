#!/bin/bash

${DOCKER_INSTALL}

NODE_PUBLIC_IP=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
NODE_PRIVATE_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)

docker swarm join --listen-addr $NODE_PRIVATE_IP:2377 --advertise-addr $NODE_PUBLIC_IP:2377 --token ${UCP_TOKEN} ${UCP_PUBLIC_ENDPOINT}:2377

docker container run --rm -t --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp join \
  --replica \
  --host-address ${UCP_PUBLIC_ENDPOINT} \
  --admin-username ${DOCKER_UCP_USERNAME} \
  --admin-password ${DOCKER_UCP_PASSWORD} \
  --san ${UCP_PUBLIC_ENDPOINT} \
  --san ${ELB_MANAGER_NODES} \
  --san ${ELB_MASTER_NODES}


curl -k https://${UCP_PUBLIC_ENDPOINT}/ca > ucp-ca.pem


docker run -t --rm docker/dtr join \
  --existing-replica-id ${DTR_REPLICA_ID} \
  --ucp-username ${DOCKER_UCP_USERNAME} \
  --ucp-password ${DOCKER_UCP_PASSWORD} \
  --ucp-url https://${UCP_PUBLIC_ENDPOINT} \
  --ucp-ca "$(cat ucp-ca.pem)" \
  --replica-http-port ${DTR_HTTP_PORT} \
  --replica-https-port ${DTR_HTTPS_PORT}