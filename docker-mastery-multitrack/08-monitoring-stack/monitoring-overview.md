# 08 – Monitoring mit Prometheus und Grafana

## Lernziele

Du verstehst einen Scrape, interpretierst Gauges und unterscheidest Erreichbarkeit von fachlicher
Gesundheit. Richtwert: 60–90 Minuten.

## Voraussetzung

Module 00–07. Beende das bisherige API-Labor, bevor du den Monitoring-Stack startest, da beide
standardmäßig Hostport 8080 verwenden. Plane zusätzlichen Speicher für drei Dienste ein.

## Übung

1. [Metrikgrundlagen](01-metrics-foundation.md)
2. [Den vollständigen Stack starten](02-complete-stack.md)

Prometheus-Konfiguration, Grafana-Datenquelle und Dashboard sind eingecheckt. Die API stellt
Bestandsmetriken für Aufgaben bereit; Anfragelatenzen und HTTP-Zähler sind ein Erweiterungsprojekt.

## Erfolgskontrolle

Du siehst `up{job="task-api"} = 1`, erkennst eine neu angelegte Aufgabe in `task_count` und kannst
einen API-Ausfall von einem erfolgreichen Scrape unterscheiden. Der automatisierte Monitoringcheck
prüft Target-Erreichbarkeit und Grafana-Health, nicht die visuelle Gestaltung des Dashboards.

[Weiter: CI und Lernkontrolle](../09-cicd-automation/cicd-overview.md)
