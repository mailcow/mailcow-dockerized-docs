# Mailcow Logs Viewer

A modern, self-hosted dashboard for viewing and analyzing Mailcow mail server logs. Built for system administrators and technicians who need quick access to mail delivery status, spam analysis, and authentication failures.

## Features

- **Dashboard**: Real-time statistics, container status, and storage usage.
- **Messages**: Unified view of Postfix and Rspamd data with smart correlation.
- **Security**: Netfilter logs visualization for failed authentication attempts.
- **Domains**: SPF, DKIM, and DMARC validation and monitoring.
- **Mailbox Statistics**: Per-mailbox insights on usage and traffic.

## Installation

You can easily run the logs viewer using Docker Compose.

1.  Create a directory and enter it:
    ```bash
    mkdir mailcow-logs-viewer && cd mailcow-logs-viewer
    ```

2.  Download the `docker-compose.yml` and `.env.example` files from the repository (or create them).

3.  Configure your `.env` file with your Mailcow URL and API key.

4.  Start the container:
    ```bash
    docker compose up -d
    ```

5.  Access the dashboard at `http://your-server-ip:8080`.

For full installation instructions and configuration options, please visit the [Authentication & Monitoring Guide](https://github.com/ShlomiPorush/mailcow-logs-viewer/blob/main/documentation/Email_Authentication_Monitoring.md) or the [GitHub Repository](https://github.com/ShlomiPorush/mailcow-logs-viewer).

## Credits
Created and maintained by [Shlomi Porush](https://github.com/ShlomiPorush).
