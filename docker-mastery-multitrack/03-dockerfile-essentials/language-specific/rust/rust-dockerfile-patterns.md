# Dockerfile-Muster für Rust

## Lernziele

Du begründest die Besonderheiten deines Tracks, ohne ein zweites, abweichendes Dockerfile aus der
Dokumentation zu kopieren.

## Voraussetzung

Die beiden gemeinsamen Lektionen in Modul 03. Referenz ist der
[ausführbare Dockerfile](../../../02-language-quickstart/rust/Dockerfile).

## Übung

Prüfe `Cargo.lock`, den Release-Build mit `--locked` und das COPY aus dem Builder.
Die Registry und das Target-Verzeichnis werden als Cache-Mount eingebunden. Der Cache darf die
Korrektheit nicht verändern: Baue nach einer sichtbaren Source-Änderung und kontrolliere die HTTP-Antwort.

Der Debian-Builder und die Debian-Runtime vermeiden einen unbeabsichtigten musl/glibc-Wechsel.
Prüfe eine neue Basisversion zusätzlich mit dem Container-Vertragstest. Ein erfolgreicher Compilerlauf
beweist nicht, dass alle Laufzeitbibliotheken vorhanden sind.

Für lokale Abhängigkeitspflege: `cargo update` bewusst ausführen, Lockfile-Diff prüfen und anschließend
`cargo build --locked --release`. Unabhängige Aktualisierungen nicht mit einem fachlichen Fehler vermischen.

Führe aus dem Repository-Wurzelverzeichnis den vollständigen Trackcheck aus:

```bash
python3 scripts/validate.py track --track rust
```

Er startet ein eigenes Compose-Projekt, prüft den HTTP-Vertrag und die Laufzeitkonfiguration und
räumt nur dieses Testprojekt auf. Dockerzugriff ist erforderlich.

## Erfolgskontrolle

Du erklärst, welche Abhängigkeiten nur zum Bauen benötigt werden und welche beim Start vorhanden
sein müssen. Du kannst einen Buildfehler von einem Fehler beim Containerstart unterscheiden.

[Zurück zur Modulübersicht](../../shared-concepts/dockerfile-essentials-overview.md)
