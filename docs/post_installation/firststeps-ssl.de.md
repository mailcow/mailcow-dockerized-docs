## Let's Encrypt (wird mitgeliefert)

Der "acme-mailcow" Container wird versuchen, ein LE-Zertifikat für `${MAILCOW_HOSTNAME}`, `autodiscover.ADDED_MAIL_DOMAIN` und `autoconfig.ADDED_MAIL_DOMAIN` zu erhalten.

!!! warning
    mailcow **muss** auf Port 80 verfügbar sein, damit der acme-Client funktioniert. Unsere Reverse Proxy Beispielkonfigurationen decken das ab. Sie können auch jeden externen ACME-Client (z.B. certbot) verwenden, um Zertifikate zu erhalten, aber Sie müssen sicherstellen, dass sie an den richtigen Ort kopiert werden und ein Post-Hook die betroffenen Container neu lädt. Weitere Informationen finden Sie in der Reverse Proxy-Dokumentation.

Standardmäßig, d.h. **0 Domains** sind zu mailcow hinzugefügt, wird es versuchen, ein Zertifikat für `${MAILCOW_HOSTNAME}` zu erhalten.

Für jede hinzugefügte Domain wird versucht, `autodiscover.ADDED_MAIL_DOMAIN` und `autoconfig.ADDED_MAIL_DOMAIN` in die IPv6-Adresse oder - falls IPv6 in der Domain nicht konfiguriert ist - in die IPv4-Adresse aufzulösen. Wenn dies gelingt, wird ein Name als SAN zur Zertifikatsanforderung hinzugefügt.

Nur Namen, die validiert werden können, werden als SAN hinzugefügt.

Für jede Domain, die Sie entfernen, wird das Zertifikat verschoben und ein neues Zertifikat angefordert. Es ist nicht möglich, Domains in einem Zertifikat zu behalten, wenn wir nicht in der Lage sind, die Challenge für diese zu validieren.

Wenn Sie den ACME-Client neu starten wollen, verwenden Sie `docker-compose restart acme-mailcow` und überwachen Sie die Protokolle mit `docker-compose logs --tail=200 -f acme-mailcow`.

### Zusätzliche Domain-Namen

Bearbeiten Sie "mailcow.conf" und fügen Sie einen Parameter `ADDITIONAL_SAN` wie folgt hinzu:

Verwenden Sie keine Anführungszeichen (`"`) und keine Leerzeichen zwischen den Namen!

```
ADDITIONAL_SAN=smtp.*,cert1.example.com,cert2.example.org,whatever.*
```

Jeder Name wird anhand seiner IPv6-Adresse oder - wenn IPv6 in Ihrer Domäne nicht konfiguriert ist - anhand seiner IPv4-Adresse überprüft.

Ein Wildcard-Name wie `smtp.*` wird versuchen, ein smtp.DOMAIN_NAME SAN für jede zu mailcow hinzugefügte Domain zu erhalten.

Führen Sie `docker-compose up -d` aus, um betroffene Container automatisch neu zu erstellen.

!!! info
    Die Verwendung anderer Namen als `MAILCOW_HOSTNAME` für den Zugriff auf das mailcow UI kann weitere Konfiguration erfordern.

Wenn Sie planen, einen anderen Servernamen als `MAILCOW_HOSTNAME` für den Zugriff auf die mailcow UI zu verwenden (z.B. durch Hinzufügen von `mail.*` zu `ADDITIONAL_SAN`), stellen Sie sicher, dass Sie diesen Namen in mailcow.conf über `ADDITIONAL_SERVER_NAMES` eintragen. Die Namen müssen durch Kommas getrennt sein und **dürfen** keine Leerzeichen enthalten. Wenn Sie diesen Schritt auslassen, kann mailcow mit einer falschen Seite antworten.

```
ADDITIONAL_SERVER_NAMES=webmail.domain.tld,other.example.tld
```

Führen Sie `docker-compose up -d` aus, um es anzuwenden.

### Erneuerung erzwingen

Um eine Erneuerung zu erzwingen, müssen Sie eine Datei namens `force_renew` erstellen und den `acme-mailcow` Container neu starten:

```
cd /opt/mailcow-dockerized
touch data/assets/ssl/force_renew
docker-compose restart acme-mailcow
# Prüfen Sie nun die Logs auf eine Erneuerung
docker-compose logs --tail=200 -f acme-mailcow
```

Die Datei wird automatisch gelöscht.

### Validierungsfehler und wie man die Validierung überspringt

