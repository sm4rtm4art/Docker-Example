# Python-Track: FastAPI und uv

## Lernziele

Du baust das Image, erklärst die Rolle der Build-Werkzeuge und prüfst den gemeinsamen Task-API-Vertrag.
Richtwert: 60–90 Minuten als Teil von Modul 02.

## Voraussetzung

Module 00–01. Docker, Compose und Python für die Prüfscripte sind auf dem Host vorhanden.
Die sprachspezifischen Werkzeuge laufen beim Containerbuild im Image.

## Übung

Alle Befehle starten im Repository-Wurzelverzeichnis:

```bash
export TASK_TRACK=python
docker compose -p docker-learning -f compose.lab.yml config
docker compose -p docker-learning -f compose.lab.yml up --build --wait
curl --fail http://127.0.0.1:8080/health
python3 scripts/api_contract.py --report reports/python-api.json
```

Erwartet werden HTTP 200 mit `storage: memory` und sieben erfolgreiche Vertragstests.
Der erste Build benötigt Registry- und Paketdownloads. Bei einem Fehler:

```bash
docker compose -p docker-learning -f compose.lab.yml ps
docker compose -p docker-learning -f compose.lab.yml logs --tail 100 task-api
```

Lege anschließend selbst eine Aufgabe an:

```bash
curl --fail -X POST http://127.0.0.1:8080/api/tasks -H 'Content-Type: application/json' -d '{"title":"Docker verstehen"}'
curl --fail http://127.0.0.1:8080/api/tasks
curl --fail http://127.0.0.1:8080/metrics
```

Kopiere die zurückgegebene ID und probiere GET, PUT und DELETE gemäß
[API-Vertrag](../../../TASK_API_SPECIFICATION.md). Ersetze bei PUT alle bearbeitbaren Felder.
Nach einem Neustart ist die Aufgabenliste leer; das ist die implementierte Speichervariante.

### Was am Track wichtig ist

Python-Abhängigkeiten stehen in `pyproject.toml`, ihre Auflösung in `uv.lock`.
Der Build verwendet `uv sync --locked` und bricht bei einer inkonsistenten Sperrdatei ab.
Die Runtime erhält nur das Virtualenv und `src/`; uv selbst bleibt in der Build-Stufe.
`requirements.txt` ist ein generierter Export und wird nicht separat gepflegt.
Der Healthcheck verwendet die Python-Standardbibliothek; curl muss dafür nicht ins Image.
Zusätzlich ist unter `http://127.0.0.1:8080/docs` eine interaktive API-Dokumentation verfügbar.

### Zweiter Einstiegspunkt

Die tracklokale `docker-compose.yml` verwendet denselben Runtime-Dockerfile. Wenn du sie ausprobieren
möchtest, beende zuerst das Root-Labor und starte dann aus diesem Trackordner `docker compose up --build --wait`.
Räume dieses lokale Projekt dort mit `docker compose down` auf. Vermische die Projektnamen nicht.

## Erfolgskontrolle

Erkläre, woher Quellcode und Abhängigkeiten ins Image gelangen, warum die API auf `0.0.0.0`
lauscht und warum der Host nur `127.0.0.1:8080` freigibt. Zeige einen erfolgreichen CRUD-Test.

## Aufräumen und weiter

Im Repository-Wurzelverzeichnis:

```bash
python3 scripts/cleanup.py api
```

[Weiter: Dockerfile-Grundlagen](../../03-dockerfile-essentials/shared-concepts/01-dockerfile-fundamentals.md)
