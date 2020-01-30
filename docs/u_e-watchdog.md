The watchdog is a container that will continues monitor your Mailcow installation, and restart containers that are unhealty.


By default the watchdog is disabled to enable it change `n` to `y`:
```
USE_WATCHDOG=y
```

You can also add your email address via:
```
# Send notifications by mail (no DKIM signature, sent from watchdog@MAILCOW_HOSTNAME)
# Can by multiple rcpts, NO quotation marks
#WATCHDOG_NOTIFY_EMAIL=a@example.com,b@example.com,c@example.com
```

Once you did that you will receive email notifications for the following type of events:
- Watchdog startup
- Container failure and restart
- Netfilter bans

If you do not want to receive ban notification emails change `y` to `n`: 
```
# Notify about banned IP (includes whois lookup)
WATCHDOG_NOTIFY_BAN=y
```

Please note that you need to create a SPF record for your MAILCOW_HOSTNAME. Otherwise the recipient mailserver could reject the email. Its very important that if you have a SPF record it has to be correct so please take the time and check that it is indeed valid.

Please note that if you organisation domain as a DMARC record you should disable DMARC for the MAILCOW_HOSTNAME domain by setting:
```
# Name              Type       Value
_dmarc.MAILCOW_HOSTNAME TXT "v=DMARC1; p=none;"
```

Apply the changes by running `docker-compose up -d`.