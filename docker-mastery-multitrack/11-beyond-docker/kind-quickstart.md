# A first Kubernetes deployment with kind

## Learning objectives

Load your image, expose it locally and observe a controller replacing a Pod. Allow 30–45 minutes plus first-time downloads.

## Prerequisites

Completed Docker path; Docker, kind 0.33.0 and kubectl compatible with Kubernetes 1.35. The lab uses node image 1.35.8. Install tools using the official links below and allow several additional GB of memory/disk space.

## Exercise

kind runs Kubernetes nodes as containers. One disposable local node is enough for this experiment; no permanent server is needed.

| Familiar concept | New concept | Key difference |
| --- | --- | --- |
| Application container | Pod | Kubernetes schedules and replaces Pods |
| Service configuration | Deployment | A controller reconciles desired replicas |
| Compose service name | Service | A stable endpoint selects matching Pods |
| Health check | Probes | Startup, readiness and liveness have distinct effects |

## Deploy your image

Run from the repository root. Check `kind get clusters` first: use `docker-learning` only if that name is free. The separate kubeconfig keeps these commands scoped to the lab.

```bash
kind get clusters
mkdir -p reports
kind create cluster --name docker-learning --config docker-mastery-multitrack/11-beyond-docker/kind/kind.yaml --image kindest/node:v1.35.8@sha256:07b2536e30b803ed61d1677a79df6115f798ce64c80f9e22f6ed45afd09323c0 --kubeconfig reports/kind.kubeconfig --wait 120s
export TASK_TRACK=python
docker build -t task-api:kind "docker-mastery-multitrack/02-language-quickstart/$TASK_TRACK"
kind load docker-image task-api:kind --name docker-learning
kubectl --kubeconfig reports/kind.kubeconfig apply -f docker-mastery-multitrack/11-beyond-docker/kind/task-api.yaml
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning rollout status deployment/task-api --timeout=180s
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning port-forward --address 127.0.0.1 service/task-api 8081:8080
```

In a second terminal at the repository root:

```bash
python3 scripts/api_contract.py --base-url http://127.0.0.1:8081
```

The manifest uses `imagePullPolicy: Never`; the image must be loaded into kind with exactly the expected name. If the Pod cannot start, inspect `kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning describe pods` for events such as `ErrImageNeverPull`.

## Observe replacement

Stop port forwarding with Ctrl+C. Inspect the Pod name, delete it, then inspect the replacement:

```bash
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning get pods
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning delete pod -l app=task-api
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning rollout status deployment/task-api --timeout=180s
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning get pods
```

The Deployment maintains one replica and creates a new Pod. Its tasks are empty because they belonged to the old process. Restart port forwarding to query the replacement. A Service does not share application memory between Pods.

Read the three probes in `kind/task-api.yaml`: startup delays the other checks until startup succeeds; readiness failure removes a Pod from regular Service traffic; repeated liveness failures can restart its container. They all use `/health` here because the API has no external dependencies.

## Cleanup

Stop port forwarding and remove only the cluster and image created for this lab:

```bash
kind delete cluster --name docker-learning
rm -f reports/kind.kubeconfig
docker image rm task-api:kind
```

For an automated repetition, `python3 scripts/validate_kind.py --track python` creates and removes its own cluster. The **Optional kind lab** workflow is a separate manual check.

Reading: [kind quick start](https://kind.sigs.k8s.io/docs/user/quick-start/), [install kubectl](https://kubernetes.io/docs/tasks/tools/), [Kubernetes probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/).

## Check your understanding

Explain image loading, Deployment reconciliation and Service selection using your observations. Identify what this single-node exercise does not demonstrate: multi-node availability, durable task storage or production networking.
