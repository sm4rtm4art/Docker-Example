# Validierung und Pflege

Für den Lernbeginn siehe [Modul 00](docker-mastery-multitrack/00-prerequisites/prerequisites-overview.md).
Diese Seite beschreibt Änderungen am Repository. Alle Befehle starten im Wurzelverzeichnis.

## Voraussetzungen

Python 3.12+, Git, Docker mit Linux-Containern und Compose mit `up --wait`.
Java- und Rust-Builds erfolgen im Container. Die normale CI verwendet Ubuntu 24.04; andere
Betriebssysteme und Architekturen sind nicht durch diesen einzelnen Runner abgedeckt.

```bash
python3 -m venv .venv-ci
. .venv-ci/bin/activate
python -m pip install -r requirements-ci.txt
python scripts/validate.py static
```

Optional kann pre-commit installiert werden. Die Konfiguration führt denselben Static-Check aus;
sie prüft alle Kursdateien und nicht nur die erste an einen Hook übergebene Datei.

## Prüfungen vor einem Pull Request

```bash
python3 scripts/validate.py static
python3 scripts/validate.py configs
python3 scripts/validate.py track --track python
python3 scripts/validate.py track --track rust
python3 scripts/validate.py track --track java
python3 scripts/validate_dev.py --track python
python3 scripts/validate_dev.py --track rust
python3 scripts/validate.py database
python3 scripts/validate.py monitoring --track python
```

Bei Änderungen am gemeinsamen Vertrag alle Tracks prüfen. Bei einem reinen Textfehler genügen
Syntax und lokale Links; keine Behauptung, dass damit Container ausgeführt wurden.
Die automatischen Containerchecks erzeugen eigene Projekte und freie Hostports. Sie löschen deren
Testvolumes, aber nicht die interaktiven Kursprojekte. `reports/` enthält Testberichte und Logs.

kind bleibt optional: `python3 scripts/validate_kind.py --track python` benötigt kind und kubectl.
Der separate Workflow `kind.yml` kann nach Aufnahme des Workflows in den Standardbranch manuell
auf dem gewünschten Branch gestartet werden. Reguläre PR-Prüfungen benötigen kein Kubernetes.

## Abhängigkeiten aktualisieren

- Python: `pyproject.toml` ändern, `uv lock` im Track ausführen, `uv sync --locked` prüfen.
  Den Requirements-Export dort mit `uv export --locked --no-dev --no-emit-project --output-file requirements.txt`
  aktualisieren. Keine unabhängige Bearbeitung des Exports.
- Rust: Manifeständerungen und `cargo update` bewusst durchführen, `Cargo.lock` einchecken;
  anschließend Build mit `--locked` und HTTP-Vertrag prüfen.
- Java: Parent-/Abhängigkeitsversion und bei Bedarf JDK/JRE gemeinsam pflegen. `mvn verify`
  und Runtime-Vertrag prüfen.
- Images: Versions-Tags prüfen, Unterstützungsstatus des Betriebssystems beachten und neu bauen.
  Tags sind veränderlich; Digest-Pinning ist ein weiterführender Wartungsschritt.
- Actions: Commit-SHA und Versionskommentar zusammen aktualisieren. Berechtigungen möglichst klein halten.

Dependabot schlägt Updates vor. Ein automatisch erzeugter PR ersetzt keine Kompatibilitätsprüfung.
Nach Python-Updates bleibt der generierte Requirements-Export zu kontrollieren. Der Security-Workflow
liefert einen beratenden Repository-Scan; vor einer realen Veröffentlichung zusätzlich die tatsächlich
gebauten Images prüfen und eine Befundpolitik festlegen.

## Dokumentationsregeln

Arbeitsordner, Voraussetzung, beobachtbares Ergebnis und Aufräumen gehören zu jeder praktischen Übung.
Linke echte Dateien, statt abweichende Dockerfiles in Markdown zu duplizieren. Kennzeichne Konzepte
und Erweiterungen als solche. Halte `curriculum.json` und den kanonischen
[Lernpfad](docker-mastery-multitrack/docker-curriculum-guide.md) bei Strukturänderungen konsistent.

Neue Texte bleiben sachlich und ohne dekorative Emojis. Quellen sollen Primärdokumentationen sein.
Eine Aussage wie „getestet“ braucht einen konkreten Lauf, Commit und benannte Umgebung.
