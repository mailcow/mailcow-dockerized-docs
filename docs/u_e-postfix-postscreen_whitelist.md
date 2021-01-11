IPs can be removed from Postscreen and therefore _also_ from RBL checks in `data/conf/postfix/custom_postscreen_whitelist.cidr`.

Postscreen does multiple checks to identify malicious senders. In most cases you want to whitelist an IP to exclude it from blacklist lookups.

The format of the file is as follows:

`CIDR   ACTION`

Where CIDR is a single IP address or IP range in CIDR notation, and action is either "permit" or "reject".

Example:

```
# Rules are evaluated in the order as specified.
# Blacklist 192.168.* except 192.168.0.1.
192.168.0.1          permit
192.168.0.0/16       reject
```

The file is reloaded on the fly, postfix restart is not required.