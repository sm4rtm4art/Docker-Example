# 09 – CI als technische Lernkontrolle

## Lernziele

Du führst dieselben Prüfungen lokal und in GitHub Actions aus, liest Fehlerberichte und
unterscheidest technische Funktion von nachgewiesenem Verständnis. Richtwert: 45–60 Minuten.

## Voraussetzung

Module 00–08. Python 3.12+ und Docker mit Compose; für die Syntaxprüfung zusätzlich
`python3 -m pip install -r requirements-ci.txt` in einer eigenen virtuellen Umgebung.

## Übung

Alle Befehle starten im Repository-Wurzelverzeichnis:

```bash
python3 scripts/validate.py static
python3 scripts/validate.py configs
python3 scripts/validate.py track --track python
python3 scripts/validate.py database
python3 scripts/validate.py monitoring --track python
```

Ersetze den Track bei Bedarf. Development-Images für Python und Rust haben zusätzlich
`python3 scripts/validate_dev.py --track python` bzw. `--track rust`.

| Prüfung | Was sie nachweist | Was sie nicht nachweist |
| --- | --- | --- |
| Static | Syntax, lokale Markdown-Ziele, Modulstruktur | Richtigkeit jeder erklärenden Aussage oder externe Linkverfügbarkeit |
| Compose config | Gültige aufgelöste Konfiguration | Erfolgreichen Imagebau oder Dienststart |
| Track | Build, sieben HTTP-Tests, UID, Schreibschutz, Stop/Start | Lastverträglichkeit oder unterbrechungsfreie Langzeitanfragen |
| Database | DNS/SQL und Daten nach Container-Neuerstellung | Persistenz der Task API oder getestetes Backup-Restore |
| Monitoring | API-Vertrag, Prometheus-Target und Grafana-Health | Dashboard-Bildqualität oder vollständige Alarmierung |
| Trivy-Bericht | Erkannte Repository-Abhängigkeiten und mögliche Secrets | Vollständige Prüfung aller Runtime-Imagepakete oder eine Sicherheitsfreigabe |

Öffne [.github/workflows/validate.yml](../../.github/workflows/validate.yml). Pull Requests,
Pushes auf `main` und ein manueller Start führen die Prüfungen aus. Builds finden auf einem
Linux-Runner statt, ohne Images zu veröffentlichen. `permissions: contents: read`, an Commit-SHAs
gebundene Actions und deaktiviertes Persistieren von Checkout-Credentials begrenzen CI-Zugriffe.
Es wird kein `pull_request_target` verwendet, um ungeprüften PR-Code mit erhöhten Rechten auszuführen.

### Einen Fehler bewusst erkennen

Ändere in einer eigenen Übungskopie den Health-Pfad oder einen lokalen Markdown-Link.
Führe den passenden Test aus, lies den ersten konkreten Fehler und behebe ihn. Ein Linkfehler
gehört in den Static-Check; eine falsche HTTP-Antwort in den API-Vertragstest.

Die Checks erzeugen eindeutige Projektnamen und entfernen nur ihre eigenen Ressourcen. JSON-
Testberichte und Logs liegen unter `reports/` und werden als Actions-Artefakte 14 Tage bereitgestellt.
Der Security-Job ist beratend: Ein abgeschlossener Job kann Befunde enthalten; prüfe `security-report`.
Ein verbindliches Release-Gate benötigt eine abgestimmte Befund- und Ausnahmepolitik.

## Erfolgskontrolle

Du kannst für jeden Fehler den passenden Check auswählen und erläutern, was ein grüner Lauf beweist.
Dokumentiere deinen Lernstand mit der [Rubrik](../../LEARNING_OBJECTIVES.md): Vorhersage,
Beobachtung, Erklärung und gegebenenfalls Transfer. CI bewertet diese Erklärung nicht selbstständig.

## Weiter

[Optional: kind](../10-orchestration-intro/orchestration-preview.md).
Für spätere Vertiefung eignen sich Image-Scans, Digest-Pinning, SBOMs und geprüfte Registry-Publikation;
sie sind keine Voraussetzung für das Bestehen des Grundkurses.

Quelle: [Sicherheit für GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions).
