Using Google Workspace in a hybrid setup is possible with mailcow. With this setup you can add mailboxes on your mailcow and use Gmail's spam filtering for both your Google Workspace email accounts and your mailcow accounts.
**All mailboxes setup in Google Workspace will receive their mails as usual**, while with the hybrid approach additional Mailboxes can be setup in mailcow without any further configuration.

Optionally, in this setup, suspected spam as detected by gmail will still be sent to mailcow and stored in the Junk mail folder for your review.

## DNS Requirements
- The mx Record of your domain needs to point at the Google Workspace's mail service. Log into your Admin center and look out for the dns settings of your domain. It should look like this `aspmx.l.google.com`, `alt1.aspmx.l.google.com` etc... Contact your domain registrant to get further information on how to change mx record.



## Set up mailcow
Your mailcow needs to relay all mails to Google Workspace. 

1. Add the domain to your mailcow
2. [Add **smtp-relay.gmail.com** as relayhost](../../manual-guides/Postfix/u_e-postfix-relayhost.en.md)
3. Add **\*.google.com** to the Rspamd settings map to unconditionally accept all relayed mails from Google Workspace. (Admin > Configuration & Details > Configuration Dropdown > Rspamd Settings Map > Click "Add rule")

    + **Option 1** - Allow All mail from Google (*dangerous if you have other domains that are not relayed through gmail)*
        ```
        Rule Content:

        priority = 10;
        rcpt = "/.*/";
        hostname = "/.*google.com/";
        from = "/.*/";
        apply "default" {
          MAILCOW_WHITE = -9999.0;
        }
        symbols [
          "MAILCOW_WHITE"
        ]
        ```
    + **Option 2** Create Domain specific whitelist.
        ```
        priority = 10;
        rcpt = "/.*@YOUR_DOMAIN_HERE.COM$/";
        from = "/.*/";
        apply "default" {
          MAILCOW_WHITE = -9999.0;
        }
        symbols [
          "MAILCOW_WHITE"
        ]
        ```
5. Go to the domain settings and select the newly added host on the `Sender-dependent transports` dropdown. Enable relaying by ticking the `Relay this domain`, `Relay all recipients` and the `Relay non-existing mailboxes only.` checkboxes

!!! info
    If you selected **Option 1** your mailcow will accept all mails relayed from Google Workspace. The **inbound filtering and so the neural learning of your cow will no longer work**. Because all mails are routed through Google Workspace.

### (Optional) Route Identified Spam to Mailcow Junk Folder
Later on in this document we will set up Google Workspace to add a header when it finds spam or phishing. We will use this header to route these messages using global sieve filters.

1. Find the Global filters (Configuration > Mail Setup > Filters)
2. In the **Global Postfilter** replace:
    ```
    if header :contains "X-Spam-Flag" "YES" {
      fileinto "Junk";
    }
    ```

    With:

        
        if anyof (header :contains "X-Spam-Flag" "YES", header :contains "X-Gm-Spam" "1", header :contains "X-Gm-Phishy" "1")
        {
                fileinto "Junk";
        }     
        

## Set up Connectors in Google Workspace
All mail traffic now goes through Google Workspace. At this point the Gmail already filters all incoming and outgoing mails. Now we need to set up two connectors to relay incoming mails from Gmail to the mailcow and another one to allow mails relayed from the mailcow to  Gmail.
### Outgoing Mail
You can follow the guide [Route outgoing SMTP relay messages through Google](https://apps.google.com/supportwidget/articlehome?hl=en&article_url=https%3A%2F%2Fsupport.google.com%2Fa%2Fanswer%2F2956491%3Fhl%3Den&product_context=2956491&product_name=UnuFlow&trigger_context=a)

!!! note "Tips for Adding SMTP Relay"
    1. Under Allowed Senders Select "Only Addresses in my domains"
    2. Strongly advise selecting "Only accept mail from specified IP addresses"
    3. If you select "require SMTP authentication" then you will need to have a valid username and password. It's probably OK to skip this as users will already be authenticating with mailcow's SMTP.

### Incoming Mail - Host Setup
First you will need to set up a mail host.

1. Navigate to (Apps > Google Workspace > Gmail > Hosts)
2. Click "Add Route" and enter your mailcow hostname and port 25.

### Incoming Mail - Routing Rules
Now we will set up the routing rules to send email to mailcow. There are several ways of doing this, but I have found the most reliable to be **Default Routing** Rules.

1. Navigate to Default Routing by searching in the bar or (Apps > Google Workspace > Gmail > Default Routing)
2. Click "Add Another Rule"
3. In "Specify envelope recipients to match" select "Pattern Match" **NOTE: Google's regex seems to be case sensitive, so add (?i) to the beginning make it case-insensitive.**
    1. Enter *(?i).\*@YOUR_DOMAIN_HERE.COM*
    2. Or if you have multiple domains you can use *(?i).\*@(domain1.com|domain2.com)*
4. Under "If the envelope recipient matches the above, do the following", Select "Add X-Gm-Spam and X-Gm-Phishy headers"
5. (OPTIONAL) If you want Gmail to route SPAM to your Junk folder in mailcow, select "Also reroute Spam"
6. Under "Route" Select "Change Route" and select the router you created previously
7. Under "Options" Select "Perform this action only on non-recognized addresses" to ensure only non-gmail addresses are routed to mailcow.



## Validating
The easiest way to validate the hybrid setup is by sending a mail from the internet to a mailbox that only exists on the mailcow and vice versa.

