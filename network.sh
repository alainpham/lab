#/bin/bash

source "$(dirname "$0")/env.sh"

echo "Setting up dedicated network bridge.."

if [ -z $(docker network ls --filter name=^${DOCKER_NETWORK_NAME}$ --format="{{ .Name }}") ] ; then 
     docker network create --driver=bridge --subnet=172.${DOCKER_NETWORK_SUBNET}.0.0/16 --gateway=172.${DOCKER_NETWORK_SUBNET}.0.1 ${DOCKER_NETWORK_NAME} ; 
     echo "✅ $DOCKER_NETWORK_NAME docker network created !"
else
     echo "✅ $DOCKER_NETWORK_NAME already exisits ! "
fi