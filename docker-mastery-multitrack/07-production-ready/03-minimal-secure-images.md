# Minimale Images mit nachvollziehbaren Grenzen

## Lernziele

Du wählst eine Runtime-Basis anhand ihrer Anforderungen und prüfst die Folgen einer Verkleinerung.

## Voraussetzung

Multi-Stage-Builds und die Sicherheitsübung. Verwende die echten Track-Dockerfiles als Ausgangspunkt.

## Konzept

Weniger Pakete können Wartung und Angriffsfläche reduzieren. Größe allein misst weder Sicherheit
noch Performance. Eine Shell ist ein Diagnosewerkzeug und zugleich zusätzliche Software; ihre
Entfernung ist eine Abwägung. Distroless bedeutet nicht pauschal non-root: Das hängt vom gewählten
Image und dessen Variante ab.

Ein `scratch`-Image enthält keine Shell, keinen Paketmanager und keine Zertifikate. Es eignet sich
nur, wenn das kopierte Programm und seine benötigten Dateien dafür vorbereitet wurden. Ein Rust-
Binary kann dynamisch gelinkt sein. Ein Python-Virtualenv ersetzt nicht den Interpreter.

Fehlendes curl verhindert keinen Healthcheck grundsätzlich: Ein vorhandenes Programm oder die
Anwendung selbst kann prüfen, und ein Orchestrator kann HTTP-Probes von außen ausführen.
Der Python-Track nutzt dafür bereits die Standardbibliothek.

## Übung

Prüfe in deinem Runtime-Dockerfile jede installierte Systemabhängigkeit und notiere ihren Zweck.
Wähle eine denkbare Verkleinerung und formuliere vor der Umsetzung den erforderlichen Nachtest:
Build, Start, TLS-Verbindung falls relevant, Healthcheck, UID und Stop-Signal.

Baue das unveränderte Referenzimage und messe dessen reale Größe wie in Modul 03. Eine optionale
Distroless-Variante ist erst erfolgreich, wenn sie dieselben Laufzeitprüfungen erfüllt. Der Kurs
enthält dafür bewusst keine ungetestete zweite „sichere“ Kopiervorlage.

## Erfolgskontrolle

Du kannst eine Basisentscheidung mit Kompatibilität, Pflege, Diagnose und Rechten begründen.
Du erklärst, warum ein Scanner ohne Befunde keine Abwesenheit von Schwachstellen beweist.

Quellen: [Docker-Buildempfehlungen](https://docs.docker.com/build/building/best-practices/),
[Distroless-Projekt](https://github.com/GoogleContainerTools/distroless).
