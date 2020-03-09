IPs can be removed from Postscreen and therefore _also_ from RBL checks in `data/conf/postfix/custom_postscreen_whitelist.cidr`.

Postscreen does multiple checks to identify malicious senders. In most cases you want to whitelist an IP to exclude it from blacklist lookups.
