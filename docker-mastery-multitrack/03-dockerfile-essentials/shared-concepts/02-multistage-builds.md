# Multi-Stage-Builds: Werkzeuge und Laufzeit trennen

## Lernziele

Du kannst ein Artefakt zwischen Stufen übertragen und seine Laufzeitabhängigkeiten begründen.

## Voraussetzung

Dockerfile-Grundlagen. Befehle laufen im Repository-Wurzelverzeichnis.

## Konzept

Eine neue `FROM`-Anweisung beginnt eine neue Stufe. Nur gezielt kopierte Dateien und die gewählte
Runtime-Basis gelangen ins finale Image. Ein kleineres Image ist leichter zu verteilen, aber nicht
allein deshalb sicher. Bibliotheken, Zertifikate, Benutzer und Startkommando müssen zusammenpassen.

| Track | Build-Artefakt | Runtime benötigt |
| --- | --- | --- |
| Python | Virtualenv plus Quellcode | Kompatiblen Python-Interpreter und Bibliotheken |
| Rust | Kompilierte ausführbare Datei | Passende libc und ggf. dynamische Bibliotheken |
| Java | Ausführbares Spring-Boot-JAR | Passende JRE |

Ein Virtualenv ist nicht beliebig zwischen Betriebssystemen, Architekturen oder Python-Versionen
verschiebbar. Ein Rust-Binary ist nicht automatisch statisch gelinkt. Alpine verwendet musl,
Debian glibc. Deshalb verwenden die Rust-Stufen hier dieselbe Debian-Familie.

## Übung

Für Java oder Rust (ersetze `java` bei Bedarf):

```bash
export TASK_TRACK=java
docker build --target builder -t task-api:builder "docker-mastery-multitrack/02-language-quickstart/$TASK_TRACK"
docker build -t task-api:runtime "docker-mastery-multitrack/02-language-quickstart/$TASK_TRACK"
docker image inspect task-api:builder task-api:runtime --format '{{.RepoTags}} {{.Size}}'
docker run --rm --entrypoint sh task-api:runtime -c 'id; command -v javac || command -v cargo || true'
```

Für Python heißt die Abhängigkeitsstufe `dependencies`. Passe `--target` entsprechend an.
Erwarte keine festen Größenwerte: Architektur, Basisstand und Abhängigkeiten beeinflussen das Ergebnis.
Notiere die tatsächlichen Werte und erkläre den Unterschied.

Beim Rust-Build ist `target/` ein Cache-Mount. Sein Inhalt wird nicht automatisch Teil des Layers.
Deshalb kopiert derselbe RUN-Schritt das Binary nach `/tmp/task-api`, bevor die Runtime es übernimmt.

## Erfolgskontrolle

Du findest das `COPY --from=...` und erklärst dessen Quellpfad. Du kannst sagen, welche Dateien
bei einem Wechsel der Runtime-Basis erneut auf Kompatibilität geprüft werden müssen.

## Aufräumen

```bash
docker image rm task-api:builder task-api:runtime
```

Quelle: [Multi-Stage-Builds](https://docs.docker.com/build/building/multi-stage/).
