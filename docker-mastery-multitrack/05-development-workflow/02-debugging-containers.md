# Container systematisch debuggen

## Lernziele

Du formulierst eine prüfbare Hypothese und grenzt Build-, Start-, Netzwerk- und Anwendungsfehler ein.

## Voraussetzung

Repository-Wurzelverzeichnis; ein ausgewählter Track in `TASK_TRACK`.

## Übung

```bash
docker compose -p docker-learning -f compose.lab.yml up --build --wait
docker compose -p docker-learning -f compose.lab.yml ps
docker compose -p docker-learning -f compose.lab.yml logs --tail 100 task-api
docker compose -p docker-learning -f compose.lab.yml config
curl -i http://127.0.0.1:8080/health
```

Arbeite vom beobachteten Fehler zur nächstkleineren Frage:

| Beobachtung | Nächste Prüfung | Mögliche Ursache |
| --- | --- | --- |
| Build scheitert bei COPY | Kontext und `.dockerignore` | Benötigte Datei ausgeschlossen |
| Container beendet sich sofort | Exitcode und Logs | Falsches Startprogramm oder fehlende Bibliothek |
| Hostverbindung abgelehnt | `ps`, Ports, aktiver Docker-Kontext | Keine Freigabe, falscher Port oder Dienst beendet |
| HTTP 404 | Angefragten Pfad mit Vertrag vergleichen | HTTP-Server läuft; Route stimmt nicht |
| Health `unhealthy` | Healthcheck-Logs und Startdauer | Prüfbefehl fehlt, Pfad falsch oder Anwendung unbereit |
| Schreiben scheitert | Mountmodus, UID und Dateirechte | Gewollter Schreibschutz oder falscher Eigentümer |

### Ein kontrollierter Fehler

Rufe `/api/does-not-exist` auf. Erwarte HTTP 404 und erkläre, warum du jetzt weder Firewall noch
Docker-Neuinstallation untersuchen musst. Prüfe anschließend `/health` und stelle die Verbindung
zwischen Netzwerkfunktion und Anwendungsroute her.

Untersuche den echten Healthcheck und Benutzer:

```bash
container_id=$(docker compose -p docker-learning -f compose.lab.yml ps -q task-api)
docker inspect "$container_id" --format '{{json .State.Health}}'
docker compose -p docker-learning -f compose.lab.yml exec task-api id
```

`docker exec` benötigt ein im Image vorhandenes Programm. Ein fehlendes `bash` bedeutet nicht,
dass der Container defekt ist. In minimalen Images kann auch `sh` fehlen; nutze dann Logs,
Inspect oder eine geeignete externe Diagnoseumgebung.

## Erfolgskontrolle

Beschreibe einen Fehler mit Symptom, Hypothese, genau einem entscheidenden Test und Ergebnis.
Vermeide als erste Maßnahme globale Prune-Befehle: Sie zerstören Belege und können fremde Daten treffen.

## Aufräumen

```bash
python3 scripts/cleanup.py api
```
