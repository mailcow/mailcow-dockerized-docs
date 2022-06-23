## Automatische Aktualisierung

Ein Update-Skript in Ihrem mailcow-dockerized Verzeichnis kümmert sich um Updates.

Aber benutzen Sie es mit Bedacht! Wenn Sie denken, dass Sie viele Änderungen am mailcow-Code vorgenommen haben, sollten Sie die manuelle Update-Anleitung unten verwenden.

Führen sie das Update-Skript aus:
```
./update.sh
```

Wenn es nötig ist, wird es Sie fragen, wie Sie fortfahren möchten.
Merge-Fehler werden gemeldet.
Einige kleinere Konflikte werden automatisch korrigiert (zugunsten des mailcow-dockerized repository code).

### Optionen

```
# Optionen können kombiniert werden

# - Prüft auf Updates und zeigt Änderungen an
./update.sh --check

# - Starten Sie mailcow nicht, nachdem Sie ein Update durchgeführt haben
./update.sh --skip-start

# - Überspringt den ICMP Check auf die öffentlichen DNS Resolver (Bitte nur nutzen, wenn keinerlei ICMP Verbindungen von und zur mailcow erlaubt sind)
./update.sh --skip-ping-check

# - Überspringt den Docker-Compose Update Prozess, aktualisierung erfolgt dann vom Benutzer
./update.sh --no-update-compose

# - Erzwinge Update (unbeaufsichtigt, aber nicht unterstützt, Benutzung auf eigenes Risiko)
./update.sh --force

# - Garbage Collector ausführen, um alte Image-Tags zu bereinigen und beenden
./update.sh --gc

# - Update mit der Merge-Strategie-Option "ours" statt "theirs"
# Dies wird **Konflikte** beim Zusammenführen zugunsten Ihrer lokalen Änderungen lösen und sollte vermieden werden. Lokale Änderungen werden immer beibehalten, es sei denn, wir haben auch die Datei XY geändert.
./update.sh --ours

# - Nicht aktualisieren, nur holen von Docker Images
./update.sh --prefetch
```

### Ich habe vergessen, was ich vor dem Ausführen von update.sh geändert habe.

Siehe `git log --pretty=oneline | grep -i "before update"`, Sie werden eine Ausgabe ähnlich dieser haben:

```
22cd00b5e28893ef9ddef3c2b5436453cc5223ab Before update on 2020-09-28_19_25_45
dacd4fb9b51e9e1c8a37d84485b92ffaf6c59353 Before update on 2020-08-07_13_31_31
```

Führen Sie `git diff 22cd00b5e28893ef9ddef3c2b5436453cc5223ab` aus, um zu sehen, was sich geändert hat.

### Kann ich ein Rollback durchführen?

Ja.

Siehe das obige Thema, anstelle eines Diffs führen Sie checkout aus:

```
docker-compose down
# Ersetzen Sie die Commit-ID 22cd00b5e28893ef9ddef3c2b5436453cc5223ab durch Ihre ID
git checkout 22cd00b5e28893ef9ddef3c2b5436453cc5223ab
docker-compose pull
docker-compose up -d
```

### Hooks

Sie können sich in den Update-Mechanismus einklinken, indem Sie Skripte namens `pre_commit_hook.sh` und `post_commit_hook.sh` zu Ihrem mailcows-Root-Verzeichnis hinzufügen. Siehe [hier](../manual-guides/u_e-update-hooks.md) für weitere Details.

## Update-Zyklus

- Wir planen an jedem ersten Dienstag eines Monats ein neues Hauptupdate zu veröffentlichen.
- Die Updates sind wie folgt nummeriert: `JJJJ-MM` (Beispiel: `2022-05`).
- Fehlerkorrekturen eines Hauptupdates werden bei uns als "Revisionen" wie a,b,c (Beispiele: `2022-05a`, `2022-05b` usw.) erscheinen.
