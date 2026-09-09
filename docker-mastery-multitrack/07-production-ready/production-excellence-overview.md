# 07 – Betriebsverhalten prüfen

## Lernziele

Du prüfst Healthchecks, Stop-Signale, Ressourcenlimits und Laufzeitabhängigkeiten.
Richtwert: 60–90 Minuten. Der historische Ordnername `production-ready` ist keine Produktionsfreigabe.

## Voraussetzung

Module 00–06. Ein Runtime-Track funktioniert mit der gehärteten Compose-Konfiguration.

## Übung

1. [Health und Shutdown](01-health-checks-graceful-shutdown.md)
2. [Ressourcen](02-resource-management.md)
3. [Minimale Images](03-minimal-secure-images.md)

Untersuche jeweils einen konkreten Container. Notiere beobachtete Startzeit, UID, Speicherlimit
und Verhalten beim Stoppen. Vergleiche bei Bedarf einen zweiten Sprachtrack, ohne allgemeine
Geschwindigkeitsurteile aus einem einzelnen Lauf abzuleiten.

## Erfolgskontrolle

Du kannst belegen, dass der Prozess unter der vorgesehenen Konfiguration startet und stoppt,
und benennen, welche Tests vor einem produktiven Einsatz zusätzlich nötig wären: reale Last,
Abhängigkeiten, Wiederherstellung, Zugriffssteuerung und Hostbetrieb.

[Weiter: Monitoring](../08-monitoring-stack/monitoring-overview.md)
