# Diagnoseaufgaben mit Musterlösungen

Arbeite in einer eigenen Übungskopie. Notiere vor jedem Test eine Hypothese. Prüfe anschließend
mit der kleinsten passenden Beobachtung. Keine Aufgabe benötigt globale Prune-Befehle.

## 1. Die API ist „weg“, aber der Container läuft

Beobachtung: Du hast `TASK_API_PORT=8082` gesetzt und fragst Port 8080 ab.
Aufgabe: Belege den tatsächlichen Hostport und prüfe `/health` dort.

<details>
<summary>Musterlösung</summary>

`docker compose -p docker-learning -f compose.lab.yml ps` zeigt die Freigabe.
Der Hostport ist 8082, der Prozessport bleibt 8080. Ein Neubuild des Anwendungscodes behebt
keinen falsch gewählten Clientport.

</details>

## 2. Die Datenbank ist gestartet, aber die Taskliste verschwindet

Beobachtung: Das SQL-Labor behält seinen Datensatz, die API verliert Aufgaben beim Neustart.
Aufgabe: Erkläre beide Ergebnisse anhand des Codes und der Mounts.

<details>
<summary>Musterlösung</summary>

Die API verwendet ausschließlich Prozessspeicher. PostgreSQL schreibt im getrennten Labor
in ein Named Volume. Die bloße Existenz einer Datenbank oder einer `DATABASE_URL`-Variable
integriert sie nicht in die Anwendung.

</details>

## 3. Ein Schreibtest schlägt fehl

Beobachtung: `touch /app/example` meldet einen Fehler, `touch /tmp/example` funktioniert.
Aufgabe: Entscheide, ob ein Defekt vorliegt.

<details>
<summary>Musterlösung</summary>

In der Runtime-Konfiguration ist das gewollt: read-only Rootdateisystem, beschreibbares tmpfs
für temporäre Daten. Prüfe Benutzer und Mounts, bevor du Berechtigungen erweiterst.

</details>

## 4. Prometheus zeigt erfolgreiche Scrapes, aber Aufgaben fehlen

Beobachtung: `up=1`, `task_count=0` nach einem Neustart.
Aufgabe: Welche Aussage beweist jede Metrik?

<details>
<summary>Musterlösung</summary>

`up=1` belegt einen erfolgreichen Scrape. Der Aufgabenbestand ist separat und nach dem Neustart
des In-Memory-Prozesses tatsächlich leer. Ein Gauge darf sinken.

</details>

## 5. Die Rust-Änderung ist nicht sichtbar

Beobachtung: Source ist im Dev-Container gemountet, aber der Prozess läuft weiter.
Aufgabe: Prüfe den konfigurierten Startbefehl und wähle den notwendigen Schritt.

<details>
<summary>Musterlösung</summary>

Der Entwicklungscontainer verwendet `cargo run --locked`, keinen Watcher. Ein Neustart führt
den Build erneut aus. Bei einer Manifeständerung muss das Image neu gebaut werden.

</details>

Bewerte deine Erklärung mit der [Lernrubrik](../../LEARNING_OBJECTIVES.md).
