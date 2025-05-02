# AbuseIPDB Integration für mailcow
**_(Nur Community Support)_**
## Einführung

AbuseIPDB ist ein Online-Dienst, der sich auf die Erkennung und Meldung von schädlichen IP-Adressen spezialisiert hat. Er bietet eine Plattform, auf der Nutzer Informationen über verdächtige IP-Adressen sammeln und teilen können, um Cyberbedrohungen effektiver zu bekämpfen. Die Datenbank von AbuseIPDB wird kontinuierlich durch Benutzerberichte aktualisiert, was es Sicherheitsfachleuten und Netzwerkadministratoren ermöglicht, ihre Systeme proaktiv gegen potenzielle Angriffe zu schützen. Mit verschiedenen API-Integrationen und Suchfunktionen bietet AbuseIPDB eine wertvolle Ressource für die Verbesserung der Netzwerksicherheit und die Vermeidung von Missbrauch durch cyberkriminelle Aktivitäten.

Über die kostenlos verwendbare AbuseIPDB API können die gelisteten IPs abgerufen und dann über die mailcow API an Fail2Ban übergeben werden.

## Vorraussetzungen
### Erstellung eines kostenlosen Kontos bei AbuseIPDB

Um die API von AbuseIPDB nutzen zu können muss ein kostenloses Konto erstellt werden: https://www.abuseipdb.com/register

Nach erfolgreicher Registrierung kann man im Login Bereich über den "API" Reiter einen neuen API Key erstellen. Dieser wird für das u.g. Script benötigt.

### Erforderliche Pakete

Die Pakete "jq" und "ipset" müssen auf dem mailcow System installiert werden

## Script

