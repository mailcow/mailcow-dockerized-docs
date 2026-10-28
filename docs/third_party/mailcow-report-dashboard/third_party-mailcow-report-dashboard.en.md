# DMARC/TLS Reports for mailcow

An add-on that collects the DMARC aggregate (RUA) and SMTP TLS (TLS-RPT) reports other mail servers send about your domains and shows them on an admin-only page inside the mailcow UI. It runs as one small container next to mailcow and sends an alert mail only when something is actually wrong.

## Features

- **Integrated into mailcow**: The page lives at `/admin/dmarc/`, uses mailcow's admin login and can be added to the Apps menu (shown to admins only). No extra web server or port.
- **Least privilege**: The container reads the report mailbox over IMAP with an app password limited to that mailbox. No docker socket, database or vmail access.
- **Alerts on real problems only**: TLS failures towards your MX, DMARC failures of mail sent by your own server, unreadable reports.
- **Overview**: Status per domain, 52-week trend, results per receiver (Google, Microsoft, ...), TLS failures and spoofing sources with reverse DNS.
- **DNS assistant**: Lists the TXT records each domain needs (DMARC `rua`, TLS-RPT, external destination authorization) and checks them live.
- **Real time**: New reports are processed within seconds (IMAP IDLE).
- **Update-safe**: Only uses mailcow's extension points; all 31 mailcow UI languages included.

## Installation

1.  Add the service to `docker-compose.override.yml` in your mailcow folder (create the file if it does not exist):

    ```yaml
    services:
      reports-mailcow:
        image: ghcr.io/thxgiving/dmarc-tls-reports-for-mailcow:latest
        restart: always
        depends_on:
          - nginx-mailcow
        environment:
          - SLUG=admin/dmarc
          - MAILCOW_HOSTNAME=${MAILCOW_HOSTNAME}
          - HTTPS_PORT=${HTTPS_PORT:-443}
          - SNAT_TO_SOURCE=${SNAT_TO_SOURCE:-}
          - SNAT6_TO_SOURCE=${SNAT6_TO_SOURCE:-}
          - TZ=${TZ}
        volumes:
          - ./data/web/admin/dmarc:/page
          - ./data/conf/nginx:/nginx-conf
          - ./data/web/css/build:/mailcow-css
          - reports-vol-1:/data
        networks:
          mailcow-network:
            aliases:
              - reports

    volumes:
      reports-vol-1:
    ```

2.  Start it:

    === "docker compose (Plugin)"
    
        ``` bash
        docker compose up -d
        ```
    
    === "docker-compose (Standalone)"
    
        ``` bash
        docker-compose up -d
        ```

3.  Open `https://<mailcow-host>/admin/dmarc/` as admin and complete the setup assistant (report mailbox, alert recipients, Apps menu entry).

4.  Add the DNS records listed by the DNS assistant, for example:

    | Record | Value |
    |---|---|
    | `_smtp._tls.example.org` TXT | `v=TLSRPTv1; rua=mailto:reports@example.org` |
    | `_dmarc.example.org` TXT | `v=DMARC1; p=quarantine; rua=mailto:reports@example.org` |

The first reports usually arrive one or two days later.

Updating, uninstalling and all details are described in the [GitHub repository](https://github.com/ThxGiving/dmarc-tls-reports-for-mailcow).
