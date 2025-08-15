# AbuseIPDB Integration for mailcow
**_(Community support only)_**
## Introduction

AbuseIPDB is an online service dedicated to the identification and reporting of malicious IP addresses. It provides a platform where users can collect and share information about suspicious IP activities, aiding in the effective combat against cyber threats. The database is constantly updated with user submissions, allowing security professionals and network administrators to proactively safeguard their systems against potential attacks. With various API integrations and search functionalities, AbuseIPDB serves as a valuable resource for enhancing network security and preventing abuse from cybercriminal activities.

## Prerequisites
### Create a free AbuseIPDB account

To use the AbuseIPDB API, you must create a free account: https://www.abuseipdb.com/register

After successful registration, you can create a new API key in the login area under the "API" tab. This key is required for the script below.

### Required packages

The package "ipset" has to be installed on your mailcow system.

## Script

The API key collected above is then used in the corresponding variable "ABUSEIP_API_KEY" a in the following script:

https://github.com/DocFraggle/mailcow-scripts/blob/main/abuseipdb.sh

(please check the code before using it.)

The script can be placed in any path you choose. You can run the script via a cron job up to 5 times a day, which is the limit set for the free AbuseIPDB account. In the following example, the cron job runs every 5 hours at 0, 5, 10, 15, and 20 o'clock.

```
0 */5 * * * /path/to/the/above/script
```

If the script is run with --skip-abuseipdb, the retrieval of IPs from AbuseIPDB is skipped. This can be useful to avoid reaching the daily limit, for example, when reinserting the iptables rule after a mailcow restart.

If the script is run with --enable-log, addtitional LOG rules are created. Logs can be found in journalctl/syslog, depending on the system.