# Ressourcenlimits messen und begründen

## Lernziele

Du liest die wirksamen Grenzen eines Containers und unterscheidest CPU-Drosselung, Speicherverbrauch
und Prozessanzahl.

## Voraussetzung

Laufendes Root-API-Labor. Die Werte im Beispiel sind Startpunkte für die Übung, keine Sizing-Empfehlung.

## Übung

```bash
docker compose -p docker-learning -f compose.lab.yml up --build --wait
container_id=$(docker compose -p docker-learning -f compose.lab.yml ps -q task-api)
docker stats --no-stream "$container_id"
docker inspect "$container_id" --format '{{.HostConfig.Memory}} {{.HostConfig.NanoCpus}} {{.HostConfig.PidsLimit}}'
```

Das Beispiel setzt 512 MiB Speicher, eine CPU als rechnerische Obergrenze und 256 PIDs.
CPU-Grenzen bedeuten nicht, dass ein bestimmter physischer Kern exklusiv zugeordnet ist.
Speicherüberlastung kann einen OOM-Kill verursachen. Prüfe dann `State.OOMKilled`; Exitcode 137
allein belegt die Ursache nicht, weil auch ein anderes SIGKILL diesen Code ergeben kann.

Reduziere das Speicherlimit nur in deiner Übungskopie schrittweise, erstelle den Container neu und
beobachte Start und Logs. `docker compose restart` übernimmt keine geänderte Containerkonfiguration.
Stelle den ursprünglichen Wert anschließend wieder her. Belastungstests gehören auf eine eigene
lokale Umgebung, nicht auf gemeinsam verwendete Systeme.

Bei Java zählen Heap und nativer Speicher zusammen. Bei allen Tracks belegen Prozesse und Threads
Ressourcen; mehr Worker lösen nicht automatisch ein Lastproblem. Die In-Memory-API würde zusätzlich
getrennte Datenbestände bekommen.

## Erfolgskontrolle

Du kannst eine konfigurierte Grenze im Inspect-Ergebnis wiederfinden und eine Abweichung zwischen
beobachtetem Verbrauch und zugelassenem Maximum erklären. Vergleiche keine Sprachperformance ohne
gleiche Last, Hostbedingungen und Messmethode.

## Aufräumen

```bash
python3 scripts/cleanup.py api
```

Quelle: [Ressourcen begrenzen](https://docs.docker.com/engine/containers/resource_constraints/).
