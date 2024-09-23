!!! danger "Vorsicht"
    Diese Anleitung befindet sich noch in Arbeit, Fehler können passieren! Nutzen Sie diese Funktion mit Bedacht!

!!! info "Hinweis"
    Diese Funktion ist ab mailcow-Versionen 2024-10 kompatibel. Ältere Versionen sind theoretisch ebenfalls in der Lage, die Funktion zu nutzen. Aufgrund interner Änderungen ist die Implementierung jedoch schwieriger.

## Vorwort
Dovecot unterstützt seit [geraumer Zeit](https://doc.dovecot.org/2.3/configuration_manual/lazy_expunge_plugin/) eine Funktion namens *Lazy Expunge*, welche es dem Serveradministrator ermöglicht, gelöschte E-Mails eines Benutzerkontos nach der eigentlichen Löschung zurückzuhalten.

mailcow besitzt eine ähnliche Funktion, die jedoch für Benutzer nicht so leicht zugänglich ist (siehe [Versehentlich gelöschte Daten wiederherstellen (Mail)](../../backup_restore/b_n_r-accidental_deletion.de.md#mail)) und eher als Fallback-Methode für Administratoren dient.

Mit der Dovecot-Option können Benutzer selbst als gelöscht markierte E-Mails einsehen und wiederherstellen, bevor diese dann automatisch vom Dovecot-Server gelöscht werden.

## Einrichtung

1. Bearbeiten Sie die `extra.conf` im Dovecot-Konfigurationsordner (in der Regel unter `MAILCOW_ROOT/data/conf/dovecot`) mit folgendem Inhalt:
    ```bash
    plugin {
        # Kopiere alle gelöschten Mails in die .EXPUNGED Mailbox
        lazy_expunge = .EXPUNGED

        # Als gelöscht markierte Mails von der Quota ausschließen
        quota_rule = .EXPUNGED:ignore
    }

    # Definiert die .EXPUNGED Mailbox
    namespace inbox {
        mailbox .EXPUNGED {
            # Definiert, wie lange Mails in diesem Ordner bleiben sollen, bevor sie gelöscht werden. 
            # Zeit wird definiert nach: https://doc.dovecot.org/2.3/settings/types/#time
            autoexpunge = 7days
            # Definiert, wie viele Mails maximal in der EXPUNGED Mailbox gehalten werden sollen, bevor diese geleert wird
            autoexpunge_max_mails = 100000
        }
    }
    ```

2. Starten Sie den Dovecot-Container neu:

    === "docker compose (Plugin)"

        ```bash
        docker compose restart dovecot-mailcow
        ```

    === "docker-compose (Standalone)"

        ```bash
        docker-compose restart dovecot-mailcow
        ```

3. Nun sollte, wenn der Papierkorb geleert wird, ein neuer Ordner mit dem Namen `.EXPUNGED` erscheinen. In diesem Ordner sind die E-Mails enthalten, die gemäß der in Schritt 1 definierten Regeln nach einer gewissen Zeit automatisch vom Server gelöscht werden.