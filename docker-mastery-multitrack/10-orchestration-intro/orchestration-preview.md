# 10 – Optional: Kubernetes mit kind

## Lernziele

Du überträgst dein Containerwissen auf Pod, Deployment und Service, beobachtest die Wiederherstellung
eines Pods und unterscheidest Startup-, Readiness- und Liveness-Probes. Richtwert: 60–90 Minuten.

## Voraussetzung

Module 00–09. Docker, kind und kubectl sind verfügbar; installiere kind gemäß
[offizieller Anleitung](https://kind.sigs.k8s.io/docs/user/quick-start/) und kubectl gemäß
[Kubernetes-Anleitung](https://kubernetes.io/docs/tasks/tools/).
Dieses Labor verwendet kind `v0.33.0` mit dem dafür veröffentlichten Kubernetes-Node-Image `v1.35.8`.
Verwende kubectl 1.35 oder eine nach Kubernetes-Versionsregeln kompatible Version.
Plane zusätzlich mehrere GB RAM und Speicher ein und beende nicht benötigte Labore.

## Warum kind hier passt

kind startet Kubernetes-Knoten als Container. Das ist für ein wegwerfbares Lern- und Testcluster
geeignet. Ein zusätzlicher dauerhaft laufender „Server“ ist für diesen Kurs nicht nötig.
Ein einzelner lokaler Knoten reicht für Deployment, Service, Imageverteilung und Probes.
Er bildet keine Hochverfügbarkeit, produktiven Storage oder Cloud-LoadBalancer realistisch ab.

| Docker-/Compose-Begriff | Kubernetes-Bezug | Wichtiger Unterschied |
| --- | --- | --- |
| Container | Container in einem Pod | Ein Pod hat einen eigenen Lebenszyklus |
| Servicekonfiguration | Deployment | Controller gleicht Soll- und Istzustand ab |
| Servicename / Netzwerk | Service und Cluster-DNS | Service selektiert passende Pods |
| Healthcheck | Probes | Readiness und Liveness haben verschiedene Wirkungen |
| Named Volume | PVC / StorageClass | Bereitstellung und Dauerhaftigkeit hängen vom Cluster ab |

## Übung

Alle Befehle im Repository-Wurzelverzeichnis, Bash. Verwende den Namen `docker-learning` nur,
wenn noch kein gleichnamiges kind-Cluster existiert; andernfalls wähle einen eigenen Namen und
passe alle Befehle zusammen an. Die separate kubeconfig vermeidet den Wechsel deines normalen Kontexts.

```bash
kind get clusters
mkdir -p reports
kind create cluster --name docker-learning --config docker-mastery-multitrack/10-orchestration-intro/kind.yaml --image kindest/node:v1.35.8@sha256:07b2536e30b803ed61d1677a79df6115f798ce64c80f9e22f6ed45afd09323c0 --kubeconfig reports/kind.kubeconfig --wait 120s
export TASK_TRACK=python
docker build -t task-api:kind "docker-mastery-multitrack/02-language-quickstart/$TASK_TRACK"
kind load docker-image task-api:kind --name docker-learning
kubectl --kubeconfig reports/kind.kubeconfig apply -f docker-mastery-multitrack/10-orchestration-intro/task-api.yaml
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning rollout status deployment/task-api --timeout=180s
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning get pods,services
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning port-forward --address 127.0.0.1 service/task-api 8081:8080
```

Im zweiten Terminal, ebenfalls im Repository-Wurzelverzeichnis:

```bash
python3 scripts/api_contract.py --base-url http://127.0.0.1:8081 --report reports/kind-api.json
```

Das Image muss auf allen verwendeten kind-Knoten vorhanden sein. `imagePullPolicy: Never` verhindert,
dass Kubernetes das lokale Lehrimage aus einer Registry laden will. Ein `ImagePullBackOff` oder
`ErrImageNeverPull` weist unter anderem auf fehlendes Laden oder einen abweichenden Namen hin.

### Wiederherstellung beobachten

Beende Port-Forwarding mit Ctrl+C. Lösche dann nur den Pod dieses Labors:

```bash
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning delete pod -l app=task-api
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning rollout status deployment/task-api --timeout=180s
kubectl --kubeconfig reports/kind.kubeconfig -n docker-learning get pods
```

Das Deployment erzeugt einen Ersatz. Die Aufgaben des alten Prozesses sind verloren. Starte
Port-Forwarding für den Ersatz erneut, bevor du HTTP testest. Ein Service-Name bedeutet nicht,
dass die Anwendung ihren Zustand mit anderen Pods teilt. Deshalb verwendet das Manifest eine Replik.

### Probes lesen

Die Startup-Probe lässt Zeit für den Start; bis dahin greifen Liveness und Readiness noch nicht.
Eine fehlgeschlagene Readiness nimmt den Pod aus regulären Service-Endpunkten. Wiederholt fehlschlagende
Liveness kann einen Containerneustart auslösen. Hier verwenden alle `/health`, da keine externen
Abhängigkeiten existieren. Bei einer Datenbankanbindung müssen die Bedeutungen getrennt werden.

## Erfolgskontrolle

Du kannst Pod-Ersetzung, Image-Laden und Port-Forwarding erklären. Der HTTP-Vertrag läuft erfolgreich.
Als optionale automatisierte Wiederholung dient `python3 scripts/validate_kind.py --track python`;
auch Rust und Java sind möglich. Er verwendet ein eigenes Cluster und löscht es anschließend.
Die reguläre CI führt kind nicht aus; [.github/workflows/kind.yml](../../.github/workflows/kind.yml)
ist ein separater manueller Check.

## Aufräumen

Beende Port-Forwarding. Lösche nur das eigens angelegte Lerncluster:

```bash
kind delete cluster --name docker-learning
rm -f reports/kind.kubeconfig
docker image rm task-api:kind
```

Quellen: [kind Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/),
[Kubernetes-Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/).
