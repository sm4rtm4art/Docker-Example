# Docker-Lernpfad: von der ersten API bis zum lokalen Kubernetes-Cluster

Ein praktischer Lernpfad für Entwicklerinnen und Entwickler mit Grundkenntnissen in
Python, Rust oder Java. Im Mittelpunkt stehen Container, Images, Netzwerke, Daten und
Betriebsverhalten. Die Frameworks dienen als Beispiele; ein Sprachtrack genügt.

## Einstieg

1. [Arbeitsumgebung vorbereiten](docker-mastery-multitrack/00-prerequisites/prerequisites-overview.md).
2. [Lernpfad und Module ansehen](docker-mastery-multitrack/docker-curriculum-guide.md).
3. [Python, Rust oder Java auswählen](docker-mastery-multitrack/02-language-quickstart/quickstart-overview.md).

Die Module 00–07 bilden den Kern, 08–11 den Aufbau. Plane ungefähr 12–18 Stunden
für einen Track einschließlich Übungen ein; Fehlersuche und Wiederholung können mehr Zeit benötigen.

## Was tatsächlich enthalten ist

| Baustein | Ausführbarer Inhalt | Bewusste Grenze |
| --- | --- | --- |
| Python / Rust / Java | Derselbe Task-API-Vertrag, Dockerfiles, lokale Compose-Konfiguration | Aufgaben liegen im Arbeitsspeicher; Neustarts verlieren Daten |
| PostgreSQL-Labor | Zwei Services, DNS, Healthcheck, Named Volume, Persistenztest | Eigenständige Datenübung; die Task API ist nicht an PostgreSQL angebunden |
| Monitoring | Prometheus, Grafana, bereitgestelltes Dashboard | Aktuelle Aufgabenbestände und Scrape-Status; keine erfundenen Latenzmetriken |
| CI | Syntax, interne Links, Builds, HTTP-Vertrag, Laufzeitrechte, Persistenz | Prüft technische Ergebnisse, nicht automatisch dein Verständnis |
| kind | Lokales Deployment mit Service und Probes | Optionales Lerncluster; keine hochverfügbare Produktionsumgebung |

Die Anwendungen besitzen keine Authentifizierung und sind ausschließlich für lokale Lernübungen
vorgesehen. Ports werden an `127.0.0.1` gebunden. Image-Härtung und Betriebsübungen ersetzen
keine Prüfung einer konkreten Produktionsumgebung.

## Einen Track ausprobieren

Nach Modul 00, im Repository-Wurzelverzeichnis, in Bash / WSL:

```bash
git clone https://github.com/sm4rtm4art/Docker-Example.git
cd Docker-Example
export TASK_TRACK=python
docker compose -p docker-learning -f compose.lab.yml up --build --wait
curl --fail http://127.0.0.1:8080/health
python3 scripts/api_contract.py
```

`TASK_TRACK` akzeptiert `python`, `rust` oder `java`. Erwarteter Health-Inhalt:
`status: healthy`, `storage: memory`. Der API-Test legt eigene Aufgaben an und entfernt sie wieder.
Windows-Anweisungen und Voraussetzungen stehen in [Modul 00](docker-mastery-multitrack/00-prerequisites/prerequisites-overview.md).

Aufräumen nach dieser Übung:

```bash
python3 scripts/cleanup.py api
```

## Dokumentation und Qualität

- [Lernziele und Bewertung](LEARNING_OBJECTIVES.md)
- [Verbindlicher API-Vertrag](TASK_API_SPECIFICATION.md)
- [Lokale Validierung und Pflege](DEVELOPMENT_SETUP.md)
- [Fachliche Referenzen](SOURCES.md)
- [Überarbeitungsbefunde und verbleibende Grenzen](REVIEW_NOTES.md)
- [Erweiterungsvorschläge](TASKLIST.md)

Der Workflow [Validate curriculum](.github/workflows/validate.yml) läuft für Pull Requests und
Änderungen auf `main`. Ein grüner Lauf bezieht sich auf den jeweiligen Commit und den Linux-Runner;
eine allgemeine Testzusage für alle Plattformen wird daraus nicht abgeleitet.

## Mitwirken und Lizenz

Bitte ändere bei Anpassungen am API-Vertrag immer Implementierungen, Tests und Dokumentation gemeinsam.
Beispiele sollen einen Arbeitsordner, ein erwartetes Ergebnis und einen Aufräumweg nennen.
Es gilt die [Apache License 2.0](LICENSE) für dieses Repository.