Sie können die **IP-Überprüfung** überspringen, indem Sie `SKIP_IP_CHECK=y` in mailcow.conf setzen (keine Anführungszeichen). Seien Sie gewarnt, dass eine Fehlkonfiguration dazu führt, dass Sie von Let's Encrypt eingeschränkt werden! Dies ist vor allem für Multi-IP-Setups nützlich, bei denen der IP-Check die falsche Quell-IP-Adresse zurückgeben würde. Aufgrund der Verwendung von dynamischen IPs für acme-mailcow ist Source-NAT bei Neustarts nicht konsistent.

Wenn Sie Probleme mit der "HTTP-Validierung" haben, aber Ihre IP-Adressbestätigung erfolgreich ist, verwenden Sie höchstwahrscheinlich firewalld, ufw oder eine andere Firewall, die Verbindungen von `br-mailcow` zu Ihrem externen Interface verbietet. Sowohl firewalld als auch ufw lassen dies standardmäßig nicht zu. Es reicht oft nicht aus, diese Firewall-Dienste einfach zu stoppen. Sie müssen mailcow stoppen (`docker-compose down`), den Firewall-Dienst stoppen, die Ketten flushen und Docker neu starten.

Sie können diese Validierungsmethode auch überspringen, indem Sie `SKIP_HTTP_VERIFICATION=y` in "mailcow.conf" setzen. Seien Sie gewarnt, dass dies nicht zu empfehlen ist. In den meisten Fällen wird die HTTP-Überprüfung übersprungen, um unbekannte NAT-Reflection-Probleme zu umgehen, die durch das Ignorieren dieser spezifischen Netzwerk-Fehlkonfiguration nicht gelöst werden. Wenn Sie Probleme haben, TLSA-Einträge in der DNS-Übersicht innerhalb von mailcow zu generieren, haben Sie höchstwahrscheinlich Probleme mit NAT-Reflexion, die Sie beheben sollten.

Wenn du einen SKIP_* Parameter geändert hast, führe `docker-compose up -d` aus, um deine Änderungen zu übernehmen.

### Deaktivieren Sie Let's Encrypt
#### Deaktivieren Sie Let's Encrypt vollständig

Setzen Sie `SKIP_LETS_ENCRYPT=y` in "mailcow.conf" und erstellen Sie "acme-mailcow" neu, indem Sie `docker-compose up -d` ausführen.

#### Alle Namen außer ${MAILCOW_HOSTNAME} überspringen

Fügen Sie `ONLY_MAILCOW_HOSTNAME=y` zu "mailcow.conf" hinzu und erstellen Sie "acme-mailcow" neu, indem Sie `docker-compose up -d` ausführen.

### Das Let's Encrypt subjectAltName-Limit von 100 Domains

Let's Encrypt hat derzeit [ein Limit von 100 Domainnamen pro Zertifikat](https://letsencrypt.org/docs/rate-limits/).

