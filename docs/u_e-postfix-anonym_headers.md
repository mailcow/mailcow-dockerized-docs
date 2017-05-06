Save as `data/conf/postfix/mailcow_anonymize_headers.pcre`:

```
/^\s*Received:[^\)]+\)\s+\(Authenticated sender:(.+)/
	REPLACE Received: from localhost (localhost [127.0.0.1]) (Authenticated sender:$1
/^\s*User-Agent/        IGNORE
/^\s*X-Enigmail/        IGNORE
/^\s*X-Mailer/          IGNORE
/^\s*X-Originating-IP/  IGNORE
/^\s*X-Forward/         IGNORE
```

Add this to `data/conf/postfix/main.cf`:
```
smtp_header_checks = pcre:/opt/postfix/conf/mailcow_anonymize_headers.pcre
```
