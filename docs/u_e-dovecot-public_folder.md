Create a new public namespace "Public" and a mailbox "Develcow" inside that namespace:

Edit or create `data/conf/dovecot/extra.conf`, add:

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

`:INDEXPVT=~/public` can be omitted if per-user seen flags are not wanted.

The new mailbox in the public namespace will be auto-subscribed by users.

To allow all authenticated users access full to that new mailbox, run:

```
docker-compose exec dovecot-mailcow doveadm acl set -A "Public/Develcow" "authenticated" lookup read write write-seen write-deleted insert post delete expunge create
```

Adjust the command to your needs if you like to assign more granular rights per user.

See [Dovecot ACL](https://doc.dovecot.org/settings/plugin/acl/) for further information about ACL.
