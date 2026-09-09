# Editor und Container-Workflow verbinden

## Lernziele

Du integrierst die funktionierenden Terminalbefehle in deinen Editor, ohne eine neue Betriebsumgebung
als Voraussetzung für den Kurs einzuführen.

## Voraussetzung

Ein beliebiger Editor; die Entwicklungsübung dieses Moduls funktioniert bereits im Terminal.

## Übung

Öffne das Repository als Projekt. Verwende ein integriertes Terminal für Compose und ein zweites
für HTTP-Tests. Trage als Arbeitsverzeichnis explizit den Trackordner oder das Repository-Wurzelverzeichnis
ein, passend zum jeweiligen Befehl. Speichere eine Änderung und beobachte Build-/Reload-Logs.

Python-Sprachanalyse kann ein lokal erzeugtes Virtualenv verwenden. Rust-Analyse benötigt für volle
Funktion einen lokalen Rust-Toolchain oder eine bewusst konfigurierte Entwicklungsumgebung. Java-
Analyse benötigt einen passenden JDK. Das sind Editoranforderungen, keine Voraussetzungen für den
reinen Docker-Buildpfad.

Setze zunächst keinen Remote-Debug-Port frei. Wenn du später JDWP oder debugpy ergänzt, verwende
eine separate Dev-Konfiguration, lokale Bindung und entferne sie aus Runtime-Images.
Ein Debugger kann weitreichenden Zugriff auf den Prozess erlauben.

## Erfolgskontrolle

Du kannst denselben Build und Test auch außerhalb der IDE ausführen. Ein Teammitglied benötigt
keine nicht dokumentierte persönliche Editor-Konfiguration, um deine Änderung zu reproduzieren.

## Aufräumen

Beende den Entwicklungsstack wie in der vorigen Lektion. Persönliche IDE-Dateien müssen nicht
in das Repository aufgenommen werden.
