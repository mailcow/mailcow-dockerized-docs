XMPP is provided by ejabberd, which describes itself as robust, scalable and extensible XMPP Server.

So first of all, thanks to ejabberd and its contributers!

## Enable XMPP in mailcow

To enable XMPP for a domain, you need to edit the given domain in mailcow UI:

![Screen1](https://i.imgur.com/oLyHBke.png)

The chosen prefix will be used to derive your XMPP login.

A prefix **xmpp_prefix** for the mailbox user `cowboy@develcow.de` would equal to the JID `cowboy@xmpp_prefix.develcow.de`.

!!! info
    The login passwords for mail and XMPP are the same. XMPP users are authenticated against mailcow.

Before enabling XMPP for a domain, you should create two CNAME records in DNS:

```
# CNAMES
# Name              Type       Value
xmpp_prefix         IN CNAME   mail.example.org. (your ${MAILCOW_HOSTNAME})
*.xmpp_prefix       IN CNAME   mail.example.org. (your ${MAILCOW_HOSTNAME})
```

These two CNAMEs are essential for acquiring a certificate. Please **do not** add "xmpp_prefix.domain.tld" as name to `ADDITIONAL_SAN`.

Make sure your CNAMEs are correct. Enable XMPP for your domain now.

If you enabled XMPP first and then added your DNS records there is no need to worry. You will just need to wait for ejabberd to automatically acquire the certificates or
simply restart ejabberd-mailcow to trigger the process immediately: `docker-compose restart ejabberd-mailcow`.

Once ejabberd is enabled, you may want to re-run the DNS check in the mailcow UI where you will find two more SRV records:

![Screen2](https://i.imgur.com/IxlUZ7y.png)

```
# SRV records
# Name                            Type       Value
_xmpp-client._tcp.xmpp_prefix     IN SRV     10 1 5222 mail.example.org. (your ${MAILCOW_HOSTNAME})
_xmpp-server._tcp.xmpp_prefix     IN SRV     10 1 5269 mail.example.org. (your ${MAILCOW_HOSTNAME})
```

There is no need to restart ejabberd, add these SRV records whenever you like. These records are crucial for autoconfiguration of XMPP clients and server-to-server connections.

## ACL

A domain administrator can be given the right to toggle XMPP access for domains and mailboxes, promoting users to XMPP administrators (WIP) and to change the prefix:

![Screen3](https://i.imgur.com/OxKuDFU.png)

## Verify certificates

Once everything is setup, make sure ejabberd was able to acquire certificates:

If you see a message similar to...

```
ejabberd-mailcow_1   | 2021-02-13 14:40:19.507956+01:00 [error] Failed to request certificate for im.example.org, pubsub.im.example.org and 3 more hosts: Challenge failed for domain conference.im.example.org: ACME server reported: DNS problem: NXDOMAIN looking up A for conference.im.example.org - check that a DNS record exists for this domain (error type: dns)
```

...you may need to recheck your DNS configuration or restart ejabberd-mailcow to restart the process in case of slow DNS propagation.

Opening `https://xmpp_prefix.domain.tld:5443/upload` should point you to a 404 page with a valid certificate.

## Why can't we use no prefix?

It does not matter which server name we point our SRV to, Jabber will always rely on the domain given in a JID. We would need to acquire a certificate for the SLD `domain.tld`, which hardly anyone wants to point to its mail system.

We are sorry for this circumstance. As soon as we implemented Servercows DNS API, this may be reconsidered.

## My reverse proxy does not work anymore

If your reverse proxy is configured to point to a site like `webmail.domain.tld` **which mailcow is not aware of** (as in MAILCOW_HOSTNAME does **not** match `webmail.domain.tld`), you may now be redirected to the default ejabberd Nginx site.

That's because mailcow does not know it should respond to `webmail.domain.tld` with mailcow UI.

### Method 1

A more simple approach is defining `ADDITIONAL_SERVER_NAMES` in `mailcow.conf`:

```
ADDITIONAL_SERVER_NAMES=webmail.domain.tld
```

Run `docker-compose up -d` to apply.

### Method 2

In your reverse proxy configuration, make sure you set a "Host" header that mailcow actually services, similar to this (Nginx example):

```
proxy_set_header Host MAILCOW_HOSTNAME;
# Instead of proxy_set_header Host $http_host;
```

Now you can use whatever name you like, as long mailcow receives a known "Host" header.
