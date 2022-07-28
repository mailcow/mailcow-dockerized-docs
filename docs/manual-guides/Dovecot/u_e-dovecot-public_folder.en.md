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

To allow all authenticated users access full to that new mailbox (not the whole namespace), run:

```
docker compose exec dovecot-mailcow doveadm acl set -A "Public/Develcow" "authenticated" lookup read write write-seen write-deleted insert post delete expunge create
```

Adjust the command to your needs if you like to assign more granular rights per user (use `-u user@domain` instead of `-A` for example).

## Allow authenticated users access to the whole public namespace

To allow all authenticated users access full access to the whole public namespace and its subfolders, create a new `dovecot-acl` file in the namespace root directory:

Open/edit/create `/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data/public/dovecot-acl` (adjust the path accordingly) to create the global ACL file with the following content:

```
authenticated kxeilprwts
```

`kxeilprwts` equals to `lookup read write write-seen write-deleted insert post delete expunge create`.

You can use `doveadm acl set -u user@domain "Public/Develcow" user=user@domain lookup read` to limit access for a single user. You may also turn it around to limit access for all users to "lr" and grant only some users full access.

See [Dovecot ACL](https://doc.dovecot.org/settings/plugin/acl/) for further information about ACL.
