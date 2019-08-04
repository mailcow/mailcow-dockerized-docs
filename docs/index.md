# 🐮 + 🐋 = 💕

## Help mailcow

Let us know about your ideas in #mailcow @ Freenode or in our Telegram channel @ [t.me/mailcow](https://t.me/mailcow).

Please [consider a support contract (around 30 € per month) with Servercow](https://www.servercow.de/mailcow#support) to support further development. _We_ support _you_ while _you_ support _us_. :)

If you are super awesome, you can get a SAL license that confirms your awesomeness (a flexible one-time payment) at [Servercow](https://www.servercow.de/mailcow?lang=en#sal).

We are looking for a build machine and demo installations. If you want to help us, please contact [info@servercow.de](mailto:info@servercow.de).

## Get support

### Commercial support

For commercial support contact [info@servercow.de](mailto:info@servercow.de) or get a basic support subscription at [Servercow](https://www.servercow.de/mailcow#support).

A fully featured managed mailcow is also available [here](https://www.servercow.de/mailcow#managed) - if not sold out.

### Community support

- IRC @ [Freenode, #mailcow](irc://irc.freenode.org:6667/mailcow)
- Telegram @ [t.me/mailcow](https://t.me/mailcow)

For bug tracking, feature requests and code contributions **only**:

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
- Integrated basic monitoring
- A lot more...

mailcow: dockerized comes with multiple containers linked in one bridged network.
Each container represents a single application.

- Dovecot
- ClamAV (optional)
- Solr (optional)
- Oletools via Olefy
- Memcached
- Redis
- MySQL
- Unbound (DNS resolver)
- PHP-FPM
- Postfix
- ACME-Client
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
