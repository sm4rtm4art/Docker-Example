# 11 – Docker, Podman und containerd einordnen

## Lernziele

Du unterscheidest Imageformat, Runtime, Entwicklungswerkzeug und Orchestrierung.
Richtwert: 30–45 Minuten.

## Voraussetzung

Der Kernpfad ist abgeschlossen. Für den begrifflichen Vergleich ist keine weitere Installation nötig.

## Konzept

| Werkzeug / Standard | Rolle | Nicht automatisch gleichbedeutend mit |
| --- | --- | --- |
| OCI | Standards für Images und Runtime | Einer vollständigen Entwickleroberfläche |
| Docker Engine | Containerverwaltung mit API und Daemon | Docker Desktop oder Kubernetes |
| Docker Compose | Deklarative Mehrcontainer-Anwendungen | Einem Cluster-Scheduler |
| Podman | Containerverwaltung, auch rootless nutzbar | Vollständiger Compose-Kompatibilität jeder Konfiguration |
| containerd | Runtime-Dienst für Containerlebenszyklen | Einem kompletten Docker-Desktop-Ersatz |
| Kubernetes | Deklarative Orchestrierung über Knoten | Einem Werkzeug zum Schreiben und Bauen von Dockerfiles |

Docker und Kubernetes können OCI-kompatible Images verwenden. Kubernetes benötigt nicht den
Docker-Engine-Daemon als Node-Runtime; die Anbindung erfolgt über CRI-kompatible Runtimes.
Docker bleibt trotzdem als lokales Buildwerkzeug für ein Kubernetes-Projekt nutzbar.

## Übung

Ordne die Dateien des Kurses zu: Dockerfile, Compose-Datei, Image, Kubernetes-Deployment, Service
und Python-HTTP-Test. Welche könnten bei einem Wechsel zu Podman unverändert bleiben? Welche
müsstest du tatsächlich erneut prüfen?

Optional, in einer eigenen Umgebung mit bereits installiertem Podman: Baue einen Track mit
`podman build` und prüfe das gestartete Image mit demselben HTTP-Vertrag. Vergleiche UID-Mapping,
Dateirechte, lokale Portfreigabe und Netzwerkverhalten. Unter macOS/Windows benötigt auch diese
Linux-Containerlösung eine geeignete VM-Umgebung. Eine identische CLI-Schreibweise beweist keine
vollständige Verhaltensgleichheit.

## Erfolgskontrolle

Begründe eine Werkzeugwahl für ein lokales Entwicklerprojekt und eine für einen mehrknotigen Betrieb.
Benutze dabei konkrete Anforderungen statt pauschaler Aussagen wie „daemonlos ist immer sicherer“.
Ein nicht ausgeführter Podman-Versuch darf nicht als bestätigte Portierung dokumentiert werden.

## Weiterführend

[Erweiterungsvorschläge](../../TASKLIST.md): persistente API, Restore-Tests, Image-Scans und
Multiarch-Builds. Vertiefe zuerst den Bedarf, den du bereits erklären und prüfen kannst.

Quellen: [OCI](https://opencontainers.org/), [Podman-Dokumentation](https://docs.podman.io/),
[Kubernetes-Runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/).
