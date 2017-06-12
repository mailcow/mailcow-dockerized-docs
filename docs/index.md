HELLO!

# 🐮 + 🐋 = 💕

## Help mailcow

Let us know about your ideas in #mailcow @ Freenode.

[Servercow](https://www.servercow.de) - hosted mailcow, KVM based virtual servers, web-hosting and more.

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JWBSYHF4SMC68)

## Get support

### Commercial support

For commercial support contact [info@servercow.de](mailto:info@servercow.de).

### Community support

- IRC @ [Freenode, #mailcow](irc://irc.freenode.org:6667/mailcow)
- GitHub @ [mailcow/mailcow-dockerized](https://github.com/mailcow/mailcow-dockerized)

## Screenshots

You can find screenshots [on Imgur](http://imgur.com/a/oewYt).

## Overview

The integrated **mailcow UI** allows administrative work on your mail server instance as well as separated domain administrator and mailbox user access:

- DKIM key management
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

mailcow dockerized comes with **12 containers** linked in **one bridged network**.
Each container represents a single application.

- Dovecot
- ClamAV
- Memcached
- Redis
- MySQL
- Bind9 (Resolver) (formerly PDNS Recursor)
- PHP-FPM
- Postfix
- Nginx
- Rmilter
- Rspamd
- SOGo

**6 volumes** to keep dynamic data - take care of them!

- vmail-vol-1
- redis-vol-1
- mysql-vol-1
- rspamd-vol-1
- postfix-vol-1
- crypt-vol-1
