# Prüf- und Aufräumskripte

Alle Befehle im Repository-Wurzelverzeichnis. Python 3.12+ ist erforderlich.

| Befehl | Wirkung |
| --- | --- |
| `python3 scripts/validate.py static` | Syntax, lokale Links, Lernstruktur; benötigt PyYAML |
| `python3 scripts/validate.py configs` | Compose-Konfigurationen auflösen |
| `python3 scripts/validate.py track --track python` | Isolierter Runtime-Check; auch Rust/Java |
| `python3 scripts/validate_dev.py --track python` | Echte Dev-Konfiguration; auch Rust |
| `python3 scripts/validate.py database` | DNS, SQL und Persistenz prüfen |
| `python3 scripts/validate.py monitoring` | API, Prometheus und Grafana prüfen |
| `python3 scripts/validate_kind.py --track python` | Optionales isoliertes kind-Labor |
| `python3 scripts/api_contract.py` | Sieben HTTP-Tests gegen die laufende lokale API |

## Interaktive Kursprojekte aufräumen

```bash
python3 scripts/cleanup.py api
python3 scripts/cleanup.py database
python3 scripts/cleanup.py monitoring
```

Die Skripte entfernen nur die fest benannten Projekte `docker-learning`, `docker-learning-db`
und `docker-learning-monitoring`. Named Volumes bleiben standardmäßig erhalten.
`--delete-data` löscht ausdrücklich die Volumes des gewählten Kursprojekts. Verwende diese
Projektnamen deshalb nur für den Kurs.

Tracklokale Starts mit `docker compose up` haben andere Projektnamen und werden im jeweiligen
Trackordner mit `docker compose down` beendet. Die automatischen Validierungen erzeugen eigene
zufällige Projektnamen und räumen sie selbst auf, einschließlich ihrer Testvolumes.

Die alten Einstiegsskripte `run-cleanup.sh`, `docker-cleanup-v2.sh` und `docker-cleanup.ps1`
leiten nur noch an `cleanup.py` weiter. Alte globale Optionen werden nicht unterstützt;
`python3 scripts/cleanup.py --help` zeigt die zulässigen Parameter.

## Fehlerberichte

Prüfungen liefern bei einem Fehler einen Exitcode ungleich 0. Logs und HTTP-Testberichte liegen
unter `reports/`. Fehlender Dockerzugriff ist ein nicht ausgeführter Containercheck, kein Erfolg.
Die vollständige Prüfbedeutung steht in [Modul 09](../docker-mastery-multitrack/09-cicd-automation/cicd-overview.md).
