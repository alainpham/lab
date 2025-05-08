#!/bin/bash

# configuration
export exec_as_user=0
export exec_as_group=0
export service_check_path=":8080/metrics"

function runsvc(){

    docker run -d \
        --name "${service_name}" \
        --hostname "${service_name}" \
        --restart unless-stopped \
        --user "${exec_as_user}:${exec_as_group}" \
        --network ${DOCKER_NETWORK_NAME} \
        -v "${DATA_ROOT_FOLDER}/${service_name}/config/config.yaml:/config/config.yaml:ro" \
        -v "${DATA_ROOT_FOLDER}/${service_name}/config/tls.yaml:/config/tls.yaml:ro" \
        -v "${DATA_ROOT_FOLDER}/tls:/certs:ro" \
        -v "/var/run/docker.sock:/var/run/docker.sock:ro" \
        -l "traefik.enable=true" \
        -l "traefik.http.services.${service_name}.loadbalancer.server.port=8080" \
        -l "traefik.http.services.${service_name}.loadbalancer.server.scheme=http" \
        -l "traefik.http.routers.${service_name}.service=${service_name}" \
        -l "traefik.http.routers.${service_name}.entrypoints=https" \
        -l "traefik.http.routers.${service_name}.tls=true" \
        -l "traefik.http.routers.${service_name}.rule=Host(\`${service_name}.${WILDCARD_DOMAIN}\`)" \
        -l "traefik.http.routers.${service_name}.middlewares=${service_name}_basicauth" \
        -l "traefik.http.middlewares.${service_name}_basicauth.basicauth.users=admin:\$2y\$05\$Qa5WcbQT1GhUdXzA/9sLhei79T1w9TXHWfqvxOYfADI5GndMy8uVW" \
        -p "80:80" \
        -p "443:443" \
        ${service_image} \
        traefik -configFile=/config/config.yaml

}
