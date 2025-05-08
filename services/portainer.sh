#!/bin/bash

# configuration
export exec_as_user=0
export exec_as_group=0
export service_check_path=":9000"

function runsvc(){

    docker run -d \
        --name "${service_name}" \
        --hostname "${service_name}" \
        --restart unless-stopped \
        --user "${exec_as_user}:${exec_as_group}" \
        --network ${DOCKER_NETWORK_NAME} \
        -v "${DATA_ROOT_FOLDER}/${service_name}/data:/data:rw" \
        -v "/var/run/docker.sock:/var/run/docker.sock:rw" \
        -l "traefik.enable=true" \
        -l "traefik.http.services.${service_name}.loadbalancer.server.port=9000" \
        -l "traefik.http.services.${service_name}.loadbalancer.server.scheme=http" \
        -l "traefik.http.routers.${service_name}.service=${service_name}" \
        -l "traefik.http.routers.${service_name}.entrypoints=https" \
        -l "traefik.http.routers.${service_name}.tls=true" \
        -l "traefik.http.routers.${service_name}.rule=Host(\`${service_name}.${WILDCARD_DOMAIN}\`)" \
        -p "${EXPOSE_BINDADDRESS}:9000:9000" \
        ${service_image} \
        --admin-password '$2y$05$lTZ0k373NHegEJjfvCfqSOZCKQHMU2K.xmKYj4FWB5r/YbbOgTV9W'
}
