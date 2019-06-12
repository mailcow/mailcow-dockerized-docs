# 🐮 + 🐋 = 💕

## Help mailcow

Let us know about your ideas in #mailcow @ Freenode.

[Servercow](https://www.servercow.de) - hosted mailcow, KVM based virtual servers, web-hosting and more.

[![Donate (PayPal)](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JWBSYHF4SMC68)
[![Donate (Bitcoin)](https://img.shields.io/badge/Donate-Bitcoin-blue.svg)](bitcoin:1E5rgzgA1sS3QH7r1ToWxRC3GEavfsGMrx)

## 💡 Entwickler gesucht!
Wir suchen für die Entwicklung eines sicheren Mailstacks dringend erfahrene DevOps. Bis hin zur Festanstellung sind alle Möglichkeiten offen. Bitte meldet euch bei info@servercow.de. Voraussetzung: Erfahrung mit dem Betreiben von E-Mail-Umgebungen - bestenfalls im Cluster.

## Get support

### Commercial support

For commercial support contact [info@servercow.de](mailto:info@servercow.de) or get a support subscription at [Servercow](https://www.servercow.de/mailcow#support).

A fully featured managed mailcow is also available [here](https://www.servercow.de/mailcow#managed).

### Community support

- IRC @ [Freenode, #mailcow](irc://irc.freenode.org:6667/mailcow)
- GitHub @ [mailcow/mailcow-dockerized](https://github.com/mailcow/mailcow-dockerized)

## Demo

You can find a demo at [demo.mailcow.email](https://demo.mailcow.email), use the following credentials to login:

- **Administrator**: admin / moohoo
- **Domain administrator**: department / moohoo
- **Mailbox**: demo@mailcow.email / moohoo

## Overview

The integrated **mailcow UI** allows administrative work on your mail server instance as well as separated domain administrator and mailbox user access:

- DKIM and ARC support
- Black- and whitelists per domain and per user
- Spam score management per-user (reject spam, mark spam, greylist)
- Allow mailbox users to create temporary spam aliases
- Prepend mail tags to subject or move mail to sub folder (per-user)
- Allow mailbox users to toggle incoming and outgoing TLS enforcement
- Allow users to reset SOGo ActiveSync device caches
- imapsync to migrate or pull remote mailboxes regularly
- TFA: Yubi OTP and U2F USB (Google Chrome and derivatives only), TOTP
- Add domains, mailboxes, aliases, domain aliases and SOGo resources
- Add whitelisted hosts to forward mail to mailcow
- Fail2ban-like integration
- Quarantine system
- A lot more...

mailcow: dockerized comes with multiple containers linked in one bridged network.
Each container represents a single application.

- Dovecot
- ClamAV (optional)
- Solr (optional)
- Memcached
- Redis
- MySQL
- Unbound (as resolver)
- PHP-FPM
- Postfix
- ACME-Client (thanks to @bebehei)
- Nginx
- Rspamd
- SOGo
- Netfilter (Fail2ban-like integration by @mkuron)
- Watchdog (basic monitoring)

**Docker volumes** to keep dynamic data - take care of them!

- vmail-vol-1
- solr-vol-1
- redis-vol-1
- mysql-vol-1
- rspamd-vol-1
- postfix-vol-1
- crypt-vol-1
