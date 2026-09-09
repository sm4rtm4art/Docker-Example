# Compose-Grundlagen: gewünschte Konfiguration beschreiben

## Lernziele

Du liest Services, Volumes und Netzwerke, unterscheidest Build und Start und kontrollierst die
aufgelöste Konfiguration vor der Ausführung.

## Voraussetzung

Module 00–03; Repository-Wurzelverzeichnis, Bash. Du brauchst keinen lokalen PostgreSQL-Client.

## Konzept

Compose verwendet ein Projekt als Namensraum für zusammengehörige Ressourcen. `-p` setzt dessen Namen
explizit. Ein Service kann ein Image referenzieren oder mit `build` gebaut werden. Die aktuelle
Compose Specification benötigt kein oberstes `version`-Feld.

`depends_on` in Kurzform beschreibt eine Startabhängigkeit, keine erfolgreiche Datenbankverbindung.
Mit `condition: service_healthy` wartet Compose auf den konfigurierten Healthcheck. Das ersetzt
keine Fehlerbehandlung, wenn die Abhängigkeit später ausfällt. `up --wait` wartet auf laufende bzw.
gesunde Services; ohne Healthcheck ist „running“ keine fachliche Bereitschaft.

## Übung

```bash
export DB_COMPOSE=docker-mastery-multitrack/common-resources/templates/docker-compose.database.yml
docker compose -p docker-learning-db -f "$DB_COMPOSE" config
docker compose -p docker-learning-db -f "$DB_COMPOSE" up -d --wait postgres
docker compose -p docker-learning-db -f "$DB_COMPOSE" ps
docker compose -p docker-learning-db -f "$DB_COMPOSE" run --rm client
```

Der SQL-Client ist ein kurzlebiger zweiter Container. Er soll `1` zurückgeben und danach verschwinden.
Das Profil `tools` hält ihn aus einem normalen Stackstart heraus; ein explizites `run client` führt
ihn trotzdem aus. `--rm` entfernt nur diesen beendeten Clientcontainer.

Lies den Healthcheck. `$${POSTGRES_USER}` wird als `$POSTGRES_USER` an die Containershell weitergegeben.
Ein einfaches `$` würde bereits von Compose auf dem Host interpoliert. Die lokalen Übungspasswörter
sind sichtbar und ausschließlich für dieses isolierte Labor geeignet.

## Erfolgskontrolle

Erkläre anhand der Datei: Welche Dienste laufen dauerhaft? Welches Volume gehört zum Projekt?
Welcher Prozess beantwortet den Healthcheck? Welche Fehler können trotz `service_healthy` später auftreten?

## Aufräumen

Wenn du direkt mit Netzwerk- und Volumeübung fortsetzt, lasse PostgreSQL laufen. Sonst:

```bash
python3 scripts/cleanup.py database
```

Quellen: [Compose Services](https://docs.docker.com/reference/compose-file/services/),
[Startreihenfolge](https://docs.docker.com/compose/how-tos/startup-order/).
