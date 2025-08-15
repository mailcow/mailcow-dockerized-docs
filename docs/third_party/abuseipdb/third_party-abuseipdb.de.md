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

Das Paket "ipset" muss auf dem mailcow System installiert werden

## Script

Der oben gesammelte API Key wird dann in der entsprechende Variable "ABUSEIP_API_KEY" des hier herunterzuladenden Scripts verwendet:

https://github.com/DocFraggle/mailcow-scripts/blob/main/abuseipdb.sh

(bitte Code eigenständig prüfen)

Der Pfad, unter dem das Script abgelegt wird, kann frei gewählt werden. Das Script kann man dann via Cronjob maximal 5x am Tag laufen lassen, das ist das Limit des kostenlosen AbuseIPDB Accounts. In folgendem Beispiel läuft der Cronjob alle 5 Stunden: 0, 5, 10, 15 und 20 Uhr.

```
0 */5 * * * /pfad/zu/obigem/script
```

Wird das Script mit --skip-abuseipdb aufgerufen wird der Abruf der IPs bei AbuseIPDB übersprungen. Dies kann nützlich sein um das Tages-Maximum nicht auszuschöpfen um z.B. nach einem mailcow Neustart die iptables Regel wieder einzufügen.

Wird das Script mit --enable-log aufgerufen werden zusätzliche LOG Rules erzeugt. Die Logs können via journalctl/syslog eingesehen werden, je nach System.