# 02 – Eine Task API containerisieren

## Lernziele

Du baust ein Anwendungsimage, startest es mit Compose und prüfst einen vollständigen HTTP-Lebenszyklus.
Richtwert: 60–90 Minuten für einen Track.

## Voraussetzung

Module 00–01. Die Anwendung selbst ist vorbereitet. Du musst kein Framework neu lernen.
Wähle [Python](python/python-quickstart.md), [Rust](rust/rust-quickstart.md)
oder [Java](java/java-quickstart.md).

## Übung

Die Trackanleitung führt durch Build, Start, Healthcheck und API-Test. Untersuche anschließend
in deinem Track `Dockerfile`, `docker-compose.yml` und den Quellcode des `/health`-Endpunkts.
Finde jeweils heraus, welche Datei eine Änderung am Hostport, am Prozessstart oder an der HTTP-Antwort erfordert.

Alle Tracks verwenden Port 8080 im Container, `/api/tasks`, `/health` und `/metrics`.
Die Standard-Compose-Datei startet das Runtime-Image; Entwicklungsdateien folgen in Modul 05.
Es läuft nur ein API-Prozess. Ein Reload oder Neustart verliert alle Aufgaben.

## Erfolgskontrolle

- Sieben gemeinsame HTTP-Tests sind erfolgreich.
- Du kannst eine Aufgabe anlegen, lesen, ersetzen und löschen.
- Du erklärst den Unterschied zwischen einer App-Änderung und einer Portfreigabe.

[Weiter: Modul 03](../03-dockerfile-essentials/shared-concepts/dockerfile-essentials-overview.md)
