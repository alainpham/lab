#!/bin/bash

export K3S_VERSION='v1.32.5-k3s1'
export DOCKER_NETWORK_NAME=k8s
export DOCKER_NETWORK_SUBNET=19
export NUMBER_OF_CLUSTERS=14
export CLUSTER_MEM=2g

function networking(){

  if [ -z $(docker network ls --filter name=^${DOCKER_NETWORK_NAME}$ --format="{{ .Name }}") ] ; then 
    echo "Setting up dedicated network bridge.."
    docker network create --driver=bridge --subnet=172.${DOCKER_NETWORK_SUBNET}.0.0/16 --gateway=172.${DOCKER_NETWORK_SUBNET}.0.1 ${DOCKER_NETWORK_NAME} ; 
  echo "✅ $DOCKER_NETWORK_NAME docker network created !"
  else
    echo "✅ $DOCKER_NETWORK_NAME docker network exists !"
  fi

}

function startclusters(){

    echo 512 | sudo tee /proc/sys/fs/inotify/max_user_instances

    for ((i=1; i<=NUMBER_OF_CLUSTERS; i++)); do
        echo "Starting cluster $i..."
        docker run  \
            --privileged \
            --name  k3s$i\
            --hostname k3s$i \
            --memory $CLUSTER_MEM \
            --network ${DOCKER_NETWORK_NAME} \
            -d rancher/k3s:$K3S_VERSION \
            server --disable=servicelb,traefik,
    done

}

function startbastion(){
    docker run  \
        --rm \
        --name  bastion \
        --hostname bastion \
        --network ${DOCKER_NETWORK_NAME} \
        -d alainpham/bastion
}

function checkclusters(){
    for ((i=1; i<=NUMBER_OF_CLUSTERS; i++)); do
        docker exec k3s1 kubectl get pods -A
    done
}

function stopclusters(){

    for ((i=1; i<=NUMBER_OF_CLUSTERS; i++)); do
        echo "Stopping cluster $i..."
        docker stop k3s$i
        docker rm k3s$i
    done

}