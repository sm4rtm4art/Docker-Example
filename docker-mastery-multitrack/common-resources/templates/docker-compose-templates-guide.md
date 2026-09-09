# Ausführbare Compose-Dateien

| Einstiegspunkt | Verwendung |
| --- | --- |
| [compose.lab.yml](../../../compose.lab.yml) | Gemeinsame Runtime für den gewählten Track |
| [docker-compose.database.yml](docker-compose.database.yml) | Eigenständiges SQL-, Netzwerk- und Persistenzlabor |
| [compose.monitoring.yml](../../../compose.monitoring.yml) | Ergänzung zum Root-API-Labor für Prometheus/Grafana |

Compose löst relative Pfade bei zusammengeführten Dateien relativ zur ersten Compose-Datei auf.
Deshalb liegen die beiden kombinierbaren Dateien im Repository-Wurzelverzeichnis. Die
Datenbankdatei wird eigenständig verwendet. Fehlende Konfigurationsdateien sollen nicht durch
Platzhalterverzeichnisse oder verdeckte Annahmen ersetzt werden.

Vollständige Befehle und Aufräumen stehen in [Modul 04](../../04-docker-compose/compose-overview.md)
und [Modul 08](../../08-monitoring-stack/02-complete-stack.md).
Die frühere doppelte Monitoringvorlage wurde zugunsten dieser einen ausführbaren Konfiguration entfernt.
