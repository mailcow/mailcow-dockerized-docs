## Neue Anleitung

Bearbeiten Sie ein Postfach und wählen Sie "Senden als * zulassen".

Aus historischen Gründen haben wir die alte und veraltete Anleitung unten beibehalten:

## Veraltete Anleitung (NICHT FÜR NEUERE MAILCOWS VERWENDEN!)

Diese Option ist keine Best-Practice und sollte nur verwendet werden, wenn es keine andere Möglichkeit gibt, das zu erreichen, was Sie erreichen wollen.

Erstellen Sie einfach eine Datei `data/conf/postfix/check_sasl_access` und tragen Sie den folgenden Inhalt ein. Dieser Benutzer muss in Ihrer Installation existieren und muss sich vor dem Versenden von Mails authentifizieren.
```
user-to-allow-everything@example.com OK
```

Öffnen Sie `data/conf/postfix/main.cf` und suchen Sie `smtpd_sender_restrictions`. Fügen Sie `check_sasl_access hash:/opt/postfix/conf/check_sasl_access` wie folgt ein:
```
smtpd_sender_restrictions = check_sasl_access hash:/opt/postfix/conf/check_sasl_access reject_authenticated_sender_login_mismatch [...]
```

Postmap auf check_sasl_access ausführen:

```
docker compose exec postfix-mailcow postmap /opt/postfix/conf/check_sasl_access
```

Starten Sie den Postfix-Container neu.
