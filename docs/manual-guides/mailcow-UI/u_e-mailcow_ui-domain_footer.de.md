Eine domänenweite Fußzeile wird an die ausgehenden Mails einer Domain angehängt, als HTML und als reiner Text.

## Fußzeile einrichten

1. `E-Mail > Konfiguration > Domains` öffnen und neben der Domain auf `Bearbeiten` klicken.
2. Den Tab `Domänenweite Fußzeile` öffnen.
3. Die Fußzeile unter `Fußzeile im HTML Format` und `Fußzeile im PLAIN Format` eintragen. Mails mit HTML-Teil bekommen die HTML-Fußzeile, reine Text-Mails die PLAIN-Fußzeile.
4. Optional:
    - `von Fußzeile ausschließen`: Mailboxen und Aliasse, die ohne Fußzeile senden.
    - `Ignoriere Footer bei Antwort E-Mails`: Antworten (Mails mit `In-Reply-To`-Header) bekommen keine Fußzeile.
5. Speichern.

## Platzhalter

Die Fußzeile kann diese Platzhalter enthalten:

| Platzhalter | Wert |
| --- | --- |
| `{= auth_user =}` | Name des angemeldeten Benutzers |
| `{= from_user =}` | Lokaler Teil des Absenders, z. B. `moo` für `moo@example.org` |
| `{= from_name =}` | Anzeigename des Absenders, z. B. `Mailcow` für `Mailcow <moo@example.org>` |
| `{= from_addr =}` | Adresse des Absenders |
| `{= from_domain =}` | Domain des Absenders |
| `{= foo =}` | Wert des benutzerdefinierten Attributs `foo` der Mailbox (`benutzerdefinierte Attribute` auf der Bearbeiten-Seite der Mailbox) |

Unbekannte Platzhalter werden durch einen leeren Text ersetzt.
