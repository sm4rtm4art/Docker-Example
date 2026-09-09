# 04 – Compose, Netzwerke und Daten

## Lernziele

Du startest mehrere Dienste deklarativ, nutzt Servicenamen statt Container-IP-Adressen und
beweist Datenpersistenz über die Neuerstellung eines Containers. Richtwert: 90–120 Minuten.

## Voraussetzung

Module 00–03. Die Task API und das Datenbanklabor sind getrennte Beispiele. Die API speichert
weiter im Prozessspeicher; PostgreSQL wird hier direkt mit einem SQL-Client untersucht.

## Übung

1. [Compose-Grundlagen](01-compose-basics.md): Konfiguration, Projekt und Healthchecks.
2. [Netzwerke](02-compose-networking.md): DNS und interne Ports.
3. [Volumes](03-compose-volumes.md): Persistenz und gezieltes Aufräumen.

Der ausführbare Datenbank-Compose liegt in
[common-resources/templates](../common-resources/templates/docker-compose.database.yml).
Nutze in allen Befehlen den Projektnamen `docker-learning-db`, damit die Übung dieselben Ressourcen verwendet.

## Erfolgskontrolle

`python3 scripts/validate.py database` prüft Verbindung, SQL und Persistenz in einem eigenen
Testprojekt. Zusätzlich kannst du erklären, warum ein gestarteteter Container nicht zwingend
bereit ist und weshalb zwei Container auf verschiedenen Netzwerken einander nicht automatisch erreichen.

[Weiter: Entwicklungsworkflow](../05-development-workflow/development-workflow-overview.md)
