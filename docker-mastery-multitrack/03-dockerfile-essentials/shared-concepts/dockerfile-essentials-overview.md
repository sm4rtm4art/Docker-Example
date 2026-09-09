# 03 – Dockerfiles und wiederholbare Builds

## Lernziele

Du erklärst Build-Kontext, COPY, Cache-Invalidierung, Multi-Stage-Builds und die Grenzen von Tags
und Lockfiles. Richtwert: 90–120 Minuten.

## Voraussetzung

Ein funktionierender Track aus Modul 02. Verwende dessen echte Dateien als Referenz.

## Übung

1. [Dockerfile-Grundlagen](01-dockerfile-fundamentals.md): Kontext und Cache untersuchen.
2. [Multi-Stage-Builds](02-multistage-builds.md): Builder und Runtime vergleichen.
3. Die passende Vertiefung lesen: [Python](../language-specific/python/python-dockerfile-patterns.md),
   [Rust](../language-specific/rust/rust-dockerfile-patterns.md) oder
   [Java](../language-specific/java/java-dockerfile-patterns.md).

Ändere in deiner Arbeitskopie eine sichtbare API-Antwort, baue erneut und prüfe die Änderung per HTTP.
Halte fest, welche Build-Schritte erneut ausgeführt werden. Mache die lokale Übungsänderung danach
gezielt rückgängig; verwirf keine anderen eigenen Änderungen.

## Erfolgskontrolle

Du kannst erklären, warum `.dockerignore` einen COPY-Schritt scheitern lassen kann, weshalb ein
Source-Edit nicht alle Abhängigkeiten neu laden muss und warum ein Tag kein unveränderlicher Stand ist.

[Weiter: Compose](../../04-docker-compose/compose-overview.md)
