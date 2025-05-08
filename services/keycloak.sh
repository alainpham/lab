#!/bin/bash

# configuration
export exec_as_user=1000
export exec_as_group=1000
export service_check_path=":8080/realms/master"

function runsvc(){

    docker run -d \
        --name "${service_name}" \
        --hostname "${service_name}" \
        --restart unless-stopped \
        --user "${exec_as_user}:${exec_as_group}" \
        --network ${DOCKER_NETWORK_NAME} \
        -e KC_HTTP_ENABLED="true" \
        -e KC_HOSTNAME="https://${service_name}.${WILDCARD_DOMAIN}" \
        -e KC_HOSTNAME_ADMIN="https://${service_name}.${WILDCARD_DOMAIN}" \
        -e KC_HOSTNAME_STRICT="false" \
        -e KC_PROXY_ADDRESS_FORWARDING="true" \
        -e KC_HEALTH_ENABLED="true" \
        -e KC_METRICS_ENABLED="true" \
        -e KC_BOOTSTRAP_ADMIN_USERNAME="admin" \
        -e KC_BOOTSTRAP_ADMIN_PASSWORD="password" \
        -v "${DATA_ROOT_FOLDER}/${service_name}/data:/opt/keycloak/data:rw" \
        -l "traefik.enable=true" \
        -l "traefik.http.services.${service_name}.loadbalancer.server.port=8080" \
        -l "traefik.http.services.${service_name}.loadbalancer.server.scheme=http" \
        -l "traefik.http.routers.${service_name}.service=${service_name}" \
        -l "traefik.http.routers.${service_name}.entrypoints=https" \
        -l "traefik.http.routers.${service_name}.tls=true" \
        -l "traefik.http.routers.${service_name}.rule=Host(\`${service_name}.${WILDCARD_DOMAIN}\`)" \
        -p "${EXPOSE_BINDADDRESS}:28003:8080" \
        ${service_image} \
        start
    
}
