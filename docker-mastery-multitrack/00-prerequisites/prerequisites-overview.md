# 00 – Arbeitsumgebung vorbereiten

## Lernziele

Du kannst Docker-Client und Daemon unterscheiden, deinen aktiven Kontext erkennen und die
Kurswerkzeuge prüfen. Richtwert: 30–60 Minuten.

## Voraussetzung

Du kennst Ordnerwechsel, Dateien und einfache Terminalbefehle. Benötigt werden Git, eine aktuelle
unterstützte Docker-Installation mit Linux-Containern und Compose-Plugin sowie Python 3.12+ für
Prüfskripte. curl dient den manuellen HTTP-Beispielen. Java, Cargo und uv müssen für den
Containerpfad nicht auf dem Host installiert sein.

Unter Linux ist Docker Engine mit Compose-Plugin möglich. Unter macOS und Windows ist Docker Desktop
ein möglicher Weg; prüfe dessen Systemanforderungen und Lizenzbedingungen beim Anbieter.
Für Bash-Beispiele unter Windows verwende WSL2 und aktiviere die Docker-Integration für diese Distribution.
Kopiere kein Host-Python-Virtualenv oder kompiliertes Rust-Binary in einen Linux-Container.

Plane als Ausgangspunkt etwa 4 GB freien Arbeitsspeicher und 10 GB freien Speicher für einzelne
Labore ein, für Rust-Builds, Monitoring und kind mehr. Das sind Planungswerte, keine Garantie.

## Übung

Im Repository-Wurzelverzeichnis:

```bash
docker version
docker context show
docker info --format '{{.OSType}}'
docker compose version
python3 --version
git --version
bash docker-mastery-multitrack/00-prerequisites/verify-setup.sh
```

`docker version` soll einen erreichbaren Server zeigen, der Betriebssystemtyp lautet `linux`.
Der Kurs verwendet Compose mit `up --wait`; prüfe mit `docker compose up --help`, ob diese Option
vorhanden ist. Bei Fehlermeldungen zuerst Kontext, Daemon und Berechtigungen klären.
Der Setup-Check installiert nichts und verändert weder Gruppen noch Socket-Rechte.

### PowerShell

Der vollständige Kurs ist in Bash beschrieben. Einstieg und API-Prüfung funktionieren auch so:

```powershell
python --version
./docker-mastery-multitrack/00-prerequisites/verify-setup.ps1
$env:TASK_TRACK = 'python'
docker compose -p docker-learning -f compose.lab.yml up --build --wait
curl.exe --fail http://127.0.0.1:8080/health
python scripts/api_contract.py
python scripts/cleanup.py api
```

Für mehrzeilige Bash-Kommandos, `export` und die folgenden Linux-Shell-Übungen wechsle in WSL.
Ein `python3`-Aufruf wird im nativen Windows-Terminal je nach Installation zu `python`.

## Erfolgskontrolle

- Du kannst zeigen, welcher Docker-Kontext benutzt wird und wo der Daemon läuft.
- Der Setup-Check beendet sich mit Exitcode 0.
- Du erklärst, warum der lokale Java-Compiler für `docker build` nicht benötigt wird.

Wenn Docker nicht erreichbar ist, verwende die [Fehlersuche](../common-resources/DOCKER_EMERGENCY_GUIDE.md).
Zugriff auf einen privilegierten Docker-Daemon ist weitreichender Hostzugriff; ein pauschales
`chmod 666` auf dem Docker-Socket ist keine geeignete Fehlerbehebung.

## Weiter

[01 – Container und Images](../01-docker-fundamentals/docker-fundamentals-overview.md)

Quellen: [Docker Engine installieren](https://docs.docker.com/engine/install/),
[Docker-Kontexte](https://docs.docker.com/engine/manage-resources/contexts/).
