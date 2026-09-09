# 06 – Container-Sicherheit mit überprüfbaren Maßnahmen

## Lernziele

Du unterscheidest Build-, Laufzeit- und Hostschutz und prüfst jede Maßnahme gegen ein konkretes Risiko.
Richtwert: 60–90 Minuten.

## Voraussetzung

Module 00–05. Die Anwendungen sind lokale Lern-APIs ohne Authentifizierung.

## Übung

Bearbeite die [Sicherheitsgrundlagen](01-security-fundamentals.md). Weise UID, Schreibschutz,
Capabilities und erlaubte temporäre Schreibzugriffe nach. Erkläre für jede Einstellung, was sie
begrenzt und welchen Angriffsweg sie nicht abdeckt.

## Erfolgskontrolle

`python3 scripts/validate.py track --track python` (oder dein Track) prüft die tatsächlich gestartete
Konfiguration. Du kannst erläutern, warum ein Non-Root-Prozess weder Rootless Docker noch eine
vollständige Absicherung des Docker-Hosts bedeutet.

[Weiter: Betriebsverhalten](../07-production-ready/production-excellence-overview.md)
