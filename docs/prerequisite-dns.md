Below you can find a list of **recommended DNS records**. While some are mandatory for a mail server (A, MX), others are recommended to build a good reputation score (TXT/SPF) or used for auto-configuration of mail clients (SRV).

## References

- A good article covering all relevant topics:
  ["3 DNS Records Every Email Marketer Must Know"](https://www.rackaid.com/blog/email-dns-records)
- Another great one, but Zimbra as an example platform:
  ["Best Practices on Email Protection: SPF, DKIM and DMARC"](https://wiki.zimbra.com/wiki/Best_Practices_on_Email_Protection:_SPF,_DKIM_and_DMARC)
- An in-depth discussion of SPF, DKIM and DMARC:
  ["How to eliminate spam and protect your name with DMARC"](https://www.skelleton.net/2015/03/21/how-to-eliminate-spam-and-protect-your-name-with-dmarc/)
- A thorough guide on understanding DMARC:
["Demystifying DMARC: A guide to preventing email spoofing"](https://seanthegeek.net/459/demystifying-dmarc/)


## Reverse DNS of your IP address

Make sure that the PTR record of your IP address matches the FQDN of your mailcow host: `${MAILCOW_HOSTNAME}` [^1]. This record is usually set at the provider you leased the IP address (server) from.

## The minimal DNS configuration

This example shows you a set of records for one domain managed by mailcow. Each domain that is added to mailcow needs at least this set of records to function correctly.

```
# Name              Type       Value
mail                IN A       1.2.3.4
autodiscover        IN CNAME   mail.example.org. (your ${MAILCOW_HOSTNAME})
autoconfig          IN CNAME   mail.example.org. (your ${MAILCOW_HOSTNAME})
@                   IN MX 10   mail.example.org. (your ${MAILCOW_HOSTNAME})
```

## DKIM, SPF and DMARC

In the example DNS zone file snippet below, a simple **SPF** TXT record is used to only allow THIS server (the MX) to send mail for your domain. Every other server is disallowed but able to ("`~all`"). Please refer to [SPF Project](http://www.open-spf.org/) for further reading.

```
# Name              Type       Value
@                   IN TXT     "v=spf1 mx a -all"
```

It is highly recommended to create a **DKIM** TXT record in your mailcow UI and set the corresponding TXT record in your DNS records. Please refer to [OpenDKIM](http://www.opendkim.org) for further reading.

```
# Name              Type       Value
dkim._domainkey     IN TXT     "v=DKIM1; k=rsa; t=s; s=email; p=..."
```

The last step in protecting yourself and others is the implementation of a **DMARC** TXT record, for example by using the [DMARC Assistant](http://www.kitterman.com/dmarc/assistant.html) ([check](https://dmarcian.com/dmarc-inspector/google.com)).

```
# Name              Type       Value
_dmarc              IN TXT     "v=DMARC1; p=reject; rua=mailto:mailauth-reports@example.org"
```

## The advanced DNS configuration

**SRV** records specify the server(s) for a specific protocol on your domain. If you want to explicitly announce a service as not provided, give "." as the target address (instead of "mail.example.org."). Please refer to [RFC 2782](https://tools.ietf.org/html/rfc2782).

```
# Name              Type       Priority Weight Port    Value
_autodiscover._tcp  IN SRV     0        1      443      mail.example.org. (your ${MAILCOW_HOSTNAME})
_caldavs._tcp       IN SRV     0        1      443      mail.example.org. (your ${MAILCOW_HOSTNAME})
_caldavs._tcp       IN TXT                              "path=/SOGo/dav/"
_carddavs._tcp      IN SRV     0        1      443      Mail.example.org. (your ${MAILCOW_HOSTNAME})
_carddavs._tcp      IN TXT                              "path=/SOGo/dav/"
_imap._tcp          IN SRV     0        1      143      mail.example.org. (your ${MAILCOW_HOSTNAME})
_imaps._tcp         IN SRV     0        1      993      mail.example.org. (your ${MAILCOW_HOSTNAME})
_pop3._tcp          IN SRV     0        1      110      mail.example.org. (your ${MAILCOW_HOSTNAME})
_pop3s._tcp         IN SRV     0        1      995      mail.example.org. (your ${MAILCOW_HOSTNAME})
_sieve._tcp         IN SRV     0        1      4190     mail.example.org. (your ${MAILCOW_HOSTNAME})
_smtps._tcp         IN SRV     0        1      465      mail.example.org. (your ${MAILCOW_HOSTNAME})
_submission._tcp    IN SRV     0        1      587      mail.example.org. (your ${MAILCOW_HOSTNAME})
```

## Testing

Here are some tools you can use to verify your DNS configuration:

- [MX Toolbox](https://mxtoolbox.com/SuperTool.aspx) (DNS, SMTP, RBL)
- [port25.com](https://www.port25.com/dkim-wizard/) (DKIM, SPF)
- [Mail-tester](https://www.mail-tester.com/) (DKIM, DMARC, SPF)
- [DMARC Analyzer](https://www.dmarcanalyzer.com/spf/checker/) (DMARC, SPF)
- [MultiRBL.valli.org](http://multirbl.valli.org/) (DNSBL, RBL, FCrDNS)

## Misc

### Optional DMARC Statistics
If you are interested in statistics, you can additionally register with some of the many below DMARC statistic services, or self-host your own.

**NOTE:** It is worth considering that if you request DMARC statistic reports to your mailcow server, if there are issues with that domain you may not get accurate results. You can consider using an alternative email domain for recieving DMARC reports.

It is worth mentioning, that the following suggestions are not a comprehensive list of all services and tools avaialble, but only a small few of the many choices.

- [Postmaster Tool](https://gmail.com/postmaster)
- [parsedmarc](https://github.com/domainaware/parsedmarc) (self-hosted)
- [Fraudmarc](https://fraudmarc.com/)
- [Postmark](https://dmarc.postmarkapp.com)
- [Dmarcian](https://dmarcian.com/)

**NOTE:** The services may provide you with a TXT record, which you would insert into your DNS records as the provider specifies. This record will give you details about spam-classified mails by your domain. However, please ensure to read the providers documentation from the service you choose, as this process may vary and not all providers may use a TXT record.

### Email Test for SPF, DKIM and DMARC:

To test send an email to the email below and wait for a reply:

check-auth@verifier.port25.com

You will get a report back that looks like the following:

```

==========================================================
Summary of Results
==========================================================
SPF check:          pass
"iprev" check:      pass
DKIM check:         pass
DKIM check:         pass
SpamAssassin check: ham

==========================================================
Details:
==========================================================
....
```
The full report will contain more technical details this is just the first section, we found this to be quite usful for testing both outgoing mail and spam scores.


### Fully Qualified Domain Name (FQDN)
[^1]: A **Fully Qualified Domain Name** (**FQDN**) is the complete (absolute) domain name for a specific computer or host, on the Internet. The FQDN consists of at least three parts divided by a dot: the hostname (myhost), the domain name (mydomain) and the top level domain in short **tld** (com). In the example of `mx.mailcow.email` the hostname would be `mx`, the domain name `mailcow` and the tld `email`.
