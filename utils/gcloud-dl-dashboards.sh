#!/bin/bash

export script_dir="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
export dashboardfolder=$script_dir/../templates/grafana/config/dashboards
source $script_dir/../init


linux_dashboard_ids=(
    node-fleet
    nodes
    node-system
    node-disk
    node-logs
    node-memory
    node-network
)

docker_dashboard_ids=(
    integration-docker-overview
    integration-docker-logs
)

# Linux integration
mkdir -p "$dashboardfolder/Integration - Linux Node"
for id in "${linux_dashboard_ids[@]}"; do
    curl -s "https://ap.grafana.net/api/dashboards/uid/$id" \
    --header "Authorization: Bearer $GCLOUD_AP_GRAFANA_NET_BEARER_TOKEN" | jq '.dashboard' > "$dashboardfolder/Integration - Linux Node/$id.json"
done

# Docker integration
mkdir -p "$dashboardfolder/Integration - Docker"
for id in "${docker_dashboard_ids[@]}"; do
    curl -s "https://ap.grafana.net/api/dashboards/uid/$id" \
    --header "Authorization: Bearer $GCLOUD_AP_GRAFANA_NET_BEARER_TOKEN" | jq '.dashboard' > "$dashboardfolder/Integration - Docker/$id.json"
done

# OpenTelemetry services

mkdir -p "$dashboardfolder/Integration - Application Services/"
curl -o "$dashboardfolder/Integration - Application Services/opentelemetry-for-http-services.json" -s https://raw.githubusercontent.com/alainpham/app-archetypes/refs/heads/master/observability/dashboards/Integration%20-%20Application%20Services/opentelemetry-for-http-services.json