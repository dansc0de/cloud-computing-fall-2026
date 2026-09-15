# Linux namespaces

A container is a process with a restricted view. Build that view by hand, then find it in Docker.

## PID + UTS

```bash
hostname
sudo unshare --pid --uts --fork --mount-proc bash
```

Inside the new namespaces:

```bash
hostname not-my-vm
ps aux              # bash is PID 1
```

In a second terminal (`multipass shell in-class`), run `hostname`. The VM is unchanged.

```bash
exit
```

## Network

```bash
sudo ip netns add demo
sudo ip netns exec demo ip addr               # only lo, and it is DOWN
sudo ip netns exec demo ping -c 1 8.8.8.8     # Network is unreachable
```

## Docker more automagically

```bash
docker run -d --name web nginx
PID=$(docker inspect -f '{{.State.Pid}}' web)

docker rm -f web
```