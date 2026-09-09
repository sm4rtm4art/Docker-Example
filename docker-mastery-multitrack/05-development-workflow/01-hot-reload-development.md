# Änderungen: Reload, Neustart oder Build?

## Lernziele

Du wählst die passende Rückkopplung für Quellcode, Abhängigkeiten und Imageänderungen.

## Voraussetzung

Beende das Root-Labor im Repository-Wurzelverzeichnis mit `python3 scripts/cleanup.py api`.
Wechsle danach in den Ordner deines Tracks.

## Übung

### Python

Arbeitsordner: `docker-mastery-multitrack/02-language-quickstart/python`.

```bash
docker compose -f compose.dev.yml up --build
```

Ändere den Text der Root-Antwort in `src/main.py`. Uvicorn lädt die Anwendung neu; prüfe dies in
einem zweiten Terminal mit `curl --fail http://127.0.0.1:8080/`. Der Source-Mount ist im Container
schreibgeschützt, dein Editor bearbeitet die Datei auf dem Host. Ein Reload verliert In-Memory-Aufgaben.
Bei geänderten Abhängigkeiten aktualisiere das Lockfile und baue das Entwicklungsimage erneut.

### Rust

Arbeitsordner: `docker-mastery-multitrack/02-language-quickstart/rust`.

```bash
docker compose -f compose.dev.yml up --build -d
docker compose -f compose.dev.yml logs -f task-api
```

Ändere die Root-Antwort in `src/main.rs`, beende die Logansicht mit Ctrl+C und führe aus:

```bash
docker compose -f compose.dev.yml restart task-api
```

`cargo run --locked` kompiliert beim Start; die erste Kompilierung kann mehrere Minuten benötigen.
Es ist kein automatischer Watcher installiert. Der Target-Cache liegt in diesem Entwicklungscontainer
und geht bei dessen Entfernung verloren. Manifeste und Lockfile werden ins Image kopiert; nach deren
Änderung ist ein neuer Build erforderlich.

### Java

Arbeitsordner: `docker-mastery-multitrack/02-language-quickstart/java`.

```bash
docker compose up --build --wait
```

Nach einer Änderung von `HomeController.java` denselben Befehl wiederholen. Java nutzt im Kurs
den vollständigen Image-Build als einfach nachvollziehbaren Workflow. Eine DevTools-/IDE-Hotreload-
Integration ist eine mögliche Vertiefung, nicht Bestandteil dieses Beispiels.

## Erfolgskontrolle

| Änderung | Erforderlicher Schritt |
| --- | --- |
| Python-Source im Dev-Mount | Automatischer Reload |
| Rust-Source im Dev-Mount | Entwicklungscontainer neu starten |
| Java-Source / Runtime-Image | Neu bauen und Container neu erstellen |
| Manifest, Lockfile oder Dockerfile | Neu bauen und neu erstellen |

## Aufräumen

Im jeweiligen Trackordner: Python/Rust mit `docker compose -f compose.dev.yml down`,
Java mit `docker compose down`. Setze nur deine eigenen Übungsänderungen zurück.

Quelle: [Bind Mounts](https://docs.docker.com/engine/storage/bind-mounts/).
