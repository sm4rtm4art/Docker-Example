# Docker und Podman vergleichen

Der fachliche Vergleich ist in [Modul 11](../docker-mastery-multitrack/11-beyond-docker/container-alternatives-overview.md)
beschrieben. Ein OCI-kompatibles Image erleichtert den Wechsel, ersetzt aber keinen Laufzeittest.

Prüfe bei einem eigenen Portierungsversuch mindestens Netzwerk/DNS, Hostportbindung, UID-Mapping,
Mountrechte und den gemeinsamen HTTP-Vertrag. Die normale CI dieses Repositorys verwendet Docker;
sie bestätigt keine pauschale Podman-Kompatibilität.
