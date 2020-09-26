DMARC Reporting done via Rspamd DMARC Module.

Offical configuration options and documentation can be found here: https://rspamd.com/doc/modules/dmarc.html

**Important:**
1. Before use config examples from this document please adjust them, change `example.com` and `Example` to your actual data
2. DMARC reporting require additional attention, especially at first days
3. Your reports for all server will be send from one reporting domain. Recommended to use parent domain of your `MAILCOW_HOSTNAME`, f.e:
    - if your `MAILCOW_HOSTNAME=mail.example.com` then Reporting `domain = "example.com";`
    - set `email` from same domain also, `email = "noreply-dmarc@example.com";`
4. This optional, but recomended step: create `noreply-dmarc` email user in mailcow to handle bounces.
    - Go to mailcow admin UI → Configuration → Mail Setup → Mailboxes → Add mailbox → Create mailbox `noreply-dmarc`, please choose correct domain
    - In case you want silently discard bounces: login in SOGo from this account and go to Preferences → Mail → Filters → Create Filter → Add action → Provide name, f.e: `noreply` and add action: Discard the message and save filter
    - In case you plan to resend a copy of reports to yourself: you need add condition to previous filter example `From is not noreply-dmarc@example.com`

## Enable DMARC Reports
Create or edit file in `data/conf/rspamd/local.d/dmarc.conf` and set content to:
```
reporting = true;
send_reports = true;
report_settings {
    org_name = "Example";
    domain = "example.com";
    email = "noreply-dmarc@example.com";
    from_name = "Example DMARC Report";
    smtp = "postfix";
    smtp_port = 25;
    helo = "rspamd";
    retries = 3;
    hscan_count = 1500
}
```

## Disable DMARC Reports
To disable reports set `send_reports` to `false`

## Send a copy reports to yourself
To get copy of own generated reports you can add `additional_address = "noreply-dmarc@pnnsoft.com";` in `report_settings` section.
This useful in case:
- you want to check that your DMARC Reports send correctly, e.g.: check that they signed by DKIM, etc.
- you want to analyze own reports to get statics data, f.e: use with ParseDMARC or other analytic system

**Important:**

Future `additional_address_bcc` is broken, lead to not sending reports to `additional_address` even while it `false`.
Do not add this option to `dmarc.conf` till bug https://github.com/rspamd/rspamd/issues/3465 will be resolved and fixed version will be used in mailcow.

## DMARC Force actions 
This module also allows to enable force actions based on sender DMARC policy to reject or quarantine emails which has failed policy.
This good from security point, but not allow whitelist broken senders. This up to your choice enable it or not.

To enable it, add to end of `data/conf/rspamd/local.d/dmarc.conf`:
```
actions {
    quarantine = "add_header";
    reject = "reject";
}
```
