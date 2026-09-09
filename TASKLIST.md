# Erweiterungsvorschläge und Abnahmekriterien

Diese Liste beschreibt zusätzliche Arbeit. Sie ist keine Behauptung bereits implementierter Funktionen.
Der aktuelle Kurs kann mit einem Sprachtrack durchlaufen werden.

| Priorität | Erweiterung | Konkrete Abnahme |
| --- | --- | --- |
| 1 | Persistente Task API in allen Tracks | Gemeinsamer HTTP-Vertrag; Aufgaben überleben API-Neustart; Migrationen und Datenbankausfall getestet |
| 1 | Backup und Restore | Dump in getrennte Datenbank zurückspielen; Datenintegrität automatisch prüfen |
| 1 | Image-Sicherheit als verbindliches Gate | Tatsächlich gebaute Images scannen; Schweregrad-, Ausnahmen- und Updatepolitik dokumentieren |
| 2 | Digest-Pinning / SBOM | Basis-Digests gepflegt, Abhängigkeitsinventar pro Commit, reproduzierbare Nachweise |
| 2 | HTTP-Instrumentierung | Echte Request-Counter und Latenzhistogramme; begrenzte Route-Labels; Expositionsprüfung |
| 2 | Negative Betriebsfälle | Shutdown während laufender Anfrage, Readiness bei Datenbankausfall, Wiederanlauf |
| 2 | ARM64 und Plattformprüfung | Eigene Laufzeitchecks statt bloßem Cross-Build; dokumentierte Linux-/Desktop-Matrix |
| 3 | Kubernetes-Vertiefung | Persistente Datenhaltung, Rollout-/Rollback-Test und bewusst gewähltes Netzwerkmodell |
| 3 | Persönliches Lernportfolio | Selbstbewertung mit Belegen und Mentorfeedback; getrennt von technischen CI-Ergebnissen |

## Persistente API als nächstes größeres Projekt

Behalte `/api/tasks` und das JSON-Modell bei. Wähle je Sprache eine gut gewartete Datenbankbibliothek,
führe Schemaänderungen versioniert aus und speichere UTC-Zeitstempel. Prüfe konkurrierende Updates,
Verbindungsfehler und Wiederholungsstrategien. Separiere eine Readiness-Prüfung von einer einfachen
Liveness-Prüfung. Die Umgebungsvariable für eine Datenbankverbindung ist erst dann dokumentierte
Konfiguration, wenn die Anwendung sie wirklich auswertet.

## kind bewusst begrenzen

Das optionale Modul 10 reicht für den ersten Transfer. Helm, Ingress, Service Mesh und ein dauerhaft
betriebener Cluster würden den Docker-Grundkurs deutlich erweitern. Ergänze sie erst mit einem
konkreten Lernziel und eigenem Testlabor.
