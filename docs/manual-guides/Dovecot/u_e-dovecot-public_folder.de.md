Erstellen Sie einen neuen öffentlichen Namespace "Public" und eine Mailbox "Develcow" innerhalb dieses Namespaces:

Bearbeiten oder erstellen Sie `data/conf/dovecot/extra.conf`, fügen Sie hinzu:

```
namespace {
  type = public
  separator = /
  prefix = Public/
  location = maildir:/var/vmail/public:INDEXPVT=~/public
  subscriptions = yes
  mailbox "Develcow" {
    auto = subscribe
  }
}
```

`:INDEXPVT=~/public` kann weggelassen werden, wenn die Flags, die pro Benutzer gesehen werden, nicht gewünscht sind.

Die neue Mailbox im öffentlichen Namensraum wird von den Benutzern automatisch abonniert.

Um allen authentifizierten Benutzern vollen Zugriff auf das neue Postfach (nicht auf den gesamten Namespace) zu gewähren, führen Sie aus:

```
docker-compose exec dovecot-mailcow doveadm acl set -A "Public/Develcow" "authenticated" lookup read write write-seen write-deleted insert post delete expunge create
```

Passen Sie den Befehl an Ihre Bedürfnisse an, wenn Sie detailliertere Rechte pro Benutzer vergeben möchten (verwenden Sie z.B. `-u user@domain` anstelle von `-A`).

## Erlaube authentifizierten Benutzern den Zugriff auf den gesamten öffentlichen Namespace

Um allen authentifizierten Benutzern vollen Zugriff auf den gesamten öffentlichen Namespace und seine Unterordner zu gewähren, erstellen Sie eine neue Datei `dovecot-acl` im Namespace-Stammverzeichnis:

Öffnen/bearbeiten/erstellen Sie `/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data/public/dovecot-acl` (passen Sie den Pfad entsprechend an), um die globale ACL-Datei mit dem folgenden Inhalt zu erstellen:

```
authenticated kxeilprwts
```

kxeilprwts" ist gleichbedeutend mit "lookup read write write-seen write-deleted insert post delete expunge create".

Sie können `doveadm acl set -u user@domain "Public/Develcow" user=user@domain lookup read` verwenden, um den Zugriff für einen einzelnen Benutzer zu beschränken. Sie können es auch umdrehen und den Zugriff für alle Benutzer auf "lr" beschränken und nur einigen Benutzern vollen Zugriff gewähren.

Siehe [Dovecot ACL](https://doc.dovecot.org/configuration_manual/acl/) für weitere Informationen über ACL.