Der oben gesammelte API Key wird dann in der entsprechende Variable "ABUSEIP_API_KEY" des folgenden Scripts verwendet.
(Die aktuellste Version gibt es im GitHub Repo: https://github.com/DocFraggle/mailcow-scripts/blob/main/abuseipdb.sh, bitte Code eigenständig prüfen)

```
#!/bin/bash

# Adjust the values of the following variables
ABUSEIP_API_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXX"
ABUSEIPDB_LIST="/tmp/abuseipdb_blacklist.txt"

show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  --skip-abuseipdb     Skip AbuseIPDB call, use last output file"
  echo "  --enable-log         Add an iptables LOG rule to show drops in journald/syslog"
  echo "  -h, --help           Show this help message"
}

SKIP_ABUSEIPDB=false
ENABLE_LOG=false

for arg in "$@"; do
  case $arg in
    --skip-abuseipdb)
      SKIP_ABUSEIPDB=true
      ;;
    --enable-log)
      ENABLE_LOG=true
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      show_help
      exit 1
      ;;
  esac
done

# Check if ipset installed
if ! command -v ipset >/dev/null 2>&1; then
  echo "ipset binary NOT found, please install package"
  exit 1
fi

if [ "$SKIP_ABUSEIPDB" = false ]
then
  echo "Retrieve IPs from AbuseIPDB"
  curl -sG https://api.abuseipdb.com/api/v2/blacklist \
    -d confidenceMinimum=90 \
    -d plaintext \
    -H "Key: $ABUSEIP_API_KEY" \
    -H "Accept: application/json" \
    -o $ABUSEIPDB_LIST

  # Capture the exit code from curl
  exit_code=$?

  # Check if curl encountered an error
  if [ $exit_code -ne 0 ]; then
    echo "Curl encountered an error with exit code $exit_code while rertieving the AbuseIPDB IPs"
    exit 1
  fi
else
  if [ -f $ABUSEIPDB_LIST ]
  then
    echo "Skipping AbuseIPDB call"
  else
    echo "Option to skip AbuseIPDB call was chosen, but file $ABUSEIPDB_LIST does not exist"
    exit 1
  fi
fi

IPSET_V4="abuseipdb_blacklist_v4"
IPSET_V6="abuseipdb_blacklist_v6"

echo "Ensure the ipsets exist"
# Create IPv4 ipset if missing
if ! ipset list $IPSET_V4 &>/dev/null; then
  echo "Creating ipset $IPSET_V4"
  ipset create $IPSET_V4 hash:ip family inet
fi
# Create IPv6 ipset if missing
if ! ipset list $IPSET_V6 &>/dev/null; then
  echo "Creating ipset $IPSET_V6"
  ipset create $IPSET_V6 hash:ip family inet6
fi

echo "Flush existing ipset entries"
ipset flush $IPSET_V4
ipset flush $IPSET_V6

echo "Process each IP and add it to the appropriate ipset"
while IFS= read -r ip; do
  [[ -z "$ip" ]] && continue  # Skip empty lines
  if [[ "$ip" =~ : ]]
  then
    ipset add $IPSET_V6 "$ip" 2>/dev/null
  else
    ipset add $IPSET_V4 "$ip" 2>/dev/null
  fi
done < $ABUSEIPDB_LIST

echo "Ensure iptables/ip6tables rules exist at the top"

ensure_rule_at_top() {
  local chain=$1
  local rule=$2
  local cmd=$3  # iptables or ip6tables
  local log=$4

  if ! $cmd -S $chain | grep -q -- "$rule"; then
    eval "$cmd -I $chain 1 $rule"  # Add rule if missing
  else
    FIRST_RULE=$($cmd -S $chain | sed -n '2p')
    if [[ "$FIRST_RULE" != *"$rule"* ]]; then
      
      for line in $($cmd -nL MAILCOW --line-numbers | grep 'MAILCOW-DROP' | awk '{print $1}' | sort -rn); do
        $cmd -D MAILCOW "$line"
      done
      eval "$cmd -D $chain $rule"  # Remove old rule
      eval "$cmd -I $chain 1 $rule"  # Reinsert at the top
    fi
  fi
}

# iptables variables
CHAIN_NAME="MAILCOW" # DO NOT CHANGE THIS UNTIL YOU KNOW WHAT YOU'RE DOING! :)
LOG_PREFIX="MAILCOW-DROP: " # Change this to your liking

IPTABLES_RULE_V4="-m set --match-set $IPSET_V4 src -j DROP"
IPTABLES_RULE_V6="-m set --match-set $IPSET_V6 src -j DROP"

ensure_rule_at_top "$CHAIN_NAME" "$IPTABLES_RULE_V4" "iptables"
ensure_rule_at_top "$CHAIN_NAME" "$IPTABLES_RULE_V6" "ip6tables"

if [ "$ENABLE_LOG" = true ]
then
  IPTABLES_RULE_V4_LOG="-m set --match-set abuseipdb_blacklist_v4 src -j LOG --log-prefix '$LOG_PREFIX' --log-level 4"
  IPTABLES_RULE_V6_LOG="-m set --match-set abuseipdb_blacklist_v6 src -j LOG --log-prefix '$LOG_PREFIX' --log-level 4"
  
  # Remove all LOG rules
  for cmd in iptables ip6tables
  do
    for line in $($cmd -nL $CHAIN_NAME --line-numbers | grep '$LOG_PREFIX' | awk '{print $1}' | sort -rn)
    do
      $cmd -D $CHAIN_NAME "$line" >/dev/null
    done
  done
  
  ensure_rule_at_top "$CHAIN_NAME" "$IPTABLES_RULE_V4_LOG" "iptables"
  ensure_rule_at_top "$CHAIN_NAME" "$IPTABLES_RULE_V6_LOG" "ip6tables"
else
  # Remove all potential LOG rules as argument wasn't specified
  for cmd in iptables ip6tables
  do
    for line in $($cmd -nL $CHAIN_NAME --line-numbers | grep '$LOG_PREFIX' | awk '{print $1}' | sort -rn)
    do
      $cmd -D $CHAIN_NAME "$line" >/dev/null
    done
  done
fi

# Save ipset rules to persist across reboots
ipset save > /etc/ipset.rules

echo -e "\n\nAll done, have fun.\n\nCheck your current iplist entries with 'ipset list | less'"
```

Das Script kann man dann via Cronjob maximal 5x am Tag laufen lassen, das ist das Limit des kostenlosen AbuseIPDB Accounts. In folgendem Beispiel läuft der Cronjob alle 5 Stunden: 0, 5, 10, 15 und 20 Uhr.

```
0 */5 * * * /pfad/zu/obigem/script
```

Wird das Script mit --skip-abuseipdb aufgerufen wird der Abruf der IPs bei AbuseIPDB übersprungen. Dies kann nützlich sein um das Tages-Maximum nicht auszuschöpfen um z.B. nach einem mailcow Neustart die iptables Regel wieder einzufügen.

Wird das Script mit --enable-log aufgerufen werden zusätzliche LOG Rules erzeugt. Die Logs können via journalctl/syslog eingesehen werden, je nach System.