# Deploying a lab

```sh

source init

# essentials
lab run traefik
lab run portainer

# repos
lab run reg
lab run rui
lab run reposilite
lab run static

# idp
lab run keycloak

# observability
lab run prometheus
lab run loki
lab run tempo
lab run alloy
lab run grafana

```

Destroy everything

```sh
source init

# essentials
lab destroy traefik
lab destroy portainer

# repos
lab destroy reg
lab destroy rui
lab destroy reposilite
lab destroy static

# idp
lab destroy keycloak

# observability
lab destroy prometheus
lab destroy loki
lab destroy tempo
lab destroy alloy
lab destroy grafana

```
