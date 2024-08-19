Mailcow use `MAILCOW_HOSTNAME` as sender domain to send watchdog notifications and compose bounce emails.

1. `WATCHDOG_NOTIFY_EMAIL` should point to **external** recipients, which managed by another mailserver, this is **very** important, as watchdog notify about system outage, and if this happen - your instance would already not capable to accept or display this notificaion potentially.
2. As watchdog designed to work in any situations, including cases when Postfix, Rspamd or Redis is not working - we send mails directly via watchdog container to recipient MX without any DKIM signing.

To properly send watchdog notifications and bounces to external mail servers you need configure SPF and DMARC for `MAILCOW_HOSTNAME` (change `mail.example.com` and IPs to reflect your setup):

```
_dmarc.mail.example.com IN TXT "v=DMARC1; p=reject"
mail.example.com IN TXT "v=spf1 ip4:192.0.2.146/32 ip6:2001:db8::1/128 -all"
```

**NOTE:** if you want later you can use this SPF as include on another domains as:
```
example.com IN TXT "v=spf1 include:mail.example.com -all"
```
