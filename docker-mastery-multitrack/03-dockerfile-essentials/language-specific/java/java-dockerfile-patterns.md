# Dockerfile-Muster für Java

## Lernziele

Du begründest die Besonderheiten deines Tracks, ohne ein zweites, abweichendes Dockerfile aus der
Dokumentation zu kopieren.

## Voraussetzung

Die beiden gemeinsamen Lektionen in Modul 03. Referenz ist der
[ausführbare Dockerfile](../../../02-language-quickstart/java/Dockerfile).

## Übung

Prüfe die Maven-Parent-Version, Java-Version und den Namen des gepackten JARs.
Der Build führt `mvn verify` aus. Ein erfolgreiches Spring-Kontexttest-Ergebnis allein prüft noch nicht
HTTP-Vertrag, Portfreigabe oder Container-UID; dafür folgt der gemeinsame Containercheck.

Die Runtime braucht eine JRE, nicht zwingend ein vollständiges JDK. Bei Speicherlimits zählen
neben dem Java-Heap auch Metaspace, Threadstacks, direkte Buffer und weiterer nativer Speicher.
Ein Heap-Limit gleich dem gesamten Containerlimit lässt dafür keinen Spielraum.

Maven-Versionen sind explizit gewählt, ein Maven-POM ist jedoch kein universelles Lockfile.
Snapshots und dynamische Versionsbereiche sind hier nicht vorgesehen. Prüfe nach Aktualisierungen
Abhängigkeitsbaum, Anwendungstest und Containerverhalten.

Führe aus dem Repository-Wurzelverzeichnis den vollständigen Trackcheck aus:

```bash
python3 scripts/validate.py track --track java
```

Er startet ein eigenes Compose-Projekt, prüft den HTTP-Vertrag und die Laufzeitkonfiguration und
räumt nur dieses Testprojekt auf. Dockerzugriff ist erforderlich.

## Erfolgskontrolle

Du erklärst, welche Abhängigkeiten nur zum Bauen benötigt werden und welche beim Start vorhanden
sein müssen. Du kannst einen Buildfehler von einem Fehler beim Containerstart unterscheiden.

[Zurück zur Modulübersicht](../../shared-concepts/dockerfile-essentials-overview.md)
