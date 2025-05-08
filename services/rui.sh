#!/bin/bash

# configuration
export exec_as_user=0
export exec_as_group=0
export service_check_path=":80/v2/"

function runsvc(){

    docker run -d \
        --name "${service_name}" \
        --hostname "${service_name}" \
        --restart unless-stopped \
        --user "${exec_as_user}:${exec_as_group}" \
        --network ${DOCKER_NETWORK_NAME} \
        -e "NGINX_PROXY_PASS_URL=http://reg:5000" \
        -e "DELETE_IMAGES=true" \
        -e "SINGLE_REGISTRY=true" \
        -l "traefik.enable=true" \
        -l "traefik.http.services.${service_name}.loadbalancer.server.port=80" \
        -l "traefik.http.services.${service_name}.loadbalancer.server.scheme=http" \
        -l "traefik.http.routers.${service_name}.service=${service_name}" \
        -l "traefik.http.routers.${service_name}.entrypoints=https" \
        -l "traefik.http.routers.${service_name}.tls=true" \
        -l "traefik.http.routers.${service_name}.rule=Host(\`${service_name}.${WILDCARD_DOMAIN}\`)" \
        -p "${EXPOSE_BINDADDRESS}:20080:80" \
        ${service_image}
}
