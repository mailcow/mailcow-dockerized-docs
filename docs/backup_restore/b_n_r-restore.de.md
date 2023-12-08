### Wiederherstellung

Bitte kopieren Sie dieses Skript nicht an einen anderen Ort.

Um eine Wiederherstellung durchzuführen, **starten Sie mailcow**, verwenden Sie das Skript mit "restore" als ersten Parameter.

```
# Syntax:
# ./helper-scripts/backup_and_restore.sh restore

```

Das Skript wird Sie nach einem Speicherort für die Sicherung der mailcow_DATE-Ordner fragen.

!!! danger "Achtung"
    Bei der Wiederherstellung von einem Backup einer anderen Architektur auf die neue Architektur **MUSS** das Rspamd-Backup bei der Wiederherstellung weggelassen werden, da es inkompatible Daten enthält, die zu Abstürzen von Rspamd und anschließendem Nichtstart von mailcow aufgrund des Architekturwechsels führen.