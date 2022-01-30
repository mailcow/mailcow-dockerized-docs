Wenn eine Mailbox erstellt wird, kann ein Benutzer Mails von seiner eigenen Mailboxadresse senden und empfangen.

    Die Mailbox me@example.org wird erstellt. example.org ist eine primäre Domäne.
    Hinweis: Eine Mailbox kann nicht in einer Alias-Domäne erstellt werden.

    me@example.org ist nur als me@example.org bekannt.
    me@example.org darf als me@example.org senden.

Wir können eine Alias-Domäne für example.org hinzufügen:

    Die Alias-Domäne alias.com wird hinzugefügt und der primären Domäne example.org zugewiesen.
    me@example.org ist nun als me@example.org und me@alias.com bekannt.
    me@example.org darf nun als me@example.org und me@alias.com senden.

Wir können Aliase für eine Mailbox hinzufügen, um Mails von dieser neuen Adresse zu empfangen und zu senden.

Es ist wichtig zu wissen, dass Sie nicht in der Lage sind, Mails für `my-alias@my-alias-domain.tld` zu empfangen. Sie müssen diesen speziellen Alias erstellen.

    me@example.org wird der Alias alias@example.org zugewiesen.
    me@example.org ist jetzt bekannt als me@example.org, me@alias.com, alias@example.org

    me@example.org ist NICHT als alias@alias.com bekannt.

Bitte beachten Sie, dass dies nicht für "catch-all"-Aliasnamen gilt:

    Die Alias-Domäne alias.com wird hinzugefügt und der primären Domäne example.org zugewiesen
    me@example.org wird der Catch-all-Alias @example.org zugewiesen
    me@example.org ist weiterhin nur als me@example.org bekannt, was die einzige verfügbare send-as Option ist.
    
    Jede an alias.com gesendete E-Mail wird mit dem Catch-All-Alias für example.org übereinstimmen.

Administratoren und Domänenadministratoren können Postfächer bearbeiten, um bestimmten Benutzern zu erlauben, als andere Postfachbenutzer zu senden (sie zu "delegieren").

Sie können zwischen Mailbox-Benutzern wählen oder die Absenderprüfung für Domänen komplett deaktivieren.

### SOGo "Mail von"-Adressen

Mailbox-Benutzer können natürlich ihre eigene Mailbox-Adresse auswählen, sowie alle Alias-Adressen und Aliase, die über Alias-Domänen existieren.

Wenn Sie einen anderen _existierenden_ Mailbox-Benutzer als Ihre "Mail von"-Adresse auswählen wollen, muss dieser Benutzer Ihnen den Zugriff über SOGo delegieren (siehe SOGo-Dokumentation). Außerdem muss ein mailcow (Domain) Administrator
Ihnen den Zugang wie oben beschrieben gewähren.