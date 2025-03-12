# AbuseIPDB Integration für Fail2Ban

## Einführung

AbuseIPDB ist ein Online-Dienst, der sich auf die Erkennung und Meldung von schädlichen IP-Adressen spezialisiert hat. Er bietet eine Plattform, auf der Nutzer Informationen über verdächtige IP-Adressen sammeln und teilen können, um Cyberbedrohungen effektiver zu bekämpfen. Die Datenbank von AbuseIPDB wird kontinuierlich durch Benutzerberichte aktualisiert, was es Sicherheitsfachleuten und Netzwerkadministratoren ermöglicht, ihre Systeme proaktiv gegen potenzielle Angriffe zu schützen. Mit verschiedenen API-Integrationen und Suchfunktionen bietet AbuseIPDB eine wertvolle Ressource für die Verbesserung der Netzwerksicherheit und die Vermeidung von Missbrauch durch cyberkriminelle Aktivitäten.

Über die kostenlos verwendbare AbuseIPDB API können die gelisteten IPs abgerufen und dann über die Mailcow API an Fail2Ban übergeben werden.

## Vorraussetzungen
### Erstellung eines kostenlosen Kontos bei AbuseIPDB

Um die API von AbuseIPDB nutzen zu können muss ein kostenloses Konto erstellt werden: https://www.abuseipdb.com/register

Nach erfolgreicher Registrierung kann man im Login Bereich über den "API" Reiter einen neuen API Key erstellen. Dieser wird für das u.g. Script benötigt.

### Erstellung eines Lese-Schreib-Zugriff API Keys in Mailcow

Ebenfalls für u.g. Script wird ein Lese-Schreib-Zugriff API Key für Mailcow benötigt.
Nach Login als Admin in die Mailcow UI wird auf die Seite

System -> Konfiguration

gewechselt. Auf dem "Zugang" Reiter wird über das "+" Symbol neben "API" die API Übersicht aufgeklappt.
Dort finden sich auf der rechten Seite die Einstellungen für den "Lese-Schreib-Zugriff". Hier muss die IP Adresse (ggf. IPv4 und IPv6) des Hosts eingetragen werden auf dem das u.g. später ausgeführt wird.
Der Haken bei "API aktivieren" muss angeklickt werden und dann die Änderungen speichern.

Den erzeugten API-Key sieht man dann im entsprechenden Feld.

## Script

Die oben gesammelten API Keys werden dann in den entsprechenden Variablen "ABUSEIP_API_KEY" und "MAILCOW_API_KEY" des folgenden Scripts verwendet. Der FQDN des eigenen Mailcow Servers wird bei "MAILSERVER_FQDN" eingetragen.

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

Das Script kann man dann via Cronjob maximal 5x am Tag laufen lassen, das ist das Limit von AbuseIPDB. In folgendem Beispiel läuft der Cronjob alle 5 Stunden: 0, 5, 10, 15 und 20 Uhr.

```
0 */5 * * * /pfad/zu/obigem/script
```