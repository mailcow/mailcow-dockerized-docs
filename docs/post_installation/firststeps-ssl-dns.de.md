# Let's Encrypt mit DNS-01-Challenge

## Einführung

### Was ist die DNS-01-Challenge?

DNS-01 ist eine alternative ACME (Automated Certificate Management Environment) Validierungsmethode, die den Domainbesitz durch DNS-TXT-Records anstelle von HTTP-Anfragen nachweist. Bei der Anforderung eines Zertifikats mit DNS-01:

1. Der ACME-Server (Let's Encrypt) stellt einen einzigartigen Token bereit
2. Ihr mailcow-Server erstellt automatisch einen DNS-TXT-Record `_acme-challenge.ihredomain.de` mit diesem Token
3. Let's Encrypt fragt DNS ab, um zu überprüfen, ob der Record existiert
4. Nach erfolgreicher Prüfung wird Ihr Zertifikat ausgestellt

mailcow nutzt [acme.sh](https://github.com/acmesh-official/acme.sh) für die DNS-01-Validierung und unterstützt über 150 DNS-Provider über deren APIs.

### Wann die DNS-Challenge verwenden?

Erwägen Sie die Verwendung der DNS-01-Challenge, wenn Sie Folgendes benötigen:

- **Wildcard-Zertifikate** (`*.example.de`) - HTTP-01 kann keine Wildcard-Zertifikate ausstellen
- **Server hinter Firewall** - Port 80 (HTTP) ist blockiert oder nicht öffentlich erreichbar
- **Komplexe Reverse-Proxy-Setups** - HTTP-Validierung würde den falschen Server erreichen
- **Mehrere Server, die sich eine Domain teilen** - HTTP-Challenge könnte einen anderen Server erreichen
- **Reduzierte externe Exposition** - Kein Port 80 muss ins Internet exponiert werden

### Wann NICHT die DNS-Challenge verwenden?

Bleiben Sie bei der Standard-HTTP-01-Challenge, wenn:

- Sie ein einfaches Single-Server-Setup mit öffentlichem HTTP-Zugang haben (einfacher zu konfigurieren)
- Ihr DNS-Provider keinen API-Zugang bietet oder von acme.sh nicht unterstützt wird
- Sie den DNS-API-Zugang aufgrund organisatorischer Einschränkungen nicht automatisieren können
- Sie keine Wildcard-Zertifikate benötigen

!!! note "Standard-Methode"
    mailcow verwendet standardmäßig die HTTP-01-Challenge, die für die meisten Installationen gut funktioniert. Wechseln Sie nur zu DNS-01, wenn Sie einen spezifischen Bedarf dafür haben.

---

## Voraussetzungen

Bevor Sie die DNS-01-Challenge aktivieren, stellen Sie sicher, dass Sie Folgendes haben:

1. **mailcow Version 2026-03 oder neuer**
2. **Einen unterstützten DNS-Provider** mit API-Zugang (siehe [Unterstützte DNS-Provider](#unterstutzte-dns-provider))
3. **API-Zugangsdaten** von Ihrem DNS-Provider mit Berechtigung zum Bearbeiten von DNS-Records
4. **Verständnis Ihrer DNS-Zonenstruktur** (welche Domains/Subdomains Zertifikate benötigen)

---

## Konfiguration

### Schritt 1: DNS-Challenge in mailcow.conf aktivieren

Bearbeiten Sie `/opt/mailcow-dockerized/mailcow.conf` und fügen Sie folgende Parameter hinzu oder ändern Sie sie:

```bash
# DNS-01-Challenge aktivieren (statt HTTP-01)
ACME_DNS_CHALLENGE=y

# DNS-Provider-Plugin angeben (siehe Provider-Liste unten)
# Beispiel: dns_servercow für Servercow, dns_cf für CloudFlare, dns_aws für AWS Route53
ACME_DNS_PROVIDER=dns_servercow

# E-Mail-Adresse für ACME-Account-Registrierung
ACME_ACCOUNT_EMAIL=admin@example.de
```

!!! warning "Wichtige Einstellungen"
    - Wenn `ACME_DNS_CHALLENGE=y` gesetzt ist, ignoriert mailcow `SKIP_HTTP_VERIFICATION` (es ist impliziert)
    - Port 80 wird für DNS-Challenge **nicht benötigt**
    - Alle Domains in Ihrer mailcow-Installation verwenden DNS-01 (HTTP-01 und DNS-01 können nicht gemischt werden)

### Schritt 2: DNS-Provider-Zugangsdaten konfigurieren

Erstellen oder bearbeiten Sie `/opt/mailcow-dockerized/data/conf/acme/dns-01.conf`:

```bash
# Servercow Beispiel
SERVERCOW_API_Username="servercow-api-username"
SERVERCOW_API_Password="servercow-api-password"
```

Das Dateiformat sind einfache `key=value` Paare. Jeder DNS-Provider benötigt unterschiedliche Variablen - siehe [Konfigurations-Beispiele](#konfigurations-beispiele) für Ihren spezifischen Provider.

### Schritt 3: Konfiguration anwenden

Starten Sie den acme-mailcow-Container neu, um die Änderungen anzuwenden:

=== "docker compose (Plugin)"

    ``` bash
    cd /opt/mailcow-dockerized
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    cd /opt/mailcow-dockerized
    docker-compose up -d
    ```

### Schritt 4: Zertifikatsanforderung überwachen

Beobachten Sie die Logs, um zu überprüfen, ob die DNS-Challenge funktioniert:

=== "docker compose (Plugin)"

    ``` bash
    docker compose logs -f acme-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose logs -f acme-mailcow
    ```

---

## Unterstützte DNS-Provider

mailcow nutzt acme.sh DNS-API-Plugins. Über 150 Provider werden unterstützt.

### Tier 1: Vollständig getestet & empfohlen

| Provider | Plugin-Name | Benötigte Zugangsdaten | Dokumentation |
|----------|-------------|------------------------|---------------|
| **Servercow** | `dns_servercow` | `SERVERCOW_API_Username`, `SERVERCOW_API_Password` | [Servercow API](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_servercow) |
| **CloudFlare** | `dns_cf` | `CF_Token`, `CF_Account_ID` | [CloudFlare DNS API](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_cf) |
| **AWS Route53** | `dns_aws` | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` | [Route53 API](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_aws) |
| **Azure DNS** | `dns_azure` | `AZUREDNS_SUBSCRIPTIONID`, `AZUREDNS_TENANTID`, `AZUREDNS_APPID`, `AZUREDNS_CLIENTSECRET` | [Azure API](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_azure) |
| **Google Cloud DNS** | `dns_gcloud` | `CLOUDSDK_ACTIVE_CONFIG_NAME` | [GCloud API](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_gcloud) |
| **DigitalOcean** | `dns_dgon` | `DO_API_KEY` | [DigitalOcean API](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_dgon) |

### Tier 2: Community-getestet

| Provider | Plugin-Name | Hinweise |
|----------|-------------|----------|
| **Hetzner** | `dns_hetzner` | Beliebt in Deutschland/Europa |
| **IONOS** | `dns_ionos` | Deutscher Provider (früher 1&1) |
| **Strato** | `dns_strato` | Deutscher Hosting-Provider |
| **OVH** | `dns_ovh` | Europäischer Provider |
| **Namecheap** | `dns_namecheap` | Benötigt DDNS-Passwort, nicht Standard-API |
| **GoDaddy** | `dns_gd` | API-Key + API-Secret erforderlich |
| **Linode** | `dns_linode` | API-Token |

**Vollständige Provider-Liste:** [acme.sh DNS API Dokumentation](https://github.com/acmesh-official/acme.sh/wiki/dnsapi) (150+ Provider)

!!! tip "Provider nicht aufgeführt?"
    Wenn Ihr Provider DNS-API unterstützt und in der acme.sh-Dokumentation aufgeführt ist, sollte er mit mailcow funktionieren. Prüfen Sie das [acme.sh Wiki](https://github.com/acmesh-official/acme.sh/wiki/dnsapi) für Konfigurationsdetails.

---

## Wildcard-Zertifikate

Die DNS-01-Challenge ist die **einzige Möglichkeit**, Wildcard-Zertifikate von Let's Encrypt zu erhalten.

### Konfigurations-Beispiel

Bearbeiten Sie `mailcow.conf`:

```bash
MAILCOW_HOSTNAME=mail.example.de
ADDITIONAL_SAN=*.example.de,example.de
ACME_DNS_CHALLENGE=y
ACME_DNS_PROVIDER=dns_servercow
```

!!! warning "Wildcard-Einschränkungen"
    - `*.example.de` deckt `mail.example.de`, `webmail.example.de`, `smtp.example.de`, etc. ab
    - `*.example.de` deckt **NICHT** `example.de` (die Apex/Root-Domain) ab
    - Sie müssen beides explizit hinzufügen: `ADDITIONAL_SAN=*.example.de,example.de`

---

## Konfigurations-Beispiele

### Beispiel 1: Servercow mit Wildcard

**Szenario:** mailcow bei Servercow gehostet, einzelne Domain mit Wildcard-Zertifikat

**mailcow.conf:**

```bash
MAILCOW_HOSTNAME=mail.example.de
ADDITIONAL_SAN=*.example.de,example.de

# DNS-01-Challenge-Konfiguration
ACME_DNS_CHALLENGE=y
ACME_DNS_PROVIDER=dns_servercow
ACME_ACCOUNT_EMAIL=admin@example.de
```

**data/conf/acme/dns-01.conf:**

```bash
# Servercow API-Zugangsdaten
# Abrufen unter: https://cp.servercow.de
# API > API-Benutzer > Neuen Benutzer erstellen oder existierenden verwenden
SERVERCOW_API_Username="ihr-servercow-api-benutzername"
SERVERCOW_API_Password="ihr-servercow-api-passwort"
```

**Servercow API-Benutzer erstellen:**

1. Einloggen im [Servercow Control Panel](https://cp.servercow.de)
2. Navigation zu **API** > **API-Benutzer**
3. Klick auf **API-Benutzer erstellen** oder existierenden API-Benutzer verwenden
4. Benutzername und Passwort notieren
5. Sicherstellen, dass der API-Benutzer DNS-Verwaltungsrechte hat

---

### Beispiel 2: CloudFlare mit Wildcard

**Szenario:** Kleines Unternehmen, einzelne Domain, Wildcard-Zertifikat für alle Subdomains gewünscht

**mailcow.conf:**

```bash
MAILCOW_HOSTNAME=mail.example.de
ADDITIONAL_SAN=*.example.de,example.de

# DNS-01-Challenge-Konfiguration
ACME_DNS_CHALLENGE=y
ACME_DNS_PROVIDER=dns_cf
ACME_ACCOUNT_EMAIL=admin@example.de
```

**data/conf/acme/dns-01.conf:**

```bash
# CloudFlare API-Token (NICHT Global API Key!)
# Erstellen unter: https://dash.cloudflare.com/profile/api-tokens
# Berechtigungen: Zone > DNS > Edit für Zone 'example.de'
CF_Token="ihr_cloudflare_api_token_hier"
CF_Account_ID="ihre_cloudflare_account_id"
```

**CloudFlare API-Token erstellen:**

1. Gehen Sie zum [CloudFlare Dashboard](https://dash.cloudflare.com/profile/api-tokens)
2. Klicken Sie auf "Token erstellen"
3. Verwenden Sie die Vorlage "Zone-DNS bearbeiten" oder erstellen Sie einen benutzerdefinierten Token mit:
   - Berechtigungen: `Zone > DNS > Bearbeiten`
   - Zonenressourcen: `Einschließen > Bestimmte Zone > example.de`
4. Kopieren Sie den Token (wird nur einmal angezeigt!)

---

### Beispiel 3: Hetzner (Deutschland)

**Szenario:** Deutscher Hosting-Provider, beliebt in Europa

**mailcow.conf:**

```bash
MAILCOW_HOSTNAME=mail.example.de
ADDITIONAL_SAN=*.example.de

ACME_DNS_CHALLENGE=y
ACME_DNS_PROVIDER=dns_hetzner
ACME_ACCOUNT_EMAIL=admin@example.de
```

**data/conf/acme/dns-01.conf:**

```bash
# Hetzner DNS API-Token
# Erstellen unter: https://dns.hetzner.com/settings/api-token
HETZNER_Token="ihr-hetzner-api-token-hier"
```

---

### Beispiel 4: IONOS (Deutschland)

**Szenario:** IONOS (früher 1&1), deutscher Provider

**mailcow.conf:**

```bash
MAILCOW_HOSTNAME=mail.example.de
ADDITIONAL_SAN=*.example.de

ACME_DNS_CHALLENGE=y
ACME_DNS_PROVIDER=dns_ionos
ACME_ACCOUNT_EMAIL=admin@example.de
```

**data/conf/acme/dns-01.conf:**

```bash
# IONOS API-Key
# Abrufen im IONOS-Kundenbereich unter Developer Tools
IONOS_API_KEY="ihr-ionos-api-key"
```

---

### Beispiel 5: AWS Route53 (Multi-Domain)

**Szenario:** Mehrere Domains auf AWS gehostet, Unternehmenssetup

**mailcow.conf:**

```bash
MAILCOW_HOSTNAME=mail.firma.de
ADDITIONAL_SAN=smtp.firma.de,mail.abteilung.de

ACME_DNS_CHALLENGE=y
ACME_DNS_PROVIDER=dns_aws
ACME_ACCOUNT_EMAIL=admin@firma.de
```

**data/conf/acme/dns-01.conf:**

```bash
# AWS IAM User Zugangsdaten
# IAM User: mailcow-acme-dns
# Policy: Angehängte benutzerdefinierte Richtlinie (siehe unten)
AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

**Empfohlene IAM-Richtlinie (minimale Rechte):**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:GetChange",
        "route53:ListHostedZones"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/Z1234567890ABC"
    }
  ]
}
```

Ersetzen Sie `Z1234567890ABC` durch Ihre tatsächliche Hosted-Zone-ID.

---

## Zusätzliche Ressourcen

- [acme.sh DNS API Dokumentation](https://github.com/acmesh-official/acme.sh/wiki/dnsapi) - Vollständige Liste von 150+ unterstützten DNS-Providern mit Konfigurationsbeispielen
- [Let's Encrypt Challenge-Typen](https://letsencrypt.org/de/docs/challenge-types/) - Offizielle Dokumentation zu HTTP-01 vs DNS-01
- [Let's Encrypt Rate Limits](https://letsencrypt.org/de/docs/rate-limits/) - Limits für Zertifikatsausstellung
- [mailcow SSL Dokumentation (HTTP-01)](firststeps-ssl.md) - Standard HTTP-basierte Zertifikatsausstellung
- [mailcow Reverse Proxy Setup](reverse-proxy/r_p.md) - mailcow hinter Reverse Proxies verwenden
- [mailcow DNS Voraussetzungen](../getstarted/prerequisite-dns.md) - Für Mail-Betrieb erforderliche DNS-Records
