#!/bin/bash

export script_dir="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
export dashboardfolder=$script_dir/../templates/grafana/config/dashboards
source $script_dir/../init


dashboard_ids=(
    node-fleet
    nodes
    node-system
    node-disk
    node-logs
    node-memory
    node-network
)

# Linux integration
mkdir -p "$dashboardfolder/Integration - Linux Node"
for id in "${dashboard_ids[@]}"; do
    curl -s "https://ap.grafana.net/api/dashboards/uid/$id" \
    --header "Authorization: Bearer $GCLOUD_AP_GRAFANA_NET_BEARER_TOKEN" | jq '.dashboard' > "$dashboardfolder/Integration - Linux Node/$id.json"
done

# OpenTelemetry services

mkdir -p "$dashboardfolder/Integration - Application Services/"
curl -o "$dashboardfolder/Integration - Application Services/opentelemetry-for-http-services.json" -s https://raw.githubusercontent.com/alainpham/app-archetypes/refs/heads/master/observability/dashboards/opentelemetry-for-http-services.json