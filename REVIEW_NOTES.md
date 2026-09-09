# Überarbeitungsbefunde

Ausgangspunkt: Commit `9c0b68f832cf67b068bd56f01fa907e4ae89d8d2` auf `main`.
Die Modulpfade 00–11 und die drei Sprachen bleiben erhalten.

## Wesentliche Korrekturen

| Befund | Auswirkung | Überarbeitung |
| --- | --- | --- |
| API-Dokumentation versprach Datenbankintegration; Anwendungen verwendeten Speicherstrukturen | Falsche Erwartungen an Volumes und Persistenz | Implementierten Stand dokumentiert; eigenständiges SQL-/Volume-Labor |
| Java lieferte Liste, numerische IDs und andere Zeitstempelnamen | Kein gemeinsamer API-Vertrag | UUIDs, Listenhülle, UTC-Felder und CRUD-Verhalten angeglichen |
| Healthmeldungen behaupteten eine verbundene Datenbank | Falsches Betriebssignal | `/health` meldet ehrlich `storage: memory` in allen Tracks |
| Aufgabenbestand wurde als Counter deklariert | Fachlich falsche Monitoringinterpretation | Drei Bestands-Gauges mit gemeinsamen Tests |
| Python lieferte Metriktext als JSON-String | Nicht korrekt als Prometheus-Exposition nutzbar | Explizite Text-Response und Content-Type-Test |
| Python-Lockfile enthielt nur einen Platzhalter | Keine abgesicherte Abhängigkeitsauflösung | Echtes generiertes Lockfile und `uv sync --locked` |
| Rust verwendete einen Dummy-Source-Cache und ungebundene Toolchains | Risiko eines falschen Artefakts; schwer reproduzierbare Builds | Echter Source-Build mit BuildKit-Caches und gepinnter Toolchain |
| UID/GID-Wiederverwendung passte nicht immer zum späteren USER-Gruppennamen | Containerstart konnte an fehlender Gruppe scheitern | Einheitliche numerische UID/GID 10001 |
| Dev-/Runtime-Verhalten und Ports waren nicht konsistent beschrieben | Kopierbeispiele widersprachen echten Dateien | Getrennte Dev-Konfigurationen, gemeinsame Runtime und lokale Portbindung |
| Java exponierte unnötige Actuator-Informationen | Zusätzliche nicht benötigte Endpunkte | Kleine gemeinsame API ohne Actuator-Abhängigkeit |
| Globale Cleanup-Funktionen und weitreichende Prunes | Fremde Ressourcen konnten betroffen sein | Nur benannte Kursprojekte; Datenlöschung explizit |
| Umfangreiche Kopiervorlagen und Produktionsbehauptungen ohne CI-Nachweis | Inhalt driftete gegenüber Code | Echte Dateien als Referenz, klare Grenzen und ausführbare Prüfungen |

## Didaktik

Jedes Modul besitzt Lernziele, Voraussetzungen, Übung und Erfolgskontrolle. Die Texte sind deutsch,
sachlich und ohne dekorative Emojis. Ein Track genügt. Der Kurs unterscheidet technische Testbelege,
selbstständige Erklärung und Transferleistung. Zeiten sind Planungswerte.

## Validierungsumfang

Lokal können Syntax, Links und der Python-HTTP-Vertrag geprüft werden. Container-Builds und
Betriebschecks benötigen einen erreichbaren Docker-Daemon; ohne diesen darf kein bestandener
Containercheck behauptet werden. Maßgeblich für Builds sind die konkreten GitHub-Actions-Läufe
im zugehörigen Pull Request, nicht eine pauschale Plattformzusage.

## Bewusste Grenzen

- Keine persistente Task API, Authentifizierung oder gemeinsame Datenhaltung mehrerer Replikate.
- Lesbare Imageversionen, nicht flächendeckend unveränderliche Digests oder hermetische OS-Pakete.
- Security-Scan beratend und auf Repository-Ebene; kein vollständiger Runtime-Imagescan.
- Automatische Monitoringprüfung ohne visuelle Dashboardprüfung.
- Stop-Signal-Test ohne Nachweis für laufende Langzeitanfragen.
- Reguläre CI auf Linux; kind als separater manueller Workflow; keine pauschale ARM-/Windows-/macOS-Zusage.

Priorisierte nächste Schritte stehen in [TASKLIST.md](TASKLIST.md).
