# Task API: verbindlicher Vertrag

Dieser Vertrag beschreibt die **implementierte In-Memory-API** aller drei Tracks.
Sie lauscht im Container auf `0.0.0.0:8080`. Hostports werden separat veröffentlicht.
Es gibt keine Datenbankanbindung, Authentifizierung oder Zusage für mehrere Replikate.

## Endpunkte

| Methode | Pfad | Erfolg | Inhalt |
| --- | --- | --- | --- |
| GET | `/` | 200 | Navigation und Trackname |
| GET | `/health` | 200 | `status: healthy`, `version: 1.0.0`, `storage: memory` |
| GET | `/api/tasks` | 200 | Objekt mit `tasks` als Liste und `total` als Anzahl |
| POST | `/api/tasks` | 201 | Neu erzeugte Aufgabe |
| GET | `/api/tasks/{id}` | 200 | Einzelne Aufgabe |
| PUT | `/api/tasks/{id}` | 200 | Vollständiger Ersatz der bearbeitbaren Felder |
| DELETE | `/api/tasks/{id}` | 204 | Leerer Antwortkörper |
| GET | `/metrics` | 200 | Prometheus-Textformat, Version 0.0.4 |

## Datenmodell

Eine Aufgabe enthält `id` als UUID-String, `title`, `description`, `completed` als Boolean sowie
`created_at` und `updated_at` als ISO-8601-Zeitstempel mit UTC-Bezug. Die Reihenfolge der Aufgaben
ist nicht definiert. IDs und Zeitstempel werden vom Server erzeugt.

Beispiel einer POST-Anfrage:

```json
{"title":"Docker lernen","description":"Build-Kontext verstehen"}
```

`title` ist erforderlich, darf nicht leer oder ausschließlich aus Leerraum bestehen und hat
höchstens 255 Zeichen. `description` ist optional (Standard: leerer String), maximal 2000 Zeichen.
Neue Aufgaben sind nicht abgeschlossen. Eine PUT-Anfrage benötigt `title` und `completed`;
fehlende `description` wird zum leeren String. PUT ist hier bewusst **kein partielles Update**.

```json
{"title":"Docker anwenden","description":"Übung abgeschlossen","completed":true}
```

Beim Ersetzen bleiben `id` und `created_at` erhalten; `updated_at` wird neu gesetzt. Ein Neustart
leert den gesamten Speicher. Mehrere Prozesse oder Container führen getrennte Aufgabenbestände.

## Fehler und Framework-Unterschiede

Unbekannte IDs liefern bei GET, PUT und DELETE den Status 404. Ungültige Eingaben liefern 400
oder 422; Fehlerkörper sind frameworkabhängig. Der Kurs testet die genannten Pflichtfelder,
Längengrenzen und Zustandsübergänge. Frameworkdetails wie Typkonvertierung, Unicode-Längenzählung,
Null-Behandlung und jede mögliche fehlerhafte JSON-Form sind kein vollständig vereinheitlichter Vertrag.

Python stellt zusätzlich `/docs` und `/redoc` bereit. Java verwendet für den gemeinsamen Healthcheck
`/health`; Actuator ist für diese kleine Anwendung nicht erforderlich.

## Metriken

Die Antwort ist Text mit `Content-Type: text/plain; version=0.0.4`, kein JSON-String.

```text
# TYPE task_count gauge
task_count 2
# TYPE task_completed_count gauge
task_completed_count 1
# TYPE task_pending_count gauge
task_pending_count 1
```

Alle drei Werte sind **Gauges**, weil sie sinken können. Es gilt
`task_count = task_completed_count + task_pending_count`. HTTP-Zähler und Latenzhistogramme
sind nicht implementiert. Prometheus erzeugt `up` selbst aus dem Scrape-Ergebnis.

## Automatische Vertragsprüfung

Bei laufender API, aus dem Repository-Wurzelverzeichnis:

```bash
python3 scripts/api_contract.py --base-url http://127.0.0.1:8080 --report reports/api.json
```

Die Tests erzeugen eigene Aufgaben und entfernen sie danach. Nutze eine ruhige lokale Instanz;
parallele Änderungen durch andere Clients können Anzahlprüfungen beeinflussen.
Die CI startet dafür isolierte Compose-Projekte. Gegen eine echte Produktiv-API sollen diese Tests
nicht ausgeführt werden.

## Erweiterungen

Eine persistente Variante benötigt einen implementierten Repository-/Datenbankzugriff,
Migrationen, Verbindungsfehlerbehandlung und separate Readiness. Die Erweiterung muss denselben
Vertrag erfüllen und zusätzlich einen API-Neustart mit erhaltenen Aufgaben testen.
Sie ist in [TASKLIST.md](TASKLIST.md) spezifiziert, nicht als vorhandene Funktion ausgegeben.
