#!/bin/bash

# configuration
export exec_as_user=1000
export exec_as_group=1000
export service_check_path=":80"

function runsvc(){

    docker run -d \
        --name "${service_name}" \
        --hostname "${service_name}" \
        --restart unless-stopped \
        --user "${exec_as_user}:${exec_as_group}" \
        --network ${DOCKER_NETWORK_NAME} \
        -e "SERVER_DIRECTORY_LISTING=true" \
        -v "${DATA_ROOT_FOLDER}/${service_name}/data:/public:rw" \
        -l "traefik.enable=true" \
        -l "traefik.http.services.${service_name}.loadbalancer.server.port=80" \
        -l "traefik.http.services.${service_name}.loadbalancer.server.scheme=http" \
        -l "traefik.http.routers.${service_name}.service=${service_name}" \
        -l "traefik.http.routers.${service_name}.entrypoints=https" \
        -l "traefik.http.routers.${service_name}.tls=true" \
        -l "traefik.http.routers.${service_name}.rule=Host(\`${service_name}.${WILDCARD_DOMAIN}\`)" \
        -p "${EXPOSE_BINDADDRESS}:20081:80" \
        ${static_image}
    
}
