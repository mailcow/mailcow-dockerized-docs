On August the 17th, we disabled the possibility to share with "any" or "all authenticated users" in Dovecot by default.

## Re-enable "any" ACL in Dovecot

Open `data/conf/dovecot/dovecot.conf`:
```
# Allow "any" or "authenticated" to be used in ACLs
#acl_anyone = allow
```
Remove "#" from "acl_anyone" and restart Dovecot by running `docker-compose restart dovecot-mailcow`.

## Re-enable "any" ACL field in SOGo

We have not yet made it an optional setting. But you can still rebuild sogo-mailcow with a slight change to 

Open `data/Dockerfiles/sogo/bootstrap-sogo.sh` and comment out the following code:

```
if patch -sfN --dry-run /usr/lib/GNUstep/SOGo/Templates/UIxAclEditor.wox < /acl.diff > /dev/null; then
  patch /usr/lib/GNUstep/SOGo/Templates/UIxAclEditor.wox < /acl.diff;
fi
```

Rebuild sogo-mailcow and update the stack:

```
docker-compose build sogo-mailcow
docker-compose up -d
```

