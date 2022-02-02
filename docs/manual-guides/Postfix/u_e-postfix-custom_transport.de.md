Für Transport maps, die nicht in mailcow UI konfiguriert werden, verwenden Sie bitte `data/conf/postfix/custom_transport.pcre`, um zu verhindern, dass bestehende Maps oder Einstellungen durch Updates überschrieben werden.

In den meisten Fällen ist die Verwendung dieser Datei **nicht** notwendig. Bitte vergewissern Sie sich, dass mailcow UI nicht in der Lage ist, den gewünschten Datenverkehr richtig zu routen, bevor Sie diese Datei verwenden.

Die Datei benötigt gültigen PCRE-Inhalt und kann Postfix zerstören, wenn sie falsch konfiguriert ist.