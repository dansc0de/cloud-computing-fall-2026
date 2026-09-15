# Demo 2: Docker networking

```bash
docker network ls
ip addr show docker0
```

## Default bridge

```bash
docker run -d --name web nginx
docker run -d --name client alpine sleep 3600

docker network inspect bridge
WEB_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web)
echo $WEB_IP

docker exec client wget -qO- http://$WEB_IP | head -4   # works by IP
docker exec client wget -qO- http://web                 # fails: no DNS on the default bridge

ip link | grep veth                                     # one veth per container
```

## User-defined network

```bash
docker network create classnet
docker network connect classnet web
docker network connect classnet client

docker exec client wget -qO- http://web | head -4       # works: Docker's embedded DNS
docker exec client cat /etc/resolv.conf                 # nameserver 127.0.0.11

docker network inspect classnet \
  -f '{{range .Containers}}{{.Name}} {{.IPv4Address}}{{println}}{{end}}'
docker inspect web -f '{{json .NetworkSettings.Networks}}' | jq
```

`web` now has two IPs, one per network.

## Publishing ports

```bash
docker port web                                         # empty: nothing published

docker run -d --name pub -p 8080:80 nginx
docker port pub
docker inspect pub -f '{{json .NetworkSettings.Ports}}' | jq
curl -s localhost:8080 | head -4
```

## Cleanup

```bash
docker rm -f web client pub
docker network rm classnet
```