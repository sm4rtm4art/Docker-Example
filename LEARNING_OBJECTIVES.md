# Lernziele und Bewertung

Die [Modulübersicht](docker-mastery-multitrack/docker-curriculum-guide.md) ist die zentrale Reihenfolge.
Wähle einen Sprachtrack. Verwende pro Modul diese Rubrik:

| Stufe | Beobachtbares Ergebnis |
| --- | --- |
| 0 – offen | Übung noch nicht bearbeitet oder Ergebnis nicht erklärbar |
| 1 – mit Hilfe | Beispiel funktioniert nach Anleitung; Begriffe teilweise erklärbar |
| 2 – selbstständig | Übung erneut ausführbar, Ergebnis und typischer Fehler erklärbar |
| 3 – Transfer | Eine begründete Änderung funktioniert; Nebenwirkungen werden benannt |

Ziel für den Kernpfad ist Stufe 2 in 00–07. Stufe 3 ist Vertiefung, keine Zugangshürde.

## Kompetenzen und Belege

| Module | Kompetenz | Praktischer Nachweis | Verständnisfrage |
| --- | --- | --- | --- |
| 00–01 | Daemon, Image und Container unterscheiden | Setup-Check und eigener Containerlebenszyklus | Warum beendet sich ein Container? |
| 02–03 | Anwendung bauen und konfigurieren | API-Vertrag grün, Cache-Experiment | Warum braucht Rust einen Builder, aber keinen Compiler im Runtime-Image? |
| 04 | Dienste verbinden und Daten erhalten | SQL-Verbindung per Servicename und Daten nach Neuerstellung | Warum rettet ein Volume keine Python-Liste? |
| 05 | Änderungen und Fehler untersuchen | Log, Konfiguration und HTTP-Beobachtung gemeinsam auswerten | Wann reicht ein Neustart, wann muss neu gebaut werden? |
| 06–07 | Schutzmaßnahmen und Betrieb beurteilen | UID, Schreibschutz, Health und Shutdown prüfen | Warum startet `unhealthy` allein keinen Container neu? |
| 08–09 | Beobachtbarkeit und Prüfung gestalten | Prometheus-Target und CI-Berichte auswerten | Was belegt `up=1`, und was bleibt unbewiesen? |
| 10–11 | Containerwissen übertragen | Pod ersetzen und Toolvergleich begründen | Warum teilen zwei Pods keinen Prozessspeicher? |

## Abschlussaufgabe

1. Baue deinen Track aus einem frischen Checkout.
2. Prüfe den vollständigen CRUD-Zyklus und weise die Laufzeit-UID nach.
3. Erzeuge und untersuche einen Portkonflikt, ohne fremde Container zu entfernen.
4. Zeige im Datenbanklabor, dass Daten eine Container-Neuerstellung überleben.
5. Erkläre Gauge, Healthcheck und Readiness anhand der vorhandenen Dateien.
6. Führe die relevanten CI-Prüfungen lokal aus und beschreibe mindestens zwei Grenzen der Tests.

Ein Mentor bewertet die Erklärung mit der Rubrik. In Selbstarbeit hältst du Vorhersage und Ergebnis
schriftlich fest. JSON-Berichte aus `scripts/api_contract.py --report reports/mein-test.json`
enthalten Testzahlen und Fehler; GitHub-Actions-Artefakte sind zeitlich begrenzt verfügbar.

## Fehler als Lernnachweis

Ein anfänglich roter Test ist kein schlechter Lernstand. Entscheidend ist, ob du eine Hypothese
formulierst, gezielt prüfst und die Ursache behebst. Notiere bei einer Korrektur den ursprünglichen
Fehler, den entscheidenden Befund und den erfolgreichen Nachtest.
