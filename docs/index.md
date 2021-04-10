# 🐮 + 🐋 = 💕

## Help mailcow

Please consider a support contract for a small monthly fee at [Servercow EN](https://www.servercow.de/mailcow?lang=en#support)/[Servercow DE](https://www.servercow.de/mailcow?#support) to support further development. _We_ support _you_ while _you_ support _us_. :)

If you are super awesome and would like to support without a contract, you can get a SAL license that confirms your awesomeness (a flexible one-time payment) at [Servercow EN](https://www.servercow.de/mailcow?lang=en#sal)/[Servercow DE](https://www.servercow.de/mailcow#sal).

## Get support

There are two ways to achieve support for your mailcow installation.

### Commercial support

For professional and prioritized commercial support you can sign a basic support subscription at [Servercow EN](https://www.servercow.de/mailcow?lang=en#support)/[Servercow DE](https://www.servercow.de/mailcow#support). For custom inquiries or questions please contact us at [info@servercow.de](mailto:info@servercow.de) instead.

Furthermore we do also provide a fully featured and managed mailcow [here](https://www.servercow.de/mailcow#managed). This way we take care about the technical magic underneath and you can enjoy your whole mail experience in a hassle-free way.

### Community support and chat

The other alternative is our free community-support on our various channels below. Please notice, that this support is driven by our awesome community around mailcow. This kind of support is best-effort, voluntary and there is no guarantee for anything.

- Our mailcow community @ [community.mailcow.email](https://community.mailcow.email)

- Telegram @ [t.me/mailcow](https://t.me/mailcow).

- Telegram @ [t.me/mailcowOfftopic](https://t.me/mailcowOfftopic).

Telegram desktop clients are available for [multiple platforms](https://desktop.telegram.org). You can search the groups history for keywords.

For **bug tracking, feature requests and code contributions** only:

- GitHub @ [mailcow/mailcow-dockerized](https://github.com/mailcow/mailcow-dockerized)

## Demo

You can find a demo at [demo.mailcow.email](https://demo.mailcow.email), use the following credentials to login:

- **Administrator**: admin / moohoo
- **Domain administrator**: department / moohoo
- **Mailbox**:  demo@440044.xyz / moohoo

## Overview

The integrated **mailcow UI** allows administrative work on your mail server instance as well as separated domain administrator and mailbox user access:

- [DKIM](http://dkim.org) and [ARC](http://arc-spec.org/) support
- Black- and whitelists per domain and per user
- Spam score management per-user (reject spam, mark spam, greylist)
- Allow mailbox users to create temporary spam aliases
- Prepend mail tags to subject or move mail to sub folder (per-user)
- Allow mailbox users to toggle incoming and outgoing TLS enforcement
- Allow users to reset SOGo ActiveSync device caches
- imapsync to migrate or pull remote mailboxes regularly
- TFA: Yubikey OTP and U2F USB (Google Chrome and derivatives only), TOTP
- Add domains, mailboxes, aliases, domain aliases and SOGo resources
- Add whitelisted hosts to forward mail to mailcow
- Fail2ban-like integration
- Quarantine system
- Antivirus scanning incl. macro scanning in office documents
- Integrated basic monitoring
- A lot more...

mailcow: dockerized comes with multiple containers linked in one bridged network.
Each container represents a single application.

- [ACME](https://letsencrypt.org/)
- [ClamAV](https://www.clamav.net/) (optional)
- [Dovecot](https://www.dovecot.org/)
- [ejabberd](https://www.ejabberd.im/)
- [MariaDB](https://mariadb.org/)
- [Memcached](https://www.memcached.org/)
- [Netfilter](https://www.netfilter.org/) (Fail2ban-like integration by [@mkuron](https://github.com/mkuron))
- [Nginx](https://nginx.org/)
- [Oletools](https://github.com/decalage2/oletools) via [Olefy](https://github.com/HeinleinSupport/olefy)
- [PHP](https://php.net/)
- [Postfix](http://www.postfix.org/)
- [Redis](https://redis.io/)
- [Rspamd](https://www.rspamd.com/)
- [SOGo](https://sogo.nu/)
- [Solr](http://lucene.apache.org/solr/) (optional)
- [Unbound](https://unbound.net/)
- A Watchdog to provide basic monitoring

**Docker volumes** to keep dynamic data - take care of them!

- crypt-vol-1
- mysql-socket-vol-1
- mysql-vol-1
- postfix-vol-1
- redis-vol-1
- rspamd-vol-1
- sogo-userdata-backup-vol-1
- sogo-web-vol-1
- solr-vol-1
- vmail-index-vol-1
- vmail-vol-1
- xmpp-upload-vol-1
- xmpp-vol-1
