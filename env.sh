#/bin/bash

export DOCKER_NETWORK_NAME=primenet
export DOCKER_NETWORK_SUBNET=18
export DATA_ROOT_FOLDER=/home/${USER}/apps
export WILDCARD_DOMAIN=zez.duckdns.org
export EXPOSE_BINDADDRESS=127.0.0.1

# Platform

# https://hub.docker.com/_/traefik/tags?page=1&name=3.
# https://github.com/traefik/traefik/releases 
export traefik_image=docker.io/traefik:3.4.0

# https://hub.docker.com/r/portainer/portainer-ce/tags?page=1&name=2.
export portainer_image=portainer/portainer-ce:2.27.5

# Repos

# https://hub.docker.com/_/registry/tags?page=1&name=2.
export reg_image=docker.io/registry:2.8.3
# https://hub.docker.com/r/joxit/docker-registry-ui/tags?page=1&name=2.
export rui_image=joxit/docker-registry-ui:2.5.7
# https://hub.docker.com/r/dzikoysk/reposilite/tags?page=1&name=3.
export reposilite_image=dzikoysk/reposilite:3.5.23
# https://hub.docker.com/r/joseluisq/static-web-server/tags
export static_image=joseluisq/static-web-server:2.33.1

# Minio

# https://hub.docker.com/r/minio/minio/tags
export minio_image=minio/minio:RELEASE.2025-04-22T22-12-26Z

# IDP

# https://quay.io/repository/keycloak/keycloak?tab=tags&tag=latest
export keycloak_image=quay.io/keycloak/keycloak:26.2.3-0

# Observability stack

# https://hub.docker.com/r/prom/prometheus/tags?page=1&name=3.
export prometheus_image=prom/prometheus:v3.3.1

# https://hub.docker.com/r/prom/alertmanager/tags?page=1&name=0.
export alertmanager_image=prom/alertmanager:v0.28.1

# https://hub.docker.com/r/grafana/loki/tags?page=1&name=3.
export loki_image=grafana/loki:3.5.0
# https://hub.docker.com/r/grafana/tempo/tags?page=1&name=2.
export tempo_image=grafana/tempo:2.7.2

# https://hub.docker.com/r/grafana/alloy/tags?page=1&name=v1.
export alloy_image=grafana/alloy:v1.8.3

# https://hub.docker.com/r/otel/opentelemetry-collector-contrib/tags?page=&page_size=&ordering=&name=0.
export otelcol_image=otel/opentelemetry-collector-contrib:0.123.0

# https://hub.docker.com/r/grafana/grafana/tags?page=1&name=12.
export grafana_image=grafana/grafana:12.0.0
export grafana_enterprise_image=grafana/grafana-enterprise:12.0.0

# https://hub.docker.com/r/prom/node-exporter/tags?page=1&name=1.
export node_exporter_image=prom/node-exporter:v1.9.1

# https://console.cloud.google.com/gcr/images/cadvisor/GLOBAL/cadvisor
export cadvisor_image=gcr.io/cadvisor/cadvisor:v0.52.1

# Databases
# https://hub.docker.com/_/mariadb
export mariadb_image=docker.io/mariadb:11.7.2
# https://hub.docker.com/_/mysql/tags?page=1&name=8.
export mysql_image=docker.io/mysql:8.4.5
# https://hub.docker.com/_/postgres
export postgres_image=docker.io/postgres:17.4
# https://hub.docker.com/_/elasticsearch
export elasticsearch_image=docker.io/elasticsearch:8.18.0
export kibana_image=docker.io/kibana:8.18.0
# oracledb: container-registry.oracle.com/database/free:23.3.0.0
export oracledb_image=oracledb:19.3.0
# https://hub.docker.com/_/adminer/tags?page=1&name=4.
export adminer_image=docker.io/adminer:5.2.1

