# Healthchecks und geordnetes Beenden

## Lernziele

Du unterscheidest Prozessstart, erfolgreiche HTTP-Prüfung und fachliche Bereitschaft.

## Voraussetzung

Repository-Wurzelverzeichnis, ausgewählter `TASK_TRACK`.

## Konzept

Ein Docker-Healthcheck führt einen Befehl **im Container** aus. Er benötigt ein vorhandenes Programm
und eine passende Route. Status `unhealthy` allein startet einen Standalone-Container nicht neu.
Eine Restart-Policy reagiert auf Prozessbeendigung; sie ist kein allgemeiner Health-Reparaturdienst.

`/health` prüft in diesem Kurs die Erreichbarkeit des API-Prozesses. Eine Datenbank wird nicht geprüft,
weil keine angebunden ist. Mit echten Abhängigkeiten sollten Liveness und Readiness getrennt werden:
Ein Datenbankausfall soll nicht zwangsläufig alle API-Prozesse in Neustartschleifen versetzen.

Beim Stoppen sendet Docker üblicherweise SIGTERM und nach Ablauf der Frist SIGKILL. Exec-Form startet
das eigentliche Programm ohne zusätzliche Shell. Java und Rust erhalten explizite Shutdownfristen;
Uvicorn behandelt das Stop-Signal ebenfalls. Die Compose-Frist beträgt 30 Sekunden.

## Übung

```bash
docker compose -p docker-learning -f compose.lab.yml up --build --wait
container_id=$(docker compose -p docker-learning -f compose.lab.yml ps -q task-api)
docker inspect "$container_id" --format '{{json .State.Health}}'
docker compose -p docker-learning -f compose.lab.yml stop task-api
docker inspect "$container_id" --format '{{json .State}}'
docker compose -p docker-learning -f compose.lab.yml logs --tail 50 task-api
```

Prüfe Exitcode, OOMKilled und Logs. Der automatische Test akzeptiert 0 oder 143 (SIGTERM),
aber nicht 137 (SIGKILL). Das ist ein grundlegender Stop-Nachweis, kein Test laufender Langzeitanfragen.
Eine spätere Erweiterung sollte eine echte laufende Anfrage beim Stoppen beobachten.

## Erfolgskontrolle

Erkläre, warum „HTTP 200“, „Container running“ und „alle Geschäftsabhängigkeiten bereit“ drei
unterschiedliche Aussagen sind. Beschreibe, was bei Überschreitung der Stop-Frist geschieht.

## Aufräumen

```bash
python3 scripts/cleanup.py api
```

Quellen: [HEALTHCHECK](https://docs.docker.com/reference/dockerfile/#healthcheck),
[Container stoppen](https://docs.docker.com/reference/cli/docker/container/stop/).
