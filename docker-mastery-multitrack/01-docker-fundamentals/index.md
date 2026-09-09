# 01 — Containers and images

## Learning objectives

Explain container lifecycle, isolation and published ports. Allow 60–90 minutes.

## Prerequisites

Module 00 completed.

## Exercise

An **image** packages filesystem layers and runtime metadata. A **container** is a running or stopped instance with its own lifecycle and writable layer. Linux containers use the host kernel; Docker Desktop supplies a Linux environment through a VM. Containers isolate processes, but they are not separate kernels or a complete security boundary.

From the repository root, use a name that is not already in use:

```bash
docker run --name docker-learning-basics -d -p 127.0.0.1:8080:80 nginx:stable-alpine
curl --fail http://127.0.0.1:8080/
docker ps
docker logs docker-learning-basics
docker inspect docker-learning-basics
docker exec docker-learning-basics sh -c 'echo hello > /tmp/lesson.txt'
docker stop docker-learning-basics
docker start docker-learning-basics
docker exec docker-learning-basics cat /tmp/lesson.txt
```

The file survives stop/start because this is the same container. The tag `stable-alpine` can move; an image digest identifies particular image content. The `-p` option publishes container port 80 on local host port 8080. Binding to `127.0.0.1` limits the listener to the local host.

Now replace the container:

```bash
docker rm -f docker-learning-basics
docker run --name docker-learning-basics -d -p 127.0.0.1:8080:80 nginx:stable-alpine
docker exec docker-learning-basics cat /tmp/lesson.txt
```

Expect `cat` to fail: the new container has a new writable layer. Removing a container does not remove the underlying image. `EXPOSE` in an image describes an intended port; it does not publish that port on the host.

Clean up only this exercise:

```bash
docker rm -f docker-learning-basics
```

Reading: [Container concepts](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/), [port publishing](https://docs.docker.com/engine/network/port-publishing/).

## Check your understanding

Explain image versus container, stop versus remove, and host versus container port. Predict whether a file survives each operation before repeating the experiment.
