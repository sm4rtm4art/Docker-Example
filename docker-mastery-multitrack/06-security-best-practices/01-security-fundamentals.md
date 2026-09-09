# Sicherheitsgrundlagen: Schutzmaßnahme und Nachweis

## Lernziele

Du kannst ein kleines Bedrohungsmodell formulieren und die Kurskonfiguration begründet beurteilen.

## Voraussetzung

Repository-Wurzelverzeichnis; die API aus `compose.lab.yml` ist gestartet.

## Konzept

Für dieses Labor betrachten wir eine kompromittierte API: Sie soll möglichst wenige Dateien ändern,
keine zusätzlichen Kernelprivilegien bekommen und nicht ungebremst Hostressourcen verbrauchen.
Netzwerkangriffe, Anwendungsauthentifizierung und Hostadministration sind zusätzliche Ebenen.

| Ebene | Maßnahme im Beispiel | Grenze |
| --- | --- | --- |
| Image | `USER 10001:10001`, root-eigener Code | Schützt nicht vor einem privilegierten Daemonbenutzer |
| Laufzeit | `read_only: true` | Benötigte Schreibpfade müssen ausdrücklich bereitstehen |
| Laufzeit | tmpfs für `/tmp` | Flüchtig; kein Schutz vor bösartiger Verwendung erlaubter Pfade |
| Laufzeit | `cap_drop: [ALL]` | Ersetzt keine Kernelupdates oder Anwendungssicherheit |
| Laufzeit | `no-new-privileges` | Verhindert zusätzliche Privilegien über exec, nicht jede Eskalationslücke |
| Ressourcen | Speicher-, CPU- und PID-Grenzen | Müssen mit realistischer Last dimensioniert werden |
| Netzwerk | Hostbindung `127.0.0.1` | Kein Ersatz für Authentifizierung in einer echten Bereitstellung |

Der Datenbankcontainer darf die Initialisierung nach dem Verfahren seines offiziellen Images
ausführen. Eine pauschale UID-Überschreibung kann Eigentümer und Startlogik beschädigen.
Prüfe bei fremden Images deren dokumentiertes Laufzeitmodell, statt „immer non-root“ ungeprüft anzunehmen.

## Übung

```bash
docker compose -p docker-learning -f compose.lab.yml exec task-api id
docker compose -p docker-learning -f compose.lab.yml exec task-api touch /app/should-fail
docker compose -p docker-learning -f compose.lab.yml exec task-api touch /tmp/allowed
```

Erwartet: UID 10001, erster Schreibversuch schlägt fehl, zweiter funktioniert. Ein Fehler ist hier
Teil des Versuchs. Untersuche anschließend `docker inspect` und finde ReadonlyRootfs, CapDrop und
SecurityOpt. Der automatische Tracktest prüft genau diese Eigenschaften am gestarteten Container.

### Geheimnisse richtig einordnen

Kopiere keine `.env`, privaten Schlüssel oder Zugangstoken ins Image. Auch Build-ARG und ENV sind
kein Secret-Transport. BuildKit-Secret-Mounts sind für temporäre Buildzugriffe geeignet, aber ein
Buildschritt darf das Secret weiterhin nicht in ein Artefakt oder Log schreiben.

Compose-Secrets können Dateien gezielt unter `/run/secrets/` bereitstellen. Lokale dateibasierte
Compose-Secrets sind kein verschlüsselter zentraler Secret-Store. Hostdateirechte, Backups und
Anwendungsunterstützung für Dateieingaben bleiben relevant. Die Datenbank- und Grafana-Labore
verwenden ausdrücklich lokale Übungszugänge; führe damit keine echten Daten.

### Lieferkette

Verwende unterstützte Basisimages, überprüfbare Versionen, echte Lockfiles und regelmäßige Updates.
Die Kursimages verwenden lesbare Versions-Tags; diese können sich ändern. Digest-Pinning mit
kontrollierten Aktualisierungen ist die Vertiefung für reproduzierbare Lieferketten. Die CI erzeugt
einen **beratenden** Trivy-Bericht über Repository-Abhängigkeiten und mögliche Geheimnisse.
Sie scannt damit nicht automatisch alle OS-Pakete der gebauten Runtime-Images.

## Erfolgskontrolle

Ordne drei Maßnahmen einem konkreten Risiko zu. Erkläre, warum `USER`, ein schreibgeschütztes
Rootdateisystem und ein Schwachstellenscan unterschiedliche Dinge prüfen. Ein grüner Funktionstest
ist keine Sicherheitsfreigabe.

## Aufräumen

`python3 scripts/cleanup.py api` entfernt das API-Projekt; der temporäre Schreibversuch hinterlässt
keine dauerhaften Anwendungsdaten.

Quellen: [Docker-Sicherheitsmodell](https://docs.docker.com/engine/security/),
[Runtime-Optionen](https://docs.docker.com/engine/containers/run/),
[Build-Secrets](https://docs.docker.com/build/building/secrets/),
[Compose-Secrets](https://docs.docker.com/compose/how-tos/use-secrets/).
