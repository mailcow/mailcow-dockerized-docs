Die Verwendung von Microsoft Exchange in einem hybriden Setup ist mit mailcow möglich. Mit diesem Setup können Sie Postfächer auf Ihrer mailcow hinzufügen und trotzdem [Exchange Online Protection](https://docs.microsoft.com/microsoft-365/security/office-365-security/exchange-online-protection-overview?view=o365-worldwide) nutzen.
**Alle Postfächer, die in Exchange eingerichtet sind, erhalten ihre Mails wie gewohnt**, während mit dem hybriden Ansatz zusätzliche Postfächer in mailcow ohne weitere Konfiguration eingerichtet werden können.

Dieses Setup ist sehr praktisch, wenn Sie die [Office 365 Sicherheitsvorgaben](https://docs.microsoft.com/azure/active-directory/fundamentals/concept-fundamentals-security-defaults) aktiviert haben und Anwendungen von Drittanbietern sich nicht mehr in Ihre Postfächer mit einer der [unterstützten Methoden](https://docs.microsoft.com/exchange/mail-flow-best-practices/how-to-set-up-a-multifunction-device-or-application-to-send-email-using-microsoft-365-or-office-365) einloggen können.


## Voraussetzungen
- Der mx Record Ihrer Domain muss auf den Exchange Mail Service zeigen. Melden Sie sich in Ihrem Admin-Center an und suchen Sie in den DNS-Einstellungen Ihrer Domäne nach Ihrer personalisierten Gateway-Domäne. Sie sollte wie folgt aussehen: `contoso-com.mail.protection.outlook.com`. Wenden Sie sich an Ihren Domainregistrator, um weitere Informationen zur Änderung des mx-Eintrags zu erhalten.
- Die Domäne, für die Sie zusätzliche Postfächer haben möchten, muss in Exchange als "Interne Relay-Domäne" eingerichtet werden.
    1. Melden Sie sich bei Ihrem [Exchange Admin Center](https://admin.exchange.microsoft.com) an.
    2. Wählen Sie den Bereich "Mailflow" und klicken Sie auf "Akzeptierte Domänen".
    3. Wählen Sie die Domäne aus und schalten Sie sie von "autorisiert" auf "internes Relais" um.


## Einrichten der mailcow
Ihre mailcow muss alle Mails an Ihren personalisierten Exchange Host weiterleiten. Es ist die gleiche Host-Adresse, die wir bereits für den mx Record gesucht haben.

1. Fügen Sie die Domain zu Ihrer mailcow hinzu
2. [Fügen Sie Ihre personalisierte Exchange Host Adresse als relayhost hinzu](../../manual-guides/Postfix/u_e-postfix-relayhost.de.md)
3. Fügen Sie Ihre personalisierte Exchange Host Adresse als Weiterleitungshost hinzu, um alle weitergeleiteten Mails von Exchange bedingungslos zu akzeptieren. (Admin > Konfiguration & Details > Konfigurations-Dropdown > Weiterleitungshosts)
4. Gehen Sie zu den Domäneneinstellungen und wählen Sie den neu hinzugefügten Host in der Dropdown-Liste "Absenderabhängige Transporte" aus. Aktivieren Sie die Weiterleitung, indem Sie die Kontrollkästchen "Diese Domäne weiterleiten", "Alle Empfänger weiterleiten" und "Nur nicht vorhandene Postfächer weiterleiten" aktivieren.

!!! info
    Von nun an wird Ihre mailcow alle Mails akzeptieren, die von Exchange weitergeleitet werden. Die **Eingangsfilterung und damit das neuronale Lernen Ihrer Kuh wird nicht mehr funktionieren**. Da alle Mails über Exchange geroutet werden, wird der [Filterungsprozess dort abgewickelt](https://docs.microsoft.com/exchange/antispam-and-antimalware/antispam-and-antimalware?view=exchserver-2019).


## Connectors in Exchange einrichten
Der gesamte Mailverkehr läuft nun über Exchange. Zu diesem Zeitpunkt filtert der Exchange Online-Schutz bereits alle ein- und ausgehenden Mails. Jetzt müssen wir zwei Konnektoren einrichten, um eingehende Mails von unserem Exchange Service an die mailcow weiterzuleiten und einen weiteren, um Mails zuzulassen, die von der mailcow an unseren Exchange Service weitergeleitet werden. Sie können der [offiziellen Anleitung von Microsoft] folgen (https://docs.microsoft.com/exchange/mail-flow-best-practices/use-connectors-to-configure-mail-flow/set-up-connectors-to-route-mail#2-set-up-a-connector-from-microsoft-365-or-office-365-to-your-email-server).

!!! warning "Warnung"
    Für den Connector, der die Mails von Ihrer mailcow zu Exchange weiterleitet, bietet Microsoft zwei Möglichkeiten der Authentifizierung an. Der empfohlene Weg ist die Verwendung eines tls-Zertifikats, das mit einem Subject-Namen konfiguriert ist, der mit einer akzeptierten Domäne in Exchange übereinstimmt. Andernfalls müssen Sie die Authentifizierung mit der statischen IP-Adresse Ihrer mailcow wählen.

## Validierung
Der einfachste Weg, die hybride Einrichtung zu überprüfen, ist das Senden einer Mail aus dem Internet an eine Mailbox, die nur auf der mailcow existiert und andersherum.

### Allgemeine Probleme
- Die Validierung des Connectors von Exchange zu Ihrer mailcow schlug fehl mit `550 5.1.10 RESOLVER.ADR.RecipientNotFound; Recipient test@contoso.com not found by SMTP address lookup`  
**Mögliche Lösung:** Ihre Domäne ist nicht als "internes Relay" eingerichtet. Exchange kann daher den Empfänger nicht finden.
- Mails, die von der mailcow an eine Mailbox im Internet gesendet werden, können nicht zugestellt werden. Non Delivery Report mit Fehler `550 5.7.64 TenantAttribution; Relay Access Denied`  
**Mögliche Lösung:** Die Authentifizierungsmethode ist fehlgeschlagen. Stellen Sie sicher, dass der Betreff des Zertifikats mit einer akzeptierten Domäne in Exchange übereinstimmt. Versuchen Sie stattdessen die Authentifizierung über eine statische IP.

Microsoft-Anleitung für die Einrichtung des Connectors und zusätzliche Anforderungen: https://docs.microsoft.com/exchange/mail-flow-best-practices/use-connectors-to-configure-mail-flow/set-up-connectors-to-route-mail#prerequisites-for-your-on-premises-email-environment

