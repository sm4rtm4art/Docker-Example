# Compose-Netzwerke: Namen und Erreichbarkeit

## Lernziele

Du unterscheidest Hostzugriff, Container-DNS und den Zugriff über gemeinsame Netzwerke.

## Voraussetzung

Die Compose-Grundlagen dieses Moduls. Alle Befehle im Repository-Wurzelverzeichnis.

## Konzept

Innerhalb eines Compose-Netzwerks wird ein Service unter seinem Servicenamen gefunden. Der Client
verbindet sich mit `postgres:5432`, nicht mit `localhost:5432`. `localhost` bezeichnet den eigenen
Netzwerk-Namespace. Container-IP-Adressen können sich nach einer Neuerstellung ändern.

Die Datenbank veröffentlicht bewusst keinen Hostport. Der Client benötigt keine solche Freigabe,
weil er Mitglied desselben Netzwerks ist. `internal: true` begrenzt dessen externe Konnektivität.
Der Hostadministrator und der Docker-Daemon bleiben außerhalb dieser Schutzgrenze.

## Übung

```bash
export DB_COMPOSE=docker-mastery-multitrack/common-resources/templates/docker-compose.database.yml
docker compose -p docker-learning-db -f "$DB_COMPOSE" up -d --wait postgres
docker compose -p docker-learning-db -f "$DB_COMPOSE" run --rm client -c 'SELECT current_database(), current_user;'
docker network inspect docker-learning-db_database
```

Erwartet werden Datenbank `learning` und Benutzer `learner`. Im Netzwerk-Inspect findest du die
aktuell angeschlossenen Container. Die Clientverbindung belegt DNS-Auflösung und TCP-Verbindung
zusammen mit erfolgreicher Datenbankanmeldung.

### Fehler gezielt erzeugen

```bash
docker compose -p docker-learning-db -f "$DB_COMPOSE" run --rm client -h localhost -c 'SELECT 1;'
```

Erwartet wird ein Verbindungsfehler: Im Clientcontainer läuft kein Datenbankserver.
Wiederhole mit `-h postgres` und erkläre den Unterschied. Dieses Experiment benötigt keinen
zusätzlichen Hostport und keine fest codierte Container-IP.

## Erfolgskontrolle

Zeichne oder beschreibe Host, Client und Datenbank mit ihren Ports. Beantworte: Wann ist `ports`
erforderlich? Was passiert bei einem falschen Servicenamen? Warum ist „kein veröffentlichter Port“
keine vollständige Zugriffskontrolle gegen einen Hostadministrator?

## Aufräumen

```bash
python3 scripts/cleanup.py database
```

Quelle: [Netzwerke in Compose](https://docs.docker.com/compose/how-tos/networking/).
