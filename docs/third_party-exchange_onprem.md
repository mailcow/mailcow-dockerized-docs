Using Microsoft Exchange in a hybrid setup is possible with mailcow. With this setup you can add mailboxes on your mailcow and still use [Exchange Online Protection](https://docs.microsoft.com/microsoft-365/security/office-365-security/exchange-online-protection-overview?view=o365-worldwide).
**All mailboxes setup in Exchange will receive their mails as usual**, while with the hybrid approach additional Mailboxes can be setup in mailcow without any further configuration.

This setup becomes very handy if you have enabled the [Office 365 security defaults](https://docs.microsoft.com/azure/active-directory/fundamentals/concept-fundamentals-security-defaults) and third party applications can no longer login into your mailboxes by any of the [supported methods](https://docs.microsoft.com/exchange/mail-flow-best-practices/how-to-set-up-a-multifunction-device-or-application-to-send-email-using-microsoft-365-or-office-365).


## Requirements
- The mx Record of your domain needs to point at the Exchange mail service. Log into your Admin center and look out for the dns settings of your domain to find your personalized gateway domain. It should look like this `contoso-com.mail.protection.outlook.com`. Contact your domain registrant to get further information on how to change mx record.
- The domain you want to have additional mailboxes for must be setup as `internal relay domain` in Exchange.
    1. Log in to your [Exchange Admin Center](https://admin.exchange.microsoft.com)
    2. Select the `mail flow` pane and click on `accepted domains`
    3. Select the domain and switch it from `authorative` to `internal relay`
    
    
## Set up the mailcow
Your mailcow needs to relay all mails to your personalized Exchange Host. It is the same host address we already looked up for the mx Record.

1. Add the domain to your mailcow
2. [Add your personalized Exchange Host address as relayhost](/firststeps-relayhost)
3. Add your personalized Exchange Host address as forwarding host to unconditionally accepted all relayed mails from Exchange. (Admin > Configuration & Details > Configuration Dropdown > Forwarding Hosts)
4. Go to the domain settings and select the newly added host on the `Sender-dependent transports` dropdown. Enable relaying by ticking the `Relay this domain`, `Relay all recipients` and the `Relay non-existing mailboxes only.` checkboxes

!!! info
    From now on your mailcow will accept all mails relayed from Exchange. The **inbound filtering and so the neural learning of your cow will no longer work**. Because all mails are routed through Exchange the [filtering process is handled there](https://docs.microsoft.com/exchange/antispam-and-antimalware/antispam-and-antimalware?view=exchserver-2019).


## Set up Connectors in Exchange
All mail traffic now goes through Exchange. At this point the Exchange Online Protection already filters all incoming and outgoing mails. Now we need to set up two connectors to relay incoming mails from our Exchange Service to the mailcow and another one to allow mails relayed from the mailcow to our exchange service. You can follow the [official guide from Microsoft](https://docs.microsoft.com/exchange/mail-flow-best-practices/use-connectors-to-configure-mail-flow/set-up-connectors-to-route-mail#2-set-up-a-connector-from-microsoft-365-or-office-365-to-your-email-server).

!!! warning
    For the connector that handles mails from your mailcow to Exchange Microsoft offers two ways of authenticating it. The recommended way is to use a tls certificate configured with a subject name that matches an accepted domain in Exchange. Otherwise you need to choose authentication with the static ip address of your mailcow.
    
## Validating
The easiest way to validate the hybrid setup is by sending a mail from the internet to a mailbox that only exists on the mailcow and vice versa.

### Common Issues
- The connector validation from Exchange to your mailcow failed with `550 5.1.10 RESOLVER.ADR.RecipientNotFound; Recipient test@contoso.com not found by SMTP address lookup`  
**Possible Solution:** Your domain is not set up as `internal relay`. Exchange therefore cannot find the recipient
- Mails sent from the mailcow to a mailbox in the internet cannot be sent. Non Delivery Report with error `550 5.7.64 TenantAttribution; Relay Access Denied`  
**Possible Solution:** The authentication method failed. Make sure the certificate subject matches an accepted domain in Exchange. Try authenticating by static ip instead.

Microsoft Guide for the connector setup and additional requirements: https://docs.microsoft.com/exchange/mail-flow-best-practices/use-connectors-to-configure-mail-flow/set-up-connectors-to-route-mail#prerequisites-for-your-on-premises-email-environment