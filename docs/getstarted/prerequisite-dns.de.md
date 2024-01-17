Nachstehend finden Sie eine Liste von **empfohlenen DNS-Einträgen**. Einige sind für einen Mailserver obligatorisch (A, MX), andere werden empfohlen, um eine gute Reputation aufzubauen (TXT/SPF) oder für die automatische Konfiguration von Mailclients verwendet (SRV).

## Referenzen

- Ein guter Artikel, der alle relevanten Themen abdeckt:
  ["3 DNS Records Every Email Marketer Must Know"](https://www.rackaid.com/blog/email-dns-records)
- Ein weiterer guter Artikel, aber mit Zimbra als Beispielplattform:
  ["Best Practices on Email Protection: SPF, DKIM and DMARC"](https://wiki.zimbra.com/wiki/Best_Practices_on_Email_Protection:_SPF,_DKIM_and_DMARC)
- Eine ausführliche Diskussion über SPF, DKIM und DMARC:
  ["Wie Sie Spam beseitigen und Ihren Namen mit DMARC schützen"](https://www.skelleton.net/2015/03/21/how-to-eliminate-spam-and-protect-your-name-with-dmarc/)
- Ein ausführlicher Leitfaden zum Verständnis von DMARC:
["Entmystifizierung von DMARC: Ein Leitfaden zur Verhinderung von E-Mail-Spoofing"](https://seanthegeek.net/459/demystifying-dmarc/)


## Reverse DNS Ihrer IP-Adresse

Stellen Sie sicher, dass der PTR-Eintrag Ihrer IP-Adresse mit dem FQDN Ihres mailcow-Hosts übereinstimmt: `${MAILCOW_HOSTNAME}` [^1]. Dieser Eintrag wird normalerweise bei dem Provider gesetzt, von dem Sie die IP-Adresse (Server) gemietet haben.

## Die minimale DNS-Konfiguration

Dieses Beispiel zeigt Ihnen eine Reihe von Einträgen für eine von mailcow verwaltete Domain. Jede Domain, die zu mailcow hinzugefügt wird, benötigt mindestens diesen Satz an Einträgen, um korrekt zu funktionieren.

```
# Name Typ Wert
mail IN A 1.2.3.4
autodiscover IN CNAME mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
autoconfig IN CNAME mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
@ IN MX 10 mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
```

**Hinweis:** Der `mail` DNS-Eintrag, der die Subdomain an die angegebene IP-Adresse bindet, muss nur für die Domain gesetzt werden, auf der mailcow läuft und die für den Zugriff auf das Webinterface verwendet wird. Für jede andere von mailcow verwaltete Domain leitet der `MX`-Eintrag den Datenverkehr entsprechend weiter.

## DKIM, SPF und DMARC

Im folgenden Beispiel für eine DNS-Zonendatei wird ein einfacher **SPF** TXT-Eintrag verwendet, um nur DIESEM Server (dem MX) zu erlauben, E-Mails für Ihre Domäne zu senden. Jeder andere Server ist nicht zugelassen, kann es aber tun ("`~all`"). Weitere Informationen finden Sie im [SPF-Projekt](http://www.open-spf.org/).

```
# Name Typ Wert
@ IN TXT "v=spf1 mx a -all"
```

Es wird dringend empfohlen, einen **DKIM** TXT-Eintrag in Ihrer mailcow UI zu erstellen und den entsprechenden TXT-Eintrag in Ihren DNS-Einträgen zu setzen. Bitte lesen Sie [OpenDKIM](http://www.opendkim.org) für weitere Informationen.

```
# Name Typ Wert
dkim._domainkey IN TXT "v=DKIM1; k=rsa; t=s; s=email; p=..."
```

Der letzte Schritt, um sich selbst und andere zu schützen, ist die Implementierung eines **DMARC** TXT-Datensatzes, zum Beispiel mit Hilfe des [DMARC-Assistenten](http://www.kitterman.com/dmarc/assistant.html) ([check](https://dmarcian.com/dmarc-inspector/google.com)).

```
# Name Typ Wert
_dmarc IN TXT "v=DMARC1; p=reject; rua=mailto:mailauth-reports@example.org"
```

## Die erweiterte DNS-Konfiguration

**SRV**-Einträge geben den/die Server für ein bestimmtes Protokoll in Ihrer Domäne an. Wenn Sie einen Dienst explizit als nicht bereitgestellt ankündigen wollen, geben Sie "." als Zieladresse an (statt "mail.example.org."). Bitte beachten Sie [RFC 2782](https://tools.ietf.org/html/rfc2782).

```
# Name Typ Priorität Gewicht Port Wert
_autodiscover._tcp IN SRV 0 1 443 mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
_caldavs._tcp IN SRV 0 1 443 mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
_caldavs._tcp IN TXT "path=/SOGo/dav/"
_carddavs._tcp IN SRV 0 1 443 mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
_carddavs._tcp IN TXT "path=/SOGo/dav/"
_imap._tcp IN SRV 0 1 143 mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
_imaps._tcp IN SRV 0 1 993 mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
_pop3._tcp IN SRV 0 1 110 mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
_pop3s._tcp IN SRV 0 1 995 mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
_sieve._tcp IN SRV 0 1 4190 mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
_smtps._tcp IN SRV 0 1 465 mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
_submission._tcp IN SRV 0 1 587 mail.example.org. (Ihr ${MAILCOW_HOSTNAME})
```

## Testen

Hier finden Sie einige Tools, mit denen Sie Ihre DNS-Konfiguration überprüfen können:

- [MX Toolbox](https://mxtoolbox.com/SuperTool.aspx) (DNS, SMTP, RBL)
- [port25.com](https://www.port25.com/dkim-wizard/) (DKIM, SPF)
- [Mail-Tester](https://www.mail-tester.com/) (DKIM, DMARC, SPF)
- [DMARC-Analysator](https://www.dmarcanalyzer.com/spf/checker/) (DMARC, SPF)
- [MultiRBL.valli.org](http://multirbl.valli.org/) (DNSBL, RBL, FCrDNS)

## Verschiedenes

### Optionale DMARC-Statistiken

Wenn Sie an Statistiken interessiert sind, können Sie sich zusätzlich bei einem der vielen unten aufgeführten DMARC-Statistikdienste anmelden - oder Ihre eigene Statistik selbst hosten.

!!! tip "Tipp"
    Es ist zu bedenken, dass wenn Sie DMARC-Statistik-Berichte an Ihren mailcow-Server anfordern und Ihr mailcow-Server nicht korrekt für den Empfang dieser Berichte konfiguriert ist, Sie möglicherweise keine genauen und vollständigen Ergebnisse erhalten. Bitte erwägen Sie die Verwendung einer alternativen E-Mail-Domain für den Empfang von DMARC-Berichten.

Es ist erwähnenswert, dass die folgenden Vorschläge keine umfassende Liste aller verfügbaren Dienste und Tools sind, sondern nur eine kleine Auswahl der vielen Möglichkeiten.

- [Postmaster Tool](https://gmail.com/postmaster)
- [parsedmarc](https://github.com/domainaware/parsedmarc) (selbst gehostet)
- [Fraudmarc](https://fraudmarc.com/)
- [Postmark](https://dmarc.postmarkapp.com)
- [Dmarcian](https://dmarcian.com/)

!!! tip "Tipp"
    Diese Dienste stellen Ihnen möglicherweise einen TXT-Eintrag zur Verfügung, den Sie in Ihre DNS-Einträge einfügen müssen, so wie es der Anbieter vorschreibt. Bitte stellen Sie sicher, dass Sie die Dokumentation des Anbieters des von Ihnen gewählten Dienstes lesen, da dieser Prozess variieren kann.

### E-Mail-Test für SPF, DKIM und DMARC:

Um eine rudimentäre E-Mail-Authentifizierungsprüfung durchzuführen, senden Sie eine E-Mail an `check-auth at verifier.port25.com` und warten Sie auf eine Antwort. Sie werden einen Bericht ähnlich dem folgenden finden:

```
==========================================================
Zusammenfassung der Ergebnisse
==========================================================
SPF-Prüfung: bestanden
"iprev"-Prüfung: bestanden
DKIM-Prüfung: bestanden
DKIM-Prüfung: bestanden
SpamAssassin-Prüfung: ham

==========================================================
Einzelheiten:
==========================================================
....
```

Der vollständige Bericht enthält weitere technische Details.


### Fully Qualified Domain Name (FQDN)

[^1]: Ein **Fully Qualified Domain Name** (**FQDN**) ist der vollständige (absolute) Domänenname für einen bestimmten Computer oder Host im Internet. Der FQDN besteht aus mindestens drei Teilen, die durch einen Punkt getrennt sind: dem Hostnamen, dem Domänennamen und der Top Level Domain (kurz **TLD**). Im Beispiel `mx.mailcow.email` wäre der Hostname `mx`, der Domainname `mailcow` und die TLD `email`.
