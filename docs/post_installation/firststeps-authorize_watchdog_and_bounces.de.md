mailcow verwendet `MAILCOW_HOSTNAME` als Absenderdomain, um Watchdog-Benachrichtigungen zu senden und Bounce-E-Mails zu erstellen.

1. `WATCHDOG_NOTIFY_EMAIL` sollte auf **externe** Empfänger verweisen, die von einem anderen Mailserver verwaltet werden. Dies ist **sehr** wichtig, da der Watchdog über Systemausfälle informiert, und im Falle eines solchen Ausfalls wäre Ihre Instanz möglicherweise nicht in der Lage, diese Benachrichtigung zu empfangen oder anzuzeigen.

2. Da der Watchdog so konzipiert ist, dass er in allen Situationen funktioniert, einschließlich Fällen, in denen Postfix, Rspamd oder Redis nicht funktionieren, senden wir E-Mails direkt über den Watchdog-Container an den Empfänger-MX, ohne DKIM-Signierung.

Um Watchdog-Benachrichtigungen und Bounces ordnungsgemäß an externe Mailserver zu senden, müssen Sie SPF und DMARC für `MAILCOW_HOSTNAME` konfigurieren (ersetzen Sie `mail.example.com` und die IPs entsprechend Ihrer Konfiguration):

```
_dmarc.mail.example.com IN TXT "v=DMARC1; p=reject"
mail.example.com IN TXT "v=spf1 ip4:192.0.2.146/32 ip6:2001:db8::1/128 -all"
```

!!! info "Hinweis"
    Wenn Sie möchten, können Sie dieses SPF später als Include für andere Domains verwenden, wie zum Beispiel:

    ```
    example.com IN TXT "v=spf1 include:mail.example.com -all"
    ```
