# Metriken: messen, ohne mehr zu behaupten als bekannt ist

## Lernziele

Du unterscheidest Gauge, Counter und Histogramm und ordnest die tatsächlich implementierten Werte zu.

## Voraussetzung

Eine laufende API aus einem Track. Befehle starten im Repository-Wurzelverzeichnis.

## Konzept

Ein Gauge beschreibt einen aktuellen Wert, der steigen und sinken kann. Ein Counter beschreibt
kumulierte Ereignisse und steigt bis zu einem möglichen Prozessneustart. Ein Histogramm aggregiert
Beobachtungen, etwa Dauern, in Buckets sowie Summe und Anzahl.

Die Kurs-API stellt drei Gauges bereit: `task_count`, `task_completed_count` und `task_pending_count`.
Ein Löschen senkt den Aufgabenbestand. Deshalb wäre `tasks_total` als Counter hier fachlich falsch.
Die Metriken werden pro Prozess berechnet; mehrere Replikate hätten getrennte Speicherstände.

## Übung

```bash
curl --fail http://127.0.0.1:8080/metrics
curl --fail -X POST http://127.0.0.1:8080/api/tasks -H 'Content-Type: application/json' -d '{"title":"Monitoring verstehen"}'
curl --fail http://127.0.0.1:8080/metrics
```

Erwartet: `task_count` und `task_pending_count` steigen um eins. Speichere die ID der Aufgabe und
lösche sie nach dem Versuch; der Bestand fällt wieder. Die Antwort muss echter Text sein, kein
JSON-kodierter String mit Anführungszeichen und Escape-Sequenzen.

Mit dem folgenden [Stack](02-complete-stack.md) übernimmt Prometheus den regelmäßigen Abruf.
`up` wird dabei von Prometheus erzeugt: 1 bedeutet erfolgreicher Scrape, 0 ein fehlgeschlagener
Scrape. Es ist kein automatisch vollständiger Bereitschaftstest der Geschäftslogik.

### Transferfrage

Wie würdest du künftig HTTP-Latenzen messen? Instrumentiere echte Anfragen mit einem Histogramm
und verwende begrenzte Labels wie Route und Methode. Konkrete Task-IDs oder Benutzerkennungen als
Label erzeugen viele Zeitreihen und können sensible Daten verbreiten. Eine `rate`-Abfrage auf dem
aktuellen Aufgabenbestand wäre keine korrekte Anfragerate.

## Erfolgskontrolle

Du kannst den Metriktyp für Bestand, Request-Anzahl und Request-Dauer begründen. Du erklärst,
warum ein zurückgesetzter Prozessspeicher in diesem Kurs kein Persistenzfehler des Monitorings ist.

Quellen: [Prometheus-Metriktypen](https://prometheus.io/docs/concepts/metric_types/),
[Metriknamen und Labels](https://prometheus.io/docs/practices/naming/).
