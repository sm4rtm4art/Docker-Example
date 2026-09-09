# 05 – Entwicklungsworkflow und Fehlersuche

## Lernziele

Du unterscheidest Source-Mount, Reload, Neustart und Neubuild und diagnostizierst Fehler anhand
von Konfiguration, Logs und HTTP-Verhalten. Richtwert: 45–60 Minuten.

## Voraussetzung

Ein funktionierender Track, Module 00–04. Beende vorher das Root-API-Labor, um Portkonflikte zu vermeiden.

## Übung

1. [Änderungen im Container](01-hot-reload-development.md)
2. [Container systematisch debuggen](02-debugging-containers.md)
3. [Editor und Terminal verbinden](03-ide-integration.md)

Python und Rust besitzen separate Entwicklungsdateien. Python lädt Source-Änderungen automatisch neu;
Rust kompiliert nach einem expliziten Neustart. Java verwendet hier einen Neubuild. Diese Unterschiede
sind bewusst beschrieben und nicht unter einer pauschalen Hot-Reload-Zusage versteckt.

## Erfolgskontrolle

Du kannst eine sichtbare Änderung durch den jeweiligen Entwicklungsweg bis zur HTTP-Antwort verfolgen
und erklären, weshalb eine Abhängigkeitsänderung anders behandelt werden muss.

[Weiter: Sicherheit](../06-security-best-practices/security-overview.md)
