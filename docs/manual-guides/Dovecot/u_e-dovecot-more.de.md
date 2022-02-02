Hier ist nur eine unsortierte Liste von nützlichen `doveadm`-Befehlen, die nützlich sein könnten.

## doveadm quota

Die Befehle `quota get` und `quota recalc`[^1] werden verwendet, um die Quota-Nutzung des aktuellen Benutzers anzuzeigen oder neu zu berechnen. Die angezeigten Werte sind in *Kilobytes*.

Um den aktuellen Quota-Status für einen Benutzer / eine Mailbox aufzulisten, tun Sie folgendes:

```
doveadm quota get -u 'mailbox@example.org'
```

Um den Quota-Speicherwert für **alle** Benutzer aufzulisten, tun Sie folgendes:

```
doveadm quota get -A |grep "STORAGE"
```

Berechnen Sie die Quota-Nutzung eines einzelnen Benutzers neu:

```
doveadm quota recalc -u 'mailbox@example.org'
```

## doveadm search

Der Befehl `doveadm search`[^2] wird verwendet, um Nachrichten zu finden, die Ihrer Anfrage entsprechen. Er kann den Benutzernamen, die Mailbox-GUID / -UID und die Nachrichten-GUIDs / -UIDs zurückgeben.

Um die Anzahl der Nachrichten im **.Trash** Ordner eines Benutzers zu sehen:

```
doveadm search -A mailbox 'Trash' | awk '{print $1}' | sort | uniq -c
```

Alle Nachrichten im **Postfach** eines Benutzers anzeigen, die älter als 90 Tage sind:

```
doveadm search -u 'mailbox@example.org' mailbox 'INBOX' savedbefore 90d
```

Zeige **alle Nachrichten** in **beliebigen Ordnern**, die **älter** sind als 30 Tage für `mailbox@example.org`:

```
doveadm search -u 'mailbox@example.org' mailbox "*" savedbefore 30d
```

[^1]:https://wiki.dovecot.org/Tools/Doveadm/Quota
[^2]:https://wiki.dovecot.org/Tools/Doveadm/Search