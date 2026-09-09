# 11 — Beyond Docker (optional)

## Learning objectives

Compare container tools and try a small local Kubernetes lab. Allow 45–60 minutes including the optional lab.

## Prerequisites

The Docker capstone. The tool comparison needs no installation; the kind lab needs kind, kubectl and additional memory/disk space.

## Exercise

Use this short continuation to place Docker in the wider container ecosystem. Read the comparison, then optionally deploy your existing image to a disposable one-node kind cluster.

- [Where Docker fits](container-tools.md)
- [A first Kubernetes deployment with kind](kind-quickstart.md)

```{toctree}
:hidden:
:maxdepth: 1

container-tools
kind-quickstart
```

The lab covers image loading, a Deployment, a Service and Pod replacement. It is an introduction, not a Kubernetes administration course. Cluster installation for production, ingress, persistent storage, Helm, operators and multi-node availability belong in a dedicated Kubernetes learning path.

## Check your understanding

Explain which Docker skills transfer to another runtime or Kubernetes, and which new responsibilities need further study. If you run kind, verify replacement of a Pod and remove the lab cluster afterwards.
