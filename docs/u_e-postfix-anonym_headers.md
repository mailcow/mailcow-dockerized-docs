To disguise your users details like IP, email client, etc. we have to create a new file in `data/conf/postfix/mailcow_anonymize_headers.pcre` and insert the following:

```
/^\s*Received:.*Authenticated sender:(.+)/
    REPLACE Received: from localhost (localhost [127.0.0.1]) (Authenticated sender:$1
/^\s*User-Agent/        IGNORE
/^\s*X-Enigmail/        IGNORE
/^\s*X-Mailer/          IGNORE
/^\s*X-Originating-IP/  IGNORE
/^\s*X-Forward/         IGNORE
```

Next we need to add the following to `data/conf/postfix/main.cf`:

```
smtp_header_checks = pcre:/opt/postfix/conf/mailcow_anonymize_headers.pcre
```

Then restart Postfix:

```
docker-compose restart postfix-mailcow
```
