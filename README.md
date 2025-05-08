# Deploying a lab

```sh
export PATH=$PATH:$(pwd)/services

# docker network
network.sh

# essentials
traefik.sh start
portainer.sh start

# repos
reg.sh start
rui.sh start
reposilite.sh start
static.sh start

# observability
prometheus.sh start

```