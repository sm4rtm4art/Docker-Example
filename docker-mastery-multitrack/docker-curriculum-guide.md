# Lernpfad und Lernvereinbarung

## Zielgruppe und Arbeitsweise

Dieser Kurs setzt einfache Terminalkenntnisse und Erfahrung mit einer Programmiersprache voraus.
Wähle **einen** Track: Python/FastAPI, Rust/Actix Web oder Java/Spring Boot. Alle drei
implementieren denselben [API-Vertrag](../TASK_API_SPECIFICATION.md).

Arbeite jede Übung in vier Schritten durch: Ergebnis vorhersagen, Befehl ausführen,
Beobachtung notieren, Ursache erklären. Lies eine Musterlösung erst nach deinem eigenen Versuch.
Die Zeitangaben sind Planungswerte für einen Track, keine gemessenen Bearbeitungszeiten.

## Module

| Modul | Thema | Richtwert | Nachweis |
| --- | --- | --- | --- |
| 00 | [Voraussetzungen](00-prerequisites/prerequisites-overview.md) | 30–60 min | Arbeitsumgebung prüfen |
| 01 | [Container und Images](01-docker-fundamentals/docker-fundamentals-overview.md) | 60–90 min | Lebenszyklus und Portfreigabe erklären |
| 02 | [Eine Task API containerisieren](02-language-quickstart/quickstart-overview.md) | 60–90 min | Einen Sprachtrack bauen und per HTTP prüfen |
| 03 | [Dockerfiles und Builds](03-dockerfile-essentials/shared-concepts/dockerfile-essentials-overview.md) | 90–120 min | Build-Kontext, Cache und Multi-Stage verstehen |
| 04 | [Compose, Netzwerke und Daten](04-docker-compose/compose-overview.md) | 90–120 min | DNS und Datenpersistenz experimentell belegen |
| 05 | [Entwicklungsworkflow](05-development-workflow/development-workflow-overview.md) | 45–60 min | Änderungen und Fehler systematisch untersuchen |
| 06 | [Container-Sicherheit](06-security-best-practices/security-overview.md) | 60–90 min | Build- und Laufzeitschutz unterscheiden |
| 07 | [Betriebsverhalten](07-production-ready/production-excellence-overview.md) | 60–90 min | Health, Shutdown und Limits prüfen |
| 08 | [Monitoring](08-monitoring-stack/monitoring-overview.md) | 60–90 min | Metriken scrapen und korrekt interpretieren |
| 09 | [CI und Lernkontrolle](09-cicd-automation/cicd-overview.md) | 45–60 min | Prüfergebnisse und Grenzen einordnen |
| 10 | [Optional: Kubernetes mit kind](10-orchestration-intro/orchestration-preview.md) | 60–90 min | Deployment, Service und Probes anwenden |
| 11 | [Container-Werkzeuge einordnen](11-beyond-docker/container-alternatives-overview.md) | 30–45 min | Docker, Podman und containerd unterscheiden |

## Roter Faden

Du startest mit einem Container und baust anschließend eine kleine API. In Modul 03 untersuchst
du ihre Images. Modul 04 trennt Prozessspeicher, Containerdateisystem und dauerhafte Daten anhand
eines PostgreSQL-Labors. Entwicklung, Sicherheitsmaßnahmen und Betriebsverhalten folgen, bevor
ein Monitoring-Stack und eine CI hinzukommen. Kubernetes ist ein optionaler Transfer nach diesen Grundlagen.

Die Module bauen konzeptionell aufeinander auf, ihre Compose-Labore sind eigenständig startbar.
Alle allgemeinen Shell-Beispiele verwenden Bash und starten im Repository-Wurzelverzeichnis,
sofern direkt am Beispiel kein anderer Ordner angegeben ist. Unter Windows wird WSL empfohlen;
PowerShell-Einstieg steht in Modul 00. Jeder neue Terminaltab braucht seine eigenen Umgebungsvariablen.

## Lernstand dokumentieren

Erstelle für dich eine Tabelle mit Modul, Vorhersage, Beobachtung und Erklärung. Ein Modul ist
abgeschlossen, wenn du die Erfolgskontrolle selbstständig erklären und die Übung erneut ausführen kannst.
Die [Bewertungsrubrik](../LEARNING_OBJECTIVES.md) trennt technische Funktion und Verständnis.
CI-Berichte sind zusätzliche Belege und kein personenbezogenes Lernmanagementsystem.

## Grenzen des Kursprojekts

Aufgaben werden in allen Tracks in einem einzelnen Prozess gespeichert. Weder ein Volume-Mount
noch eine Umgebungsvariable `DATABASE_URL` erzeugt eine Datenbankintegration. Das PostgreSQL-Labor
prüft Datenpersistenz direkt per SQL. Eine Integration in alle drei APIs ist ein
[ausgewiesenes Erweiterungsprojekt](../TASKLIST.md).

Die Laufzeit-Compose-Dateien verwenden bereits Schutzmaßnahmen, die du später im Detail untersuchst.
Du musst diese beim ersten Start noch nicht alle verstehen. Baue einen Begriff nach dem anderen auf.

## Quellen und Versionspflege

Maßgeblich sind die verlinkten [Primärquellen](../SOURCES.md), die Dateien im jeweiligen Commit
und dessen CI-Ergebnisse. Versions-Tags sind lesbar, aber veränderlich. Lockfiles fixieren
Anwendungsabhängigkeiten; vollständige Reproduzierbarkeit benötigt zusätzlich Image-Digests
und eine kontrollierte Paketversorgung.
