# Einen vollständigen Monitoring-Stack betreiben

## Lernziele

Du startest API, Prometheus und Grafana mit bereitgestellten Konfigurationen und prüfst den Datenweg.

## Voraussetzung

Modul 08 Grundlagen. Alle Befehle in Bash im Repository-Wurzelverzeichnis.
Beende vorher andere Kursinstanzen auf 8080, 9090 oder 3000. Die Zugangsdaten gelten nur lokal.

## Übung

```bash
python3 scripts/cleanup.py api
export TASK_TRACK=python
export GRAFANA_ADMIN_PASSWORD='local-monitoring-exercise-only'
docker compose -p docker-learning-monitoring -f compose.lab.yml -f compose.monitoring.yml config --quiet
docker compose -p docker-learning-monitoring -f compose.lab.yml -f compose.monitoring.yml up --build --wait
```

Wähle stattdessen `rust` oder `java`, wenn das dein Track ist. Das Passwort ist ein **DEV-ONLY**-
Beispiel; verwende keinen vorhandenen persönlichen Zugang. Bei Grafana wird der Initialzugang beim
ersten Anlegen der Datenbank eingerichtet. Eine spätere Änderung der Umgebungsvariable setzt ein
bereits gespeichertes Passwort nicht automatisch zurück.

Öffne nach dem Start:

| Adresse | Prüfung |
| --- | --- |
| `http://127.0.0.1:8080/health` | API antwortet mit `storage: memory` |
| `http://127.0.0.1:9090/targets` | Target `task-api` ist UP |
| `http://127.0.0.1:3000` | Anmeldung als `learner` mit dem gewählten Laborpasswort |

In Grafana ist die Datenquelle Prometheus voreingestellt. Öffne das Dashboard **Docker Task API**.
Lege eine Aufgabe über die API an und warte mindestens einen Scrape-Zyklus (fünf Sekunden) sowie
den Dashboard-Refresh. Die Panels zeigen Bestände, keine erfundenen Durchsatzwerte.
`up --wait` kennt hier nur für die API einen Healthcheck; Targets und Grafana sind separat zu prüfen.

### Den Datenweg nachvollziehen

Prometheus erreicht `task-api:8080` im Compose-Netzwerk, Grafana erreicht `prometheus:9090`.
Dein Browser verwendet dagegen veröffentlichte Hostports. Die Konfigurationsdateien sind
schreibgeschützt eingebunden; Prometheus und Grafana schreiben ihre Daten in eigene Named Volumes.

```bash
docker compose -p docker-learning-monitoring -f compose.lab.yml -f compose.monitoring.yml stop task-api
```

Beobachte in Prometheus, wie `up` nach dem nächsten erfolglosen Scrape auf 0 wechselt.
Alte Messwerte können in historischen Diagrammen weiterhin sichtbar bleiben. Starte die API wieder:

```bash
docker compose -p docker-learning-monitoring -f compose.lab.yml -f compose.monitoring.yml start task-api
```

Der Aufgabenbestand ist leer. Die Prometheus-Historie bleibt im eigenen Volume erhalten.

## Erfolgskontrolle

```bash
python3 scripts/validate.py monitoring --track python
```

Der Check startet ein isoliertes Projekt auf freien lokalen Ports, prüft den API-Vertrag, einen
Prometheus-Scrape und die Grafana-Health-Antwort. Er prüft keine Screenshots, Alerts oder realen
Betriebs-SLOs. Lies zusätzlich das eingecheckte Dashboard und die Datenquellenkonfiguration.

## Aufräumen

```bash
python3 scripts/cleanup.py monitoring
```

Zum bewussten Löschen der Messhistorie und Grafana-Daten:
`python3 scripts/cleanup.py monitoring --delete-data`.

Quellen: [Prometheus-Konfiguration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/),
[Grafana-Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/).
