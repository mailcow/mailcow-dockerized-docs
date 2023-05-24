## maildir_very_dirty_syncs

Dovecot's [`maildir_very_dirty_syncs`](https://wiki.dovecot.org/MailLocation/Maildir#Optimizations) Option ist seit mailcow Release 2023-05 standardmäßig aktiviert. Diese Option kann die Leistung von Postfächern, die sehr große Ordner (über 100.000 E-Mails) enthalten, erheblich verbessern.

Mit dieser Option wird vermieden, dass beim Laden einer E-Mail das gesamte `cur`-Verzeichnis erneut durchsucht wird. Wenn diese Option deaktiviert ist, geht Dovecot auf Nummer sicher und durchsucht das **gesamte** `cur`-Verzeichnis (vergleichbar mit dem Ausführen eines `ls`), um zu prüfen, ob diese bestimmte E-Mail berührt (umbenannt, etc.) wurde, indem es nach allen Dateien sucht, deren Namen die richtige ID enthalten. Dies ist sehr langsam, wenn das Verzeichnis groß ist, selbst auf Dateisystemen, die für solche Anwendungsfälle optimiert sind (wie ext4 mit aktiviertem `dir_index`) auf schnellen SSD-Laufwerken.

Diese Option ist sicher, solange Sie Dateien unter `cur` nicht manuell anfassen (da Dovecot die Änderungen dann möglicherweise nicht bemerkt). Auch wenn diese Option aktiviert ist, wird Dovecot Änderungen bemerken, wenn die mtime (last modified time) der Datei geändert wurde, aber ansonsten wird das Verzeichnis nicht gescannt und es wird einfach angenommen, dass der Index aktuell ist. Dies entspricht im Wesentlichen dem, was sdbox/mdbox tun, und mit dieser Option können Sie einen Teil der Leistungssteigerung erhalten, die mit sdbox/mdbox einhergehen würde, während Sie weiterhin maildir verwenden.

Diese Option ist bei einer Standard-mailcow-Installation sicher zu verwenden. Wenn Sie jedoch Tools von Drittanbietern verwenden, die manuell Dateien direkt im Maildir modifizieren (anstatt über IMAP), möchten Sie diese Option vielleicht deaktivieren. Um diese Option zu deaktivieren, [erstellen Sie eine data/conf/dovecot/extra.conf Datei](./u_e-dovecot-extra_conf.de.md) und fügen Sie diese Einstellung hinzu:

```ini
maildir_very_dirty_syncs=no
```

!!! warning "Achtung"
    Bitte nutzen Sie für eigene Anpassungen **IMMER**, die oben erwähnte [`extra.conf`](./u_e-dovecot-extra_conf.de.md), da Änderungen, welche in der normalen `dovecot.conf` geändert werden möglicherweise _nach einem Update vom GitHub Quellcode_ überschrieben werden.