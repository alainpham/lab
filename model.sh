#!/bin/bash

export command=$1

source ./env.sh

# configuration
export servicename=model
export exec_as_user=root
export exec_as_group=root

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
        -v "${DATA_ROOT_FOLDER}/${servicename}/config:/config:ro" \
        -v "${DATA_ROOT_FOLDER}/${servicename}/data:/data:rw" \
        -l "traefik.enable=true" \
        -l "traefik.http.services.${servicename}.loadbalancer.server.port=8080" \
        -l "traefik.http.services.${servicename}.loadbalancer.server.scheme=http" \
        -l "traefik.http.routers.${servicename}.service=${servicename}" \
        -l "traefik.http.routers.${servicename}.entrypoints=https" \
        -l "traefik.http.routers.${servicename}.tls=true" \
        -l "traefik.http.routers.${servicename}.rule=Host(\`${servicename}.${WILDCARD_DOMAIN}\`)" \
        -p "8080:8080" \
        ${model_image} \
        model -configFile=/config/config.yaml
    fi
    
    ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${servicename})
    
    http_readiness_check ${servicename} ${ip}:8080/metrics

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