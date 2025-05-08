# Deploying a lab

```sh

# docker network
network.sh

# essentials
./lab.sh traefik start
./lab.sh portainer start

# repos
./lab.sh reg start
./lab.sh rui start
./lab.sh reposilite start
./lab.sh static start

# idp
./lab.sh keycloak start

# observability
./lab.sh prometheus start

```

Destroy everything

```sh
# essentials
./lab.sh traefik destroy
./lab.sh portainer destroy

# repos
./lab.sh reg destroy
./lab.sh rui destroy
./lab.sh reposilite destroy
./lab.sh static destroy

# idp
./lab.sh keycloak destroy

# observability
./lab.sh prometheus destroy
```