<figure markdown>
  ![mailcow Logo](assets/images/logo.svg){ width="150" }
</figure>

# mailcow: dockerized - :cow: + :whale: = :two_hearts:
**The mailserver suite with the 'moo'**

## What is mailcow: dockerized?

!!! question
	Mailcow, MailCow or mailcow? What is the exact name of the project?

	Correct: **mailcow**, because mailcow is a registered word mark with a small m :grin:

mailcow: dockerized is an open source groupware/email suite based on docker.

mailcow relies on many well known and long used components, which in combination result in an all around carefree email server.

Each container represents a single application, connected in a bridged network.

- [ACME](https://letsencrypt.org/) (Automatic generation of Let's Encrypt certificates)
- [ClamAV](https://www.clamav.net/) (anti-virus scanner) (optional)
- [Dovecot](https://www.dovecot.org/) (IMAP/POP server for retrieving mail)
- [MariaDB](https://mariadb.org/) (database to store user information, etc.)
- [Memcached](https://www.memcached.org/) (cache for the SOGo webmailer)
- [Netfilter](https://www.netfilter.org/) (Fail2ban-like integration of [@mkuron](https://github.com/mkuron))
- [Nginx](https://nginx.org/) (Web server for the mailcow UI)
- [Oletools](https://github.com/decalage2/oletools) via [Olefy](https://github.com/HeinleinSupport/olefy) (analyzing office documents for viruses, macros, etc.)
- [PHP](https://php.net/) (programming language for most web-based mailcow actions)
- [Postfix](http://www.postfix.org/) (Receiver/sender for mail traffic on the Internet)
- [Redis](https://redis.io/) (storage for spam information, DKIM keys, etc.)
- [Rspamd](https://www.rspamd.com/) (spam filter with automatic learning of spam mails)
- [SOGo](https://sogo.nu/) (integrated webmailer and cal/carddav interface)
- [Solr](https://solr.apache.org/) (full-text search for IMAP connections for quick email search) (optional)
- [Unbound](https://unbound.net/) (integrated DNS server to check DNSSEC etc.)
- A watchdog for basic monitoring of container health inside mailcow

But the heart of mailcow is the graphical web interface, the **mailcow UI**.

It offers a place for almost all settings and allows the comfortable creation of new domains and email addresses with just a few clicks.

But also other or more tricky tasks can be done in it with ease:

- [DKIM](http://dkim.org) and [ARC](http://arc-spec.org/) support/generation.
- Black and white lists per domain and per user.
- Spam score management per user (reject spam, flag spam, greylist).
- Allow mailbox users to create temporary spam aliases
- Prepend email tags to subject or move emails to subfolders (per user)
- Allow mailbox users to toggle TLS enforcement for inbound and outbound messages
- Users can reset caches on SOGo ActiveSync devices
- imapsync to periodically migrate or retrieve remote mailboxes
- TFA: Yubikey OTP and WebAuthn USB (Google Chrome and derivatives only), TOTP
- Add whitelist hosts to forward mail to mailcow
- Fail2ban-like integration
- Quarantine system
- Anti-virus scanning including macro scanning in Office documents
- Integrated basic monitoring
- And much more...

The mailcow data (such as emails, user data, etc.) is stored in **Docker volumes** - take good care of these volumes:

- clamd-db-vol-1
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

!!! warning
	The mails are compressed and encrypted. The key pair can be found in crypt-vol-1. Please don't forget to backup this and other volumes. #nobackupnopity

---

## Support the mailcow project

Please consider a support contract for a small monthly fee at [Servercow](https://www.servercow.de/mailcow?lang=en#support)[^1] to support further development. _We_ support _you_ while _you_ support _us_. :)

If you are super awesome and would like to support without a contract, you can get a SAL (Stay-Awesome License) that confirms your awesomeness (a flexible one-time payment) at [Servercow](https://www.servercow.de/mailcow?lang=en#sal).

---

## Need help?

There are two ways to achieve support for your mailcow installation.

### Commercial support

For professional and prioritized commercial support you can sign a basic support subscription at [Servercow](https://www.servercow.de/mailcow?lang=en#support). For custom inquiries or questions please contact us at [info@servercow.de](mailto:info@servercow.de) instead.

Furthermore we do also provide a fully featured and managed mailcow [here](https://www.servercow.de/mailcow?lang=en#managed). This way we take care about the technical magic underneath and you can enjoy your whole mail experience in a hassle-free way.

### Community support and chat

The other alternative is our free community-support on our various channels below. Please notice, that this support is driven by our awesome community around mailcow. This kind of support is best-effort, voluntary and there is no guarantee for anything.

- :material-forum: [mailcow Community @ community.mailcow.email](https://community.mailcow.email)

- :fontawesome-brands-telegram:{ .telegram } [Telegram (Support) @ t.me/mailcow](https://t.me/mailcow)

- :fontawesome-brands-telegram:{ .telegram } [Telegram (Off-Topic) @ t.me/mailcowOfftopic](https://t.me/mailcowOfftopic)

Telegram desktop clients are available for [multiple platforms](https://desktop.telegram.org). You can search the groups history for keywords.

For **bug tracking, feature requests and code contributions** only:

- :fontawesome-brands-github: [mailcow/mailcow-dockerized @ GitHub](https://github.com/mailcow/mailcow-dockerized)

### News and release informations

For announcements and release informations you can find us on:

- :fontawesome-brands-x-twitter: [mailcow @ X/Twitter](https://twitter.com/mailcow)

- :fontawesome-brands-mastodon:{ .mastodon }  [@doncow @ mailcow.social](https://mailcow.social/@doncow)

Or alternatively on our blog:

- :fontawesome-solid-globe: [mailcow.email](https://mailcow.email)

---
## Interested? Try it out right away!

Have we got your interest? Get a first overview of the functionalities of mailcow and your mailcow UI in our official **mailcow demos**!

Since September 2022 we´re providing two seperate Demo instances: 

+ **[demo.mailcow.email](https://demo.mailcow.email)** is the classic Demo based on the **stable releases**.
+ **[nightly-demo.mailcow.email](https://nightly-demo.mailcow.email)** is the new **nightly demo** based on unreleased testing features. (So especially interesting for those who have no possibility to create a test instance themselves.)

!!! abstract "Use these credentials for the demos"
	- **Administrator**: admin / moohoo
	- **Domain-Administrator**: department / moohoo
	- **Mailbox**: demo@440044.xyz / moohoo
	
	*The login credentials work for both variants*.

!!! success "Always up to date"
	The demo instances get the latest updates directly after releases from GitHub. Fully automatic, without any downtime!

[^1]: Servercow is a hosting/support division of The Infrastructure Company GmbH (mailcow maintainer).