# Messaging
# https://quay.io/repository/strimzi/kafka?tab=tags&tag=latest
export kafka_image=apache/kafka:4.0.0
# https://hub.docker.com/r/obsidiandynamics/kafdrop/tags?page=1&name=4.
export kafdrop_image=obsidiandynamics/kafdrop:4.1.0
# https://hub.docker.com/r/apache/activemq-artemis/tags?page=1&name=2.
export artemis_image=apache/activemq-artemis:2.41.0

# Homelab

# https://hub.docker.com/r/linuxserver/jellyfin/tags?page=1&name=10.
export jellyfin_image=linuxserver/jellyfin:10.10.7

export teddycast_image=registry.awon.cpss.duckdns.org/teddycast:1.0.7
export rentman_image=registry.awon.cpss.duckdns.org/rentman:1.0.4
export pkdex_image=registry.awon.cpss.duckdns.org/pkdex:1.0.4

# https://hub.docker.com/r/linuxserver/wireguard/tags?name=1.
export wireguard_image=linuxserver/wireguard:1.0.20210914

# https://hub.docker.com/r/linuxserver/transmission/tags
export transmission_image=linuxserver/transmission:4.0.6

# https://hub.docker.com/r/linuxserver/nextcloud/tags
export nextcloud_image=linuxserver/nextcloud:31.0.4

# https://hub.docker.com/r/linuxserver/homeassistant/tags
export homeassistant_image=linuxserver/homeassistant:2025.4.4

# https://hub.docker.com/r/syncthing/syncthing/tags?page=&page_size=&ordering=&name=1.
export syncthing_image=syncthing/syncthing:1.29.6

# https://hub.docker.com/r/ollama/ollama/tags?name=0.
export ollama_image=ollama/ollama:0.6.8

# https://github.com/open-webui/open-webui/pkgs/container/open-webui/versions
export openwebui_image=ghcr.io/open-webui/open-webui:0.6.7

# Windows

# https://hub.docker.com/r/dockurr/windows/tags
export windows_image=dockurr/windows:4.35

# Helper functions

function http_readiness_check {
    name=$1
    url=$2
    retries=60
    echo "Checking readiness of $name at $url..."
    for i in $(seq 1 "$retries"); do
        echo "Attempt $i: Checking $name at $url..."
        res=$(curl -f -L -s -m 5 -w "%{http_code}" -o /dev/null "$url")
        if [ "$res" -eq "200" ]; then
            echo "✅ $name OK"
            break
        else
            if [ "$i" -lt "$retries" ]; then
                echo "⏪ Retrying in 5 seconds..."
                sleep 2
            else
                echo "❌ $name FAILED after 10 attempts"
            fi
        fi
    done
}

function create_config_and_data_folder(){
    servicename=$1
    ownername=$2
    groupname=$3

    sudo mkdir -p ${DATA_ROOT_FOLDER}/${servicename}/config
    sudo mkdir -p ${DATA_ROOT_FOLDER}/${servicename}/data

    if [ -d "templates/${servicename}/config" ]; then
    
        sudo cp -r templates/${servicename}/config/* ${DATA_ROOT_FOLDER}/${servicename}/config

        # create config files
        for tmpl_file in templates/${servicename}/config/*.tmpl; do
            echo "Processing template file: ${tmpl_file}"
            output_file=${DATA_ROOT_FOLDER}/${servicename}/config/$(basename "${tmpl_file}" .tmpl)
            envsubst < "${tmpl_file}" | sudo tee "${output_file}" > /dev/null
            echo "Created config file: ${output_file}"
        done
    fi
    sudo chown -R ${ownername}:${groupname} ${DATA_ROOT_FOLDER}/${servicename}

    echo "Created folder structure for service: ${servicename}"
}

function delete_config_and_data_folder(){
    servicename=$1

    sudo rm -rf ${DATA_ROOT_FOLDER}/${servicename}

    echo "Deleted folder structure for service: ${servicename}"
}

