# Week 4: Containers

## Setup

On your laptop, from this folder:

```bash
multipass launch 24.04 -n in-class --cloud-init cloud-init.yaml --mount "$PWD/hello-api":/home/ubuntu/hello-api
multipass shell in-class
```

Inside the VM:

```bash
docker run --rm hello-world
```

## Demos

1. [Linux namespaces](demos/linux-namespaces.md)
2. [Docker networking](demos/docker-networking.md)
3. [Building an image](demos/building-an-image.md)

## Cleanup

```bash
multipass delete --purge in-class
```