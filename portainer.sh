#!/bin/bash

export command=$1

source ./env.sh

# configuration
export servicename=portainer
export exec_as_user=0
export exec_as_group=0

if [ "$command" == "start" ]; then

    # create folders
    create_config_and_data_folder ${servicename} ${exec_as_user} ${exec_as_group}

    # start container
    if docker ps -a --format '{{.Names}}' | grep -q "^${servicename}$"; then
        echo "Container ${servicename} exists. Starting it..."
        docker start ${servicename}
    else
        echo "Container ${servicename} does not exist. Creating and starting it..."

        docker run -d \
        --name "${servicename}" \
        --hostname "${servicename}" \
        --restart unless-stopped \
        --user "${exec_as_user}:${exec_as_group}" \
        --network ${DOCKER_NETWORK_NAME} \
        -v "${DATA_ROOT_FOLDER}/${servicename}/data:/data:rw" \
        -v "/var/run/docker.sock:/var/run/docker.sock:rw" \
        -l "traefik.enable=true" \
        -l "traefik.http.services.${servicename}.loadbalancer.server.port=9000" \
        -l "traefik.http.services.${servicename}.loadbalancer.server.scheme=http" \
        -l "traefik.http.routers.${servicename}.service=${servicename}" \
        -l "traefik.http.routers.${servicename}.entrypoints=https" \
        -l "traefik.http.routers.${servicename}.tls=true" \
        -l "traefik.http.routers.${servicename}.rule=Host(\`${servicename}.${WILDCARD_DOMAIN}\`)" \
        ${portainer_image} \
        --admin-password '$2y$05$lTZ0k373NHegEJjfvCfqSOZCKQHMU2K.xmKYj4FWB5r/YbbOgTV9W'
    fi
    
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${servicename})
    
    http_readiness_check ${servicename} ${ip}:9000

fi

if [ "$command" == "stop" ]; then
  echo "Stopping container ${servicename}..."
  docker stop ${servicename}
fi

if [ "$command" == "destroy" ]; then
  echo "Stopping container ${servicename}..."
  docker stop ${servicename}
  echo "Removing container ${servicename}..."
  docker rm ${servicename}
  delete_config_and_data_folder ${servicename}
fi