# Volumes: Persistenz nachvollziehbar prüfen

## Lernziele

Du unterscheidest Prozessspeicher, beschreibbare Containerschicht, Bind Mount und Named Volume.

## Voraussetzung

Die beiden vorigen Lektionen. Verwende nur die Daten des lokalen Kurslabors.

## Konzept

| Speicherort | Container-Neustart | Container entfernen / neu erstellen |
| --- | --- | --- |
| Prozessspeicher der Task API | Verloren | Verloren |
| Beschreibbare Containerschicht | Bleibt gewöhnlich erhalten | Verloren |
| Named Volume | Bleibt erhalten | Bleibt erhalten, solange das Volume nicht gelöscht wird |
| Bind Mount | Daten liegen auf dem Hostpfad | Hostdateien bleiben bestehen |
| tmpfs | Flüchtig; beim Stoppen verloren | Verloren |

Ein Volume ist kein Backup. Es schützt weder vor versehentlichen SQL-Löschungen noch vor einem
Hostausfall. Bei Bind Mounts gelten reale Dateirechte; auch Named Volumes können falsche Eigentümer haben.
Ein Mount über ein vorhandenes Verzeichnis kann dessen Imageinhalt verdecken.

## Übung

```bash
export DB_COMPOSE=docker-mastery-multitrack/common-resources/templates/docker-compose.database.yml
docker compose -p docker-learning-db -f "$DB_COMPOSE" up -d --wait postgres
docker compose -p docker-learning-db -f "$DB_COMPOSE" run --rm client -c "CREATE TABLE IF NOT EXISTS progress (id integer PRIMARY KEY, lesson text NOT NULL); INSERT INTO progress VALUES (1, 'volumes') ON CONFLICT (id) DO UPDATE SET lesson=EXCLUDED.lesson;"
docker compose -p docker-learning-db -f "$DB_COMPOSE" down
docker compose -p docker-learning-db -f "$DB_COMPOSE" up -d --wait postgres
docker compose -p docker-learning-db -f "$DB_COMPOSE" run --rm client -c 'SELECT * FROM progress;'
```

Die Zeile `1 | volumes` bleibt erhalten. Vergleiche das mit einer Aufgabe in der Task API nach
deren Prozessneustart. Das Volume macht nur die Dateien persistent, die die Anwendung tatsächlich hineinschreibt.

### Backup als zusätzliche Übung

Während die Datenbank läuft, im Repository-Wurzelverzeichnis:

```bash
mkdir -p reports
docker compose -p docker-learning-db -f "$DB_COMPOSE" exec -T postgres pg_dump -U learner -d learning > reports/learning.sql
```

Ein Backup ist erst belastbar, wenn ein Restore in eine getrennte Testdatenbank erfolgreich geprüft
wurde. Kopiere nicht ungeprüft ein laufendes PostgreSQL-Datenverzeichnis als „konsistentes Backup“.
Der Kurs fixiert PostgreSQL 17 und dessen Datenpfad; beim Major-Upgrade müssen Image-Dokumentation,
Datenpfad und Migrationsweg erneut geprüft werden.

## Erfolgskontrolle

Führe `python3 scripts/validate.py database` aus. Dieser Test erstellt isolierte Daten, entfernt
den Container ohne Volumelöschung, startet neu und prüft den erhaltenen Datensatz.
Erkläre anschließend, warum ein einfacher `docker restart` allein diesen Nachweis nicht erbringt.

## Aufräumen

Daten behalten: `python3 scripts/cleanup.py database`.
Nur wenn du die Übungsdaten bewusst löschen möchtest:

```bash
python3 scripts/cleanup.py database --delete-data
```

Quellen: [Docker Volumes](https://docs.docker.com/engine/storage/volumes/),
[PostgreSQL pg_dump](https://www.postgresql.org/docs/17/app-pgdump.html).
