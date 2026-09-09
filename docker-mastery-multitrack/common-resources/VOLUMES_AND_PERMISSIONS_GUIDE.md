# Volumes und Dateirechte

Ein Mount und eine Schreibberechtigung sind unterschiedliche Dinge. Prüfe zuerst, ob der erwartete
Pfad überhaupt gemountet wird, danach Mountmodus und Benutzerkennung.

## Diagnose

Bei laufendem Root-API-Labor, Repository-Wurzelverzeichnis:

```bash
container_id=$(docker compose -p docker-learning -f compose.lab.yml ps -q task-api)
docker inspect "$container_id" --format '{{json .Mounts}}'
docker compose -p docker-learning -f compose.lab.yml exec task-api id
docker compose -p docker-learning -f compose.lab.yml exec task-api ls -ld /app /tmp
```

Der Kurs verwendet UID/GID 10001 im Runtime-Image. `/app` ist root-eigen und mit schreibgeschütztem
Rootdateisystem geschützt; `/tmp` ist ein beschreibbares tmpfs. In den Entwicklungsdateien ist
`src/` ein schreibgeschützter Bind Mount: Nur der Hosteditor soll den Quellcode verändern.

## Typische Ursachen

- Ein Named Volume kann Daten mit einem früheren Eigentümer enthalten.
- Ein Bind Mount verwendet Hostdateien und deren effektive Rechte. Docker Desktop und Rootless-
  Konfigurationen können UID-Abbildungen anders behandeln als ein nativer Linux-Daemon.
- Ein Mount verdeckt vorhandene Dateien am Zielpfad. Ein unpassender Mount auf `/app` kann das
  Virtualenv, das JAR oder die ausführbare Datei verdecken.
- Eine Änderung von Build-ARGs ändert keine bereits vorhandenen Volumedateien.

Verwende kein pauschales `chmod 777`, keinen globalen Benutzerwechsel zu root und keine globale
Volumelöschung als erste Reparatur. Korrigiere den konkreten Eigentümer oder Mountpfad in einer
kontrollierten Übungskopie. Für echte Daten zuerst einen verifizierten Sicherungsweg vorsehen.

[Persistenzübung](../04-docker-compose/03-compose-volumes.md),
[Docker Bind Mounts](https://docs.docker.com/engine/storage/bind-mounts/).
