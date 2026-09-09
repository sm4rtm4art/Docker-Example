# Dockerfile-Grundlagen: vom Kontext zum Prozess

## Lernziele

Du ordnest jede zentrale Dockerfile-Anweisung einer Wirkung beim Build oder beim Start zu.

## Voraussetzung

Modul 02; ein ausgewählter Track. Befehle starten im Repository-Wurzelverzeichnis.

## Konzept

| Anweisung | Wirkung | Häufiges Missverständnis |
| --- | --- | --- |
| FROM | Basis bzw. neue Build-Stufe | Ein Tag ist kein Digest |
| WORKDIR | Arbeitsverzeichnis für folgende Anweisungen | Ändert nicht dein Host-Terminal |
| COPY | Dateien aus dem Kontext oder einer Stufe übernehmen | Der Pfad bezieht sich nicht beliebig auf den Host |
| RUN | Prozess während des Builds ausführen | Läuft nicht bei jedem Containerstart |
| ENV | Variable als Imagekonfiguration setzen | Kein sicherer Ort für Passwörter |
| USER | Standardbenutzer für folgende Schritte und Laufzeit | Bedeutet nicht, dass der Docker-Daemon rootless läuft |
| EXPOSE | Beabsichtigten Containerport dokumentieren | Veröffentlicht keinen Hostport |
| CMD / ENTRYPOINT | Startprogramm und Standardargumente | Shell-Form kann die Signalweiterleitung beeinflussen |

Dateisystemändernde Schritte erzeugen Layer; Metadatenanweisungen sind nicht pauschal zusätzliche
Dateisystemschichten. Ein späteres Löschen entfernt vertrauliche Daten nicht aus früheren Layern.

## Übung

```bash
export TASK_TRACK=python
docker build --progress=plain -t task-api:cache "docker-mastery-multitrack/02-language-quickstart/$TASK_TRACK"
docker build --progress=plain -t task-api:cache "docker-mastery-multitrack/02-language-quickstart/$TASK_TRACK"
docker image history task-api:cache
docker image inspect task-api:cache --format '{{json .Config}}'
```

Wiederhole den Build nach einer kleinen Änderung an der Root-Antwort deines Tracks. Notiere zuerst,
welche Schritte du für erneut notwendig hältst. Vergleiche dies mit `CACHED` im Buildprotokoll.
RUN-Schritte holen bei einem Cachetreffer nicht automatisch neue Paketstände aus dem Netz.
Ein Build mit `--pull` aktualisiert Basisreferenzen; `--no-cache` deaktiviert den Buildcache.
Keines davon ersetzt eine kontrollierte Versionsaktualisierung.

Untersuche `.dockerignore`: Sind `.venv/`, `target/` und lokale Geheimnisse ausgeschlossen?
Bleiben Quellcode, Manifeste und Lockfiles zugänglich? Teste in einer Kopie des Trackordners,
was passiert, wenn `src/` ausgeschlossen wird. Erwartet wird ein fehlgeschlagener COPY-Schritt.

## Erfolgskontrolle

Du kannst den Build-Kontext zeigen, zwei unterschiedliche Cache-Invalidierungen erklären und
sagen, weshalb Geheimnisse weder in ARG/ENV noch in COPY-Dateien gehören.

## Aufräumen

Entferne nur das Übungsimage mit `docker image rm task-api:cache`, nachdem kein Container es mehr nutzt.
Setze deine kleine Source-Änderung gezielt zurück.

Quellen: [Dockerfile-Referenz](https://docs.docker.com/reference/dockerfile/),
[Buildcache](https://docs.docker.com/build/cache/),
[Build-Kontext](https://docs.docker.com/build/building/context/).
