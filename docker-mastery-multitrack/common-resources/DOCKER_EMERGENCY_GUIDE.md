# Fehlersuche ohne globale Bereinigung

Starte mit dem konkreten Symptom. Bewahre Logs und Fehlermeldungen, bevor du Ressourcen entfernst.
Alle Befehle beziehen sich auf das Root-API-Labor im Repository-Wurzelverzeichnis.

```bash
docker context show
docker version
docker compose -p docker-learning -f compose.lab.yml ps
docker compose -p docker-learning -f compose.lab.yml logs --tail 100 task-api
```

| Symptom | Gezielte Prüfung |
| --- | --- |
| Cannot connect to daemon | Docker starten, aktiven Kontext und Rechte prüfen |
| COPY failed | Build-Kontext und `.dockerignore` mit echtem Pfad abgleichen |
| Port already allocated | Konfliktport identifizieren; für das Labor `TASK_API_PORT` ändern |
| Container beendet sich | Logs und Exitcode lesen; Startprogramm prüfen |
| Healthcheck schlägt fehl | Route, vorhandenes Prüfprogramm und Startfrist prüfen |
| Permission denied | Benutzer, Mountmodus und Eigentümer prüfen; kein pauschales `chmod 777` |
| Daten nach Neustart weg | Prozessspeicher mit Volume-Dateien unterscheiden |
| Grafana-Login passt nicht | Initialpasswort gilt für neue Datenbank; vorhandene Grafana-Daten beachten |

Portwechsel in Bash, Repository-Wurzelverzeichnis:

```bash
export TASK_API_PORT=8082
docker compose -p docker-learning -f compose.lab.yml up --build --wait
python3 scripts/api_contract.py --base-url http://127.0.0.1:8082
```

Prüfe davor mit `docker ps`, ob ein anderer Dienst den ursprünglichen Port belegt.
Stoppe keine fremden Container, um Platz zu schaffen. Bei Speicherknappheit hilft zunächst
`docker system df` als reine Bestandsaufnahme.

[Cleanup-Anleitung](../../scripts/scripts-utilities-guide.md) und
[ausführliche Diagnoseübung](../05-development-workflow/02-debugging-containers.md).