Standardmäßig erstellt "acme-mailcow" ein einzelnes SAN-Zertifikat für alle validierten Domains
(siehe den [ersten Abschnitt](#lets-encrypt-wird-mitgeliefert) und [Zusätzliche Domainnamen](#zusatzliche-domain-namen)).
Dies bietet beste Kompatibilität, bedeutet aber, dass das Let's Encrypt-Limit überschritten wird, wenn Sie zu viele Domains zu einer einzelnen Mailcow-Installation hinzufügen.

Um dies zu lösen, können Sie `ENABLE_SSL_SNI` so konfigurieren, dass es generiert wird:

- Ein Hauptserver-Zertifikat mit `MAILCOW_HOSTNAME` und allen voll qualifizierten Domainnamen in der `ADDITIONAL_SAN` Konfiguration
- Ein zusätzliches Zertifikat für jede in der Datenbank gefundene Domain mit autodiscover.*, autoconfig.* und jeder anderen in diesem Format konfigurierten `ADDITIONAL_SAN` (subdomain.*).
- Begrenzungen: Ein Zertifikatsname `ADDITIONAL_SAN=test.example.com` wird als SAN zum Hauptzertifikat hinzugefügt. Ein separates Zertifikat/Schlüsselpaar wird für dieses Format **nicht** erzeugt.

Postfix, Dovecot und Nginx werden dann diese Zertifikate mit SNI bedienen.

Setzen Sie `ENABLE_SSL_SNI=y` in "mailcow.conf" und erstellen Sie "acme-mailcow" durch Ausführen von `docker-compose up -d`.

!!! warning
    Nicht alle Clients unterstützen SNI, [siehe Dovecot Dokumentation](https://wiki.dovecot.org/SSL/SNIClientSupport) oder [Wikipedia](https://en.wikipedia.org/wiki/Server_Name_Indication#Support).
    Sie sollten sicherstellen, dass diese Clients den `MAILCOW_HOSTNAME` für sichere Verbindungen verwenden, wenn Sie diese Funktion aktivieren.

Hier ist ein Beispiel:

- `MAILCOW_HOSTNAME=server.email.tld`
- `ADDITIONAL_SAN=webmail.email.tld,mail.*`
- Mailcow E-Mail-Domänen: "domain1.tld" und "domain2.tld"

Die folgenden Zertifikate werden generiert:

- `server.email.tld, webmail.email.tld` -> dies ist das Standard-Zertifikat, alle Clients können sich mit diesen Domains verbinden
- `mail.domain1.tld, autoconfig.domain1.tld, autodiscover.domain1.tld` -> individuelles Zertifikat für domain1.tld, kann von Clients ohne SNI-Unterstützung nicht verwendet werden
- `mail.domain2.tld, autoconfig.domain2.tld, autodiscover.domain2.tld` -> individuelles Zertifikat für domain2.tld, kann von Clients ohne SNI-Unterstützung nicht verwendet werden

### Ein eigenes Zertifikat verwenden

Stellen Sie sicher, dass Sie mailcows internen LE-Client deaktivieren (siehe oben).

Um Ihre eigenen Zertifikate zu verwenden, speichern Sie einfach das kombinierte Zertifikat (mit dem Zertifikat und der zwischengeschalteten CA/CA, falls vorhanden) unter `data/assets/ssl/cert.pem` und den entsprechenden Schlüssel unter `data/assets/ssl/key.pem`.

**WICHTIG:** Verwenden Sie keine symbolischen Links! Stellen Sie sicher, dass Sie die Zertifikate kopieren und sie nicht mit `data/assets/ssl` verknüpfen.

Starten Sie die betroffenen Dienste anschließend neu:

```
docker restart $(docker ps -qaf name=postfix-mailcow)
docker neu starten $(docker ps -qaf name=nginx-mailcow)
docker restart $(docker ps -qaf name=dovecot-mailcow)
```

Siehe [Post-Hook-Skript für Nicht-Mailcow-ACME-Clients](../firststeps-rp#optional-post-hook-skript-fur-nicht-mailcow-acme-clients) für ein vollständiges Beispielskript.

### Test gegen das ACME-Verzeichnis

Bearbeiten Sie `mailcow.conf` und fügen Sie `LE_STAGING=y` hinzu.

Führen Sie `docker-compose up -d` aus, um Ihre Änderungen zu aktivieren.

### Benutzerdefinierte Verzeichnis-URL

Editieren Sie `mailcow.conf` und fügen Sie die entsprechende Verzeichnis-URL in die neue Variable `DIRECTORY_URL` ein:

```
DIRECTORY_URL=https://acme-custom-v9000.api.letsencrypt.org/directory
```

Sie können `LE_STAGING` nicht mit `DIRECTORY_URL` verwenden. Wenn beide gesetzt sind, wird nur `LE_STAGING` verwendet.

Führen Sie `docker-compose up -d` aus, um Ihre Änderungen zu aktivieren.

### Überprüfen Sie Ihre Konfiguration

Führen Sie `docker-compose logs acme-mailcow` aus, um herauszufinden, warum eine Validierung fehlschlägt.

Um zu überprüfen, ob nginx das richtige Zertifikat verwendet, benutzen Sie einfach einen Browser Ihrer Wahl und überprüfen Sie das angezeigte Zertifikat.

Um das von Postfix, Dovecot und Nginx verwendete Zertifikat zu überprüfen, verwenden wir `openssl`:

```
# Verbindung über SMTP (587)
echo "Q" | openssl s_client -starttls smtp -crlf -connect mx.mailcow.email:587
# Verbindung über IMAP (143)
echo "Q" | openssl s_client -starttls imap -showcerts -connect mx.mailcow.email:143
# Verbindung über HTTPS (443)
echo "Q" | openssl s_client -connect mx.mailcow.email:443
```

Um die von openssl zurückgegebenen Verfallsdaten gegen MAILCOW_HOSTNAME zu validieren, können Sie unser Hilfsskript verwenden:

```
cd /opt/mailcow-dockerized
bash helper-scripts/expiry-dates.sh
```
