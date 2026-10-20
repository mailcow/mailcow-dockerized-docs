# mailcow Report Dashboard

An add-on that collects the DMARC aggregate (RUA) and SMTP TLS (TLS-RPT) reports other mail servers send about your domains and shows them on an admin-only page inside the mailcow UI. It sends an alert mail only when something is actually wrong.

## Features

- **Integrated into mailcow**: The page is added to the Apps menu and uses mailcow's admin login. No extra container, web server or port.
- **Alerts on real problems only**: TLS failures towards your MX, DMARC failures of mail sent by your own server, unreadable reports.
- **Overview**: Status per domain, 52-week trend, results per receiver (Google, Microsoft, ...), TLS failures and spoofing sources with reverse DNS.
- **DNS assistant**: Lists the TXT records each domain needs (DMARC `rua`, TLS-RPT, external destination authorization) and checks them live.
- **Instant processing**: New reports are processed as soon as they arrive in the report mailbox.
- **Update-safe**: Only uses mailcow's extension points (`data/conf/nginx/*.custom`, App links), all 31 mailcow UI languages included.

## Installation

The add-on runs on the mailcow host (root, `python3` 3.8 or newer, systemd).

1.  Clone the repository and run the installer:
    ```bash
    git clone https://github.com/ThxGiving/mailcow-report-dashboard.git
    cd mailcow-report-dashboard
    sudo ./install.sh --alert-to postmaster@example.org
    ```

2.  Open **Apps → Delivery reports** in the mailcow UI, go to **Settings** and select or create the mailbox that should receive the reports.

3.  Add the DNS records listed by the DNS assistant, for example:

    | Record | Value |
    |---|---|
    | `_smtp._tls.example.org` TXT | `v=TLSRPTv1; rua=mailto:reports@example.org` |
    | `_dmarc.example.org` TXT | `v=DMARC1; p=quarantine; rua=mailto:reports@example.org` |

The first reports usually arrive one or two days later.

All options, updating and uninstalling are described in the [GitHub repository](https://github.com/ThxGiving/mailcow-report-dashboard).
