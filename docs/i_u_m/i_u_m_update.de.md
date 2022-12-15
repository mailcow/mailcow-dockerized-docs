## mailcow automatisch Updaten

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

# - Wechselt die Update Quellen der mailcow auf nightly (unstabile) Inhalte.
NUR ZUM TESTEN VERWENDEN!! KEIN PRODUKTIV BETRIEB!!!
./update.sh --nightly

# - Wechselt die Update Quellen der mailcow auf stable (stabile) Inhalte (standard).
./update.sh --stable

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
=== "docker compose (Plugin)"

    ``` bash
    docker compose down
    # Ersetzen Sie die Commit-ID 22cd00b5e28893ef9ddef3c2b5436453cc5223ab durch Ihre ID
    git checkout 22cd00b5e28893ef9ddef3c2b5436453cc5223ab
    docker compose pull
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
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

## Update-Varianten

**stable (stabile Updates)**: Diese Updates sind für den Produktivbetrieb geeignet. Sie erscheinen in einem Zyklus von mindest 1x im Monat.

**nightly (instabile Updates)**: Diese Updates sind **NICHT** für den Produktivbetrieb geeignet und dienen lediglich dem Testen. Die nightly Updates sind den stabilen Updates vorraus, da in diesen neue und auch umfangreichere Funktionen getestet werden bevor diese für alle User Live gehen.

## NEU: Nightly Updates beziehen
### Infos zu den Nightly Updates
Seit dem 2022-08 Update gibt es die Möglichkeit die Update quellen zu ändern. Bisher diente der master Branch auf GitHub als einzige (offizieller) Update Quelle. Mit dem August 2022 Update gibt es aber nun noch den Nightly Branch welcher instabile und größere Änderungen zum testen und Feedback geben enthält.

Dabei bekommt der Nightly Branch immer dann neue Updates, wenn irgendetwas am mailcow Projekt fertig gemacht wurde was in die neue Hauptversion reinkommt.

Neben den offensichtlichen neuerungen welche sowieso im nächsten Major Update enthalten sein werden enthält er ebenfalls erstmal exklusive Features welche eine längere Testzeit brauchen (bspw. das UI Update auf Bootstrap 5).

### Wie bekomme ich Nightly Updates?
Der Vorgang ist relativ simpel. Mit dem 2022-08 Update (ein Update auf die Version voraussgesetzt) ist es möglich die `update.sh` mit dem Parameter `--nightly` zu starten.

!!! danger "Achtung"
        Bitte machen Sie vorher ein Backup oder folgen Sie dem Abschnitt [Best Practice Nightly Update](#best-practice-nightly-update) bevor Sie auf die Nightly Builds von mailcow wechseln. Wir sind für keinerlei Datenverluste/korruptionen verantwortlich, also arbeiten Sie mit bedacht!

Das Skript wird nun den Branch wechseln mit `git checkout nightly` d.h. es wird auch wieder nach den IPv6 Einstellungen fragen. Das ist aber normal.

Sollte alles problemlos geklappt haben (wofür wir ja auch vorsichtshalber ein Backup vorher gemacht haben) sollte nun in der mailcow UI unten rechts die aktuelle Versionsnummer samt Datumsstempel abgebildet sein: <br>
![nightly footer](../assets/images/i_u_m/nightly_footer.png)

### Best Practice Nightly Update
!!! info
        Wir empfehlen die Benutzung des Nightly Updates nur dann, wenn Ihr eine weitere Maschine oder VM besitzt und diese **NICHT** Produktiv nutzt.

1. Das [Cold-Standby Skript](../backup_restore/b_n_r-coldstandby.de.md) nutzen um die Maschine **vor** dem Schwenk auf die Nightly Builds auf ein anderes System zu kopieren.
2. Das `update.sh` Skript auf der neuen Maschine mit dem Parameter `--nightly` ausführen und bestätigen.
3. Die Nightly Updates auf der sekundären Maschine erleben/testen.
