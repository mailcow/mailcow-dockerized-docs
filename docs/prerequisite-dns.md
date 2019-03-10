Below you can find a list of **recommended DNS records**. While some are mandatory for a mail server (A, MX), others are recommended to build a good reputation score (TXT/SPF) or used for auto-configuration of mail clients (SRV).

## References

- A good article covering all relevant topics:
  ["3 DNS Records Every Email Marketer Must Know"](https://www.rackaid.com/blog/email-dns-records)
- Another great one, but Zimbra as an example platform:
  ["Best Practices on Email Protection: SPF, DKIM and DMARC"](https://wiki.zimbra.com/wiki/Best_Practices_on_Email_Protection:_SPF,_DKIM_and_DMARC)
- An in-depth discussion of SPF, DKIM and DMARC:
  ["How to eliminate spam and protect your name with DMARC"](https://www.skelleton.net/2015/03/21/how-to-eliminate-spam-and-protect-your-name-with-dmarc/)

## Reverse DNS of your IP

Make sure that the PTR record of your IP matches the FQDN of your mailcow host: `${MAILCOW_HOSTNAME}` [^1]. This record is usually set at the provider you leased the IP (server) from.

## The minimal DNS configuration

This example shows you a set of records for one domain managed by mailcow. Each domain that is added to mailcow needs at least this set of records to function correctly.

```
# Name              Type       Value
mail                IN A       1.2.3.4
autodiscover        IN CNAME   mail
autoconfig          IN CNAME   mail

@                   IN MX 10   mail
```

## DKIM, SPF and DMARC

In the example DNS zone file snippet below, a simple **SPF** TXT record is used to only allow THIS server (the MX) to send mail for your domain. Every other server is disallowed but able to ("`~all`"). Please refer to [SPF Project](http://www.openspf.org) for further reading.

```
@                   IN TXT     "v=spf1 mx ~all"
```

It is highly recommended to create a **DKIM** TXT record in your mailcow UI and set the corresponding TXT record in your DNS records. Please refer to [OpenDKIM](http://www.opendkim.org) for further reading.

```
dkim._domainkey  IN TXT     "v=DKIM1; k=rsa; t=s; s=email; p=..."
```

The last step in protecting yourself and others is the implementation of a **DMARC** TXT record, for example by using the [DMARC Assistant](http://www.kitterman.com/dmarc/assistant.html) ([check](https://dmarcian.com/dmarc-inspector/google.com)).

```
_dmarc              IN TXT     "v=DMARC1; p=reject; rua=mailto:mailauth-reports@example.org"
```

## The advanced DNS configuration

**SRV** records specify the server(s) for a specific protocol on your domain. If you want to explicitly announce a service as not provided, give "." as the target address (instead of "mail.example.org."). Please refer to [RFC 2782](https://tools.ietf.org/html/rfc2782).

```
_imap._tcp          IN SRV     0 1 143   mail.example.org.
_imaps._tcp         IN SRV     0 1 993   mail.example.org.
_pop3._tcp          IN SRV     0 1 110   mail.example.org.
_pop3s._tcp         IN SRV     0 1 995   mail.example.org.
_submission._tcp    IN SRV     0 1 587   mail.example.org.
_smtps._tcp         IN SRV     0 1 465   mail.example.org.
_sieve._tcp         IN SRV     0 1 4190  mail.example.org.
_autodiscover._tcp  IN SRV     0 1 443   mail.example.org.
_carddavs._tcp      IN SRV     0 1 443   mail.example.org.
_carddavs._tcp      IN TXT     "path=/SOGo/dav/"
_caldavs._tcp       IN SRV     0 1 443   mail.example.org.
_caldavs._tcp       IN TXT     "path=/SOGo/dav/"
```

## Testing

Here are some tools you can use to verify your DNS configuration:

- [MX Toolbox](https://mxtoolbox.com/SuperTool.aspx) (DNS, SMTP, RBL)
- [port25.com](https://www.port25.com/dkim-wizard/) (DKIM, SPF)
- [Mail-tester](https://www.mail-tester.com/) (DKIM, DMARC, SPF)
- [DMARC Analyzer](https://www.dmarcanalyzer.com/spf/checker/) (DMARC, SPF)

## Misc

If you are interested in statistics, you can additionally register with the [Postmaster Tool](https://gmail.com/postmaster)  by Google and supply a **google-site-verification** TXT record, which will give you details about spam-classified mails by your domain. This is clearly optional.

```
@                   IN TXT     "google-site-verification=..."
```

[^1]: A **Fully Qualified Domain Name** (**FQDN**) is the complete (absolute) domain name for a specific computer or host, on the Internet. The FQDN consists of at least three parts divided by a dot: the hostname (myhost), the domain name (mydomain) and the top level domain in short **tld** (com). In the example of `mx.mailcow.email` the hostname would be `mx`, the domain name 'mailcow' and the tld `email`.
