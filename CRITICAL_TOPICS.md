# Fachliche Stolperstellen

Diese Übersicht verweist auf die vertieften Lektionen und dient als Wiederholung.

| Aussage | Korrekte Einordnung | Lektion |
| --- | --- | --- |
| „Ein Container ist eine kleine VM“ | Er isoliert Prozesse und teilt einen Kernel; Desktop kann dafür eine VM verwenden | [01](docker-mastery-multitrack/01-docker-fundamentals/docker-fundamentals-overview.md) |
| „EXPOSE öffnet den Port“ | Hostfreigaben entstehen durch Laufzeitkonfiguration | [03](docker-mastery-multitrack/03-dockerfile-essentials/shared-concepts/01-dockerfile-fundamentals.md) |
| „depends_on bedeutet bereit“ | Nur mit passender Bedingung wird auf Health gewartet | [04](docker-mastery-multitrack/04-docker-compose/01-compose-basics.md) |
| „Ein Volume macht die API persistent“ | Nur tatsächlich im Volume gespeicherte Daten bleiben erhalten | [Volumes](docker-mastery-multitrack/04-docker-compose/03-compose-volumes.md) |
| „Named Volumes haben keine Rechteprobleme“ | UID/GID, Initialisierung und Mountziel bleiben relevant | [Dateirechte](docker-mastery-multitrack/common-resources/VOLUMES_AND_PERMISSIONS_GUIDE.md) |
| „Non-root bedeutet rootless“ | Prozessbenutzer und Daemonbetrieb sind verschiedene Ebenen | [06](docker-mastery-multitrack/06-security-best-practices/01-security-fundamentals.md) |
| „Unhealthy startet automatisch neu“ | Docker-Healthstatus allein bewirkt keinen Standalone-Neustart | [07](docker-mastery-multitrack/07-production-ready/01-health-checks-graceful-shutdown.md) |
| „Aufgabenanzahl ist ein Counter“ | Ein sinkender Bestand ist ein Gauge | [08](docker-mastery-multitrack/08-monitoring-stack/01-metrics-foundation.md) |
| „Grüne CI beweist Verständnis“ | Funktion und Erklärung benötigen unterschiedliche Belege | [09](docker-mastery-multitrack/09-cicd-automation/cicd-overview.md) |
| „Mehr Replikate teilen automatisch Daten“ | Die Kurs-API hält getrennten Prozessspeicher | [10](docker-mastery-multitrack/10-orchestration-intro/orchestration-preview.md) |
