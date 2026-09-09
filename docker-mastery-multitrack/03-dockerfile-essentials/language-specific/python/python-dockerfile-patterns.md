# Dockerfile-Muster für Python

## Lernziele

Du begründest die Besonderheiten deines Tracks, ohne ein zweites, abweichendes Dockerfile aus der
Dokumentation zu kopieren.

## Voraussetzung

Die beiden gemeinsamen Lektionen in Modul 03. Referenz ist der
[ausführbare Dockerfile](../../../02-language-quickstart/python/Dockerfile).

## Übung

Prüfe zuerst `pyproject.toml` und `uv.lock`. Ein leeres oder manuell skizziertes Lockfile ist
kein Lockfile. `uv sync --locked` muss aus einem frischen Checkout funktionieren.
Die virtuelle Umgebung wird immer am Pfad `/app/.venv` aufgebaut und verwendet; der Pythonpfad
bleibt zwischen Builder und Runtime kompatibel.

Im Runtime-Image laufen keine Paketinstallationen. Der Code gehört root und wird von UID 10001
nur gelesen. Ein zusätzlicher Worker würde einen getrennten Aufgabenbestand halten; erhöhe die
Workerzahl deshalb erst nach Einführung einer gemeinsamen Speicherlösung.

Für lokale Pflege: `uv lock`, danach `uv sync --locked` und den HTTP-Vertrag prüfen.
`requirements.txt` wird mit `uv export --locked --no-dev --no-emit-project --output-file requirements.txt`
im Python-Trackordner erzeugt. Ändere diese Datei nicht unabhängig vom Lockfile.

Führe aus dem Repository-Wurzelverzeichnis den vollständigen Trackcheck aus:

```bash
python3 scripts/validate.py track --track python
```

Er startet ein eigenes Compose-Projekt, prüft den HTTP-Vertrag und die Laufzeitkonfiguration und
räumt nur dieses Testprojekt auf. Dockerzugriff ist erforderlich.

## Erfolgskontrolle

Du erklärst, welche Abhängigkeiten nur zum Bauen benötigt werden und welche beim Start vorhanden
sein müssen. Du kannst einen Buildfehler von einem Fehler beim Containerstart unterscheiden.

[Zurück zur Modulübersicht](../../shared-concepts/dockerfile-essentials-overview.md)
