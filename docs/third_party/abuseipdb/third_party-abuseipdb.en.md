# AbuseIPDB Integration for Fail2Ban

## Introduction

AbuseIPDB is an online service dedicated to the identification and reporting of malicious IP addresses. It provides a platform where users can collect and share information about suspicious IP activities, aiding in the effective combat against cyber threats. The database is constantly updated with user submissions, allowing security professionals and network administrators to proactively safeguard their systems against potential attacks. With various API integrations and search functionalities, AbuseIPDB serves as a valuable resource for enhancing network security and preventing abuse from cybercriminal activities.

## Prerequisites
### Create a free AbuseIPDB account

To use the AbuseIPDB API, you must create a free account: https://www.abuseipdb.com/register

After successful registration, you can create a new API key in the login area under the "API" tab. This key is required for the script below.

### Creating a Read-Write Access API Key in Mailcow
A read-write access API key for Mailcow is also needed for the script below.

After logging in as an admin to the Mailcow UI, navigate to the page:

System -> Configuration

Switch to the "Access" tab, where you can expand the API overview using the "+" symbol next to "API". On the right side, you will find the settings for "Read-Write Access". Here, you need to enter the IP address (possibly both IPv4 and IPv6) of the host where the script will be executed later. Make sure to check the "Enable API" checkbox and then save the changes.

You will then see the generated API key in the corresponding field.

## Script

The API keys collected above are then used in the corresponding variables "ABUSEIP_API_KEY" and "MAILCOW_API_KEY" in the following script. The FQDN of your Mailcow server should be entered in "MAILSERVER_FQDN".

```
#!/bin/bash

# Adjust the values of the following variables
ABUSEIP_API_KEY="XXXXXXXXXXXXXXXX"
MAILCOW_API_KEY="YYYYYYYYYYYYYYYY"
MAILSERVER_FQDN="your.mail.server"

echo "Retrieve IPs from AbuseIPDB"
curl -sG https://api.abuseipdb.com/api/v2/blacklist \
  -d confidenceMinimum=90 \
  -d plaintext \
  -H "Key: $ABUSEIP_API_KEY" \
  -H "Accept: application/json" \
  -o /tmp/abuseipdb_blacklist.txt

# Capture the exit code from curl
exit_code=$?

# Check if curl encountered an error
if [ $exit_code -ne 0 ]; then
  echo "Curl encountered an error with exit code $exit_code while rertieving the AbuseIPDB IPs"
  exit 1
fi

BLACKLIST=$(awk '{if (index($0, ":") > 0) printf "%s%s/128", sep, $0; else printf "%s%s/32", sep, $0; sep=","} END {print ""}' /tmp/abuseipdb_blacklist.txt)

cat <<EOF > /tmp/request.json
{
  "items":["none"],
  "attr": {
    "blacklist": "$BLACKLIST"
  }
}
EOF

echo "Add IPs to Fail2Ban" 
curl -s --include \
     --request POST \
     --header "Content-Type: application/json" \
     --header "X-API-Key: $MAILCOW_API_KEY" \
     --data-binary @/tmp/request.json \
     "https://${MAILSERVER_FQDN}/api/v1/edit/fail2ban"

# Capture the exit code from curl
exit_code=$?

# Check if curl encountered an error
if [ $exit_code -ne 0 ]; then
  echo "Curl encountered an error with exit code $exit_code while rertieving the AbuseIPDB IPs"
  exit 1
fi

echo -e "\n\nAll done, have fun"
```

You can run the script via a cron job up to 5 times a day, which is the limit set by AbuseIPDB. In the following example, the cron job runs every 5 hours at 0, 5, 10, 15, and 20 o'clock.

```
0 */5 * * * /path/to/the/above/script
```