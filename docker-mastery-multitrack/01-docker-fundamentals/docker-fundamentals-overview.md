# 01 – Container, Images und Lebenszyklus

## Lernziele

Du unterscheidest Image, Container und Registry, erklärst Portfreigaben und beobachtest den
Lebenszyklus eines Prozesses. Richtwert: 60–90 Minuten.

## Voraussetzung

Modul 00 ist abgeschlossen. Befehle laufen in Bash im Repository-Wurzelverzeichnis.

## Konzept

Ein Image enthält Dateisystemschichten und Startkonfiguration. Ein Container entsteht aus einem
Image und bekommt unter anderem eine beschreibbare Schicht sowie Laufzeitkonfiguration. Mehrere
Container können dasselbe Image verwenden und trotzdem unterschiedliche Daten besitzen.
Eine Registry verteilt Images. Ein Tag bezeichnet eine veränderliche Referenz; ein Digest adressiert
konkreten Inhalt.

Linux-Container isolieren Prozesse mit Kernelmechanismen wie Namespaces und begrenzen Ressourcen
über cgroups. Sie teilen den Kernel des Linux-Hosts. Auf Docker Desktop läuft dieser typischerweise
in einer Linux-VM. Ein Container ist deshalb weder eine vollständige VM noch eine absolute Sicherheitsgrenze.

## Übung

Sage zuerst voraus, ob dieser Container dauerhaft läuft:

```bash
docker run --name docker-learning-once alpine:3.22 echo 'Hallo Container'
docker ps
docker ps -a --filter name=docker-learning-once
docker inspect docker-learning-once --format '{{.State.ExitCode}}'
docker rm docker-learning-once
```

Der Hauptprozess `echo` beendet sich erfolgreich. Deshalb ist der Container anschließend gestoppt,
obwohl das Image weiterhin vorhanden ist. `docker ps` zeigt nur laufende Container.
`docker rm` entfernt den Container, nicht automatisch sein Image.

### Einen Dienst beobachten

```bash
docker run -d --name docker-learning-web -p 127.0.0.1:8088:80 nginx:stable-alpine
curl --fail http://127.0.0.1:8088/
docker logs --tail 20 docker-learning-web
docker inspect docker-learning-web --format '{{json .NetworkSettings.Ports}}'
docker stop docker-learning-web
docker start docker-learning-web
docker rm -f docker-learning-web
```

`8088` ist der Hostport, `80` der Containerport. Ein `EXPOSE 80` im Image allein veröffentlicht
keinen Hostport. Die Bindung an `127.0.0.1` begrenzt diese Freigabe auf den lokalen Host.
`stable-alpine` ist für diese isolierte Erstübung ein veränderlicher Tag, keine festgeschriebene Version.
Untersuche den aufgelösten Digest mit `docker image inspect nginx:stable-alpine`.

### Vorhersagen prüfen

Starte den Webcontainer erneut. Versuche, einen zweiten Dienst mit demselben Hostport zu starten.
Lies die Fehlermeldung und wähle für den zweiten Versuch einen anderen Port. Entferne anschließend
nur deine beiden Übungscontainer. Führe dabei keine globale Bereinigung aus.

## Erfolgskontrolle

Erkläre in eigenen Worten:

1. Warum ist `docker-learning-once` beendet, aber sein Image noch verfügbar?
2. Was unterscheidet `stop`, `rm` und `image rm`?
3. Warum funktioniert `curl localhost:80` auf dem Host nicht automatisch?
4. Welche Dateiänderungen würdest du bei `stop/start` und bei `rm/run` erwarten?

Die letzte Frage wird in Modul 04 experimentell vertieft.

## Weiter

[02 – Einen Sprachtrack auswählen](../02-language-quickstart/quickstart-overview.md)

Quellen: [Container ausführen](https://docs.docker.com/engine/containers/run/),
[Portfreigaben](https://docs.docker.com/engine/network/port-publishing/).
