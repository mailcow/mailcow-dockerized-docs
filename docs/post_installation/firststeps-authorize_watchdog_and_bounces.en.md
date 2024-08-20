mailcow uses `MAILCOW_HOSTNAME` as the sender domain to send watchdog notifications and compose bounce emails.

1. `WATCHDOG_NOTIFY_EMAIL` should point to **external** recipients, managed by another mail server. This is **very** important because the watchdog notifies you about system outages. If this happens, your instance might not be capable of accepting or displaying this notification.
2. Since the watchdog is designed to work in any situation, including cases when Postfix, Rspamd, or Redis is not functioning, we send emails directly via the watchdog container to the recipient's MX without any DKIM signing.

To properly send watchdog notifications and bounces to external mail servers, you need to configure SPF and DMARC for `MAILCOW_HOSTNAME` (replace `mail.example.com` and the IPs to reflect your setup):

```
_dmarc.mail.example.com IN TXT "v=DMARC1; p=reject"
mail.example.com IN TXT "v=spf1 ip4:192.0.2.146/32 ip6:2001:db8::1/128 -all"
```

!!! info
    If you want, later you can use this SPF as an include on other domains as:
    ```
    example.com IN TXT "v=spf1 include:mail.example.com -all"
    ```
