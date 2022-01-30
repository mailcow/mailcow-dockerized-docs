Die Bearbeitung eines Domänenadministrators oder eines Mailboxbenutzers ermöglicht es, Einschränkungen für dieses Konto festzulegen.

**Wichtig**: Bei sich überschneidenden Modulen wie Synchronisierungsaufträgen, auf die sowohl Domänenadministratoren als auch Mailbox-Benutzer Zugriff erhalten können, werden die Rechte des Domänenadministrators geerbt, wenn man sich als Mailbox-Benutzer anmeldet.

Einige Beispiele:

1.

- Ein Domänenadministrator hat **keinen** Zugriff auf Synchronisierungsaufträge, kann sich aber als Mailbox-Benutzer anmelden
- Wenn er sich als Mailbox-Benutzer anmeldet, erhält er keinen Zugriff auf Synchronisierungsaufträge, auch wenn der betreffende Mailbox-Benutzer bei der direkten Anmeldung Zugriff _hat_.

2.

- Ein Domänenadministrator **hat** Zugriff auf Synchronisierungsaufträge und kann sich als Postfachbenutzer anmelden
- Der Mailbox-Benutzer, als der er sich anzumelden versucht, hat **keinen** Zugang zu Synchronisierungsaufträgen
- Der Domänenadministrator, der nun als Mailbox-Benutzer angemeldet ist, erbt die Berechtigung des Mailbox-Benutzers und kann auf Synchronisierungsaufträge zugreifen.

3.

- Ein Domänenadministrator meldet sich als Mailbox-Benutzer an
- Jede Berechtigung, die **nicht** in der ACL eines Domänenadministrators vorhanden ist, wird automatisch gewährt (Beispiel: zeitlich begrenzter Alias, TLS-Richtlinie usw.)