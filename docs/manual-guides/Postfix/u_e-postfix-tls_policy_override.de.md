!!! info "Diese Anleitung sollte nur von erfahrenen Administratoren verwendet werden"
    Diese Anleitung richtet sich an erfahrene Administratorinnen und Administratoren, die gezielt TLS-Richtlinien für bestimmte Domains oder IP-Adressen anpassen müssen.  
    Unsachgemäße Änderungen an den TLS-Einstellungen können zu Zustellungsproblemen oder unsicheren Verbindungen führen.

---

## Hintergrund

Seit dem **mailcow-Update im September 2025** überprüft mailcow auch **für ausgehende SMTP-Verbindungen** die TLS-Richtlinien des Empfängers.  
Zuvor galt diese Prüfung ausschließlich für eingehende E-Mails oder für Domains, bei denen die Funktion ausdrücklich aktiviert war.

In seltenen Fällen kann dies dazu führen, dass E-Mails nicht mehr zugestellt werden – etwa wenn eine Empfänger-Domain fehlerhafte oder ungültige **TLSA-Records (DANE)** veröffentlicht hat.  
Da Postfix (und damit auch mailcow) diese Einträge gemäß [RFC 7672](https://datatracker.ietf.org/doc/html/rfc7672) als verbindlich betrachtet, wird die Zustellung in solchen Fällen verweigert.

Wenn Sie E-Mails an derart betroffene Empfänger dennoch zustellen möchten – beispielsweise als **Workaround bei fehlerhaften TLSA-Records** – können Sie über die TLS-Richtlinienverwaltung eine abweichende Policy für die jeweilige Domain festlegen.  
Beachten Sie, dass dies bewusst Sicherheitsprüfungen umgeht und nur **temporär** oder **mit entsprechender Dokumentation** eingesetzt werden sollte.

---

## Vorgehensweise

1. **Anmelden:**  
   Melden Sie sich in der mailcow-Weboberfläche als Administrator an.

2. **Navigation:**  
   Öffnen Sie **E-Mail > Konfiguration**.

3. **TLS-Richtlinien öffnen:**  
   Wechseln Sie auf den Reiter **TLS-Richtlinien**.

4. **Eintrag hinzufügen:**  
   Klicken Sie auf **TLS-Richtlinieneintrag hinzufügen**.

5. **Ziel festlegen:**  
   Geben Sie im Feld **Ziel** die betroffene Domain oder IP-Adresse ein, für die die Richtlinie gelten soll (z. B. `example.com`).

6. **Richtlinie auswählen:**  
   Wählen Sie im Dropdown-Menü **Richtlinie** eine der folgenden Optionen aus:
      - `none` – TLS wird nicht verwendet, auch wenn der Zielserver es anbietet.  
      - `may` – TLS wird genutzt, wenn verfügbar, ist aber nicht verpflichtend.  
      - `encrypt` – TLS ist Pflicht, Zertifikate werden jedoch nicht geprüft.  
      - `verify` – TLS ist Pflicht und das Serverzertifikat wird überprüft.  
      - `secure` – TLS ist Pflicht, Zertifikat und Hostname müssen gültig sein.  
      - `dane` – TLS nach DANE-Richtlinien, fällt ohne TLSA-Record auf opportunistisches TLS zurück.  
      - `dane-only` – TLS ausschließlich über gültige DANE/TLSA-Records, kein Fallback.  
      - `fingerprint` – TLS ist Pflicht, das Zertifikat muss einem hinterlegten Fingerabdruck entsprechen.

    *Beispiel:*  
    Wenn eine Domain fehlerhafte TLSA-Einträge hat, können Sie vorübergehend `may` oder `encrypt` wählen, um die Zustellung dennoch zu ermöglichen.

7. **Optionale Parameter:**  
   Im Feld **Parameter** können Sie zusätzliche Postfix-Optionen angeben, z. B.: `protocols=!SSLv2,!SSLv3` um veraltete Protokolle zu deaktivieren.

    Trennen Sie die Parameter voneinander mit einer Leerzeile.

8. **Richtlinie aktivieren:**  
Aktivieren Sie die Option **Aktiv**, damit die Richtlinie angewendet wird.

9. **Speichern:**  
Klicken Sie auf **Hinzufügen**, um die Richtlinie zu erstellen und zu aktivieren.

Die Richtlinie ist nun aktiv.  
Ein **Neustart von mailcow oder Postfix ist nicht erforderlich** – die Änderung wird sofort wirksam.

---

## Beispielanwendungen

| Situation | Empfohlene Richtlinie | Beschreibung |
|------------|----------------------|---------------|
| Ziel-Domain hat ungültige TLSA-Records | `may` | Opportunistisches TLS, um die Zustellung trotz fehlerhafter DANE-Einträge zu ermöglichen. |
| Interne Testsysteme ohne gültige Zertifikate | `encrypt` | Erzwingt Verschlüsselung, ohne Zertifikatsprüfung. |
| Partner-Domain mit korrekt konfiguriertem DANE | `dane` | Sichere Zustellung über DNSSEC-verifizierte TLSA-Records. (mailcow Standard, wenn empfänger Domain kompatibel) |
| Hochsicherheitsumgebung mit bekannten Zertifikaten | `fingerprint` | Explizite Zertifikatsbindung für maximale Kontrolle. |

!!! warning "Hinweis"
    Sobald fehlerhafte TLSA-Records oder Zertifikatsprobleme auf Empfängerseite behoben wurden, sollten Sie die temporär gesetzte Richtlinie **wieder entfernen oder auf den Standardwert zurücksetzen**, um die Integrität des TLS-Sicherheitsmodells zu gewährleisten.

---

## TLS-Richtlinienprüfung vollständig deaktivieren

In seltenen Fällen reicht eine Richtlinie pro Domain nicht aus - etwa wenn eine Firewall mit SMTP-Inspection (Cisco ASA `inspect esmtp`, FortiGate SMTP-Proxy und ähnliche) oder ein zwischengeschaltetes Relay Ihres Providers `STARTTLS` aus der EHLO-Antwort des Gegenübers entfernt. Postfix sieht dann einen Server, der überhaupt kein TLS anbietet, während DANE oder MTA-STS es weiterhin verlangen, und jede betroffene E-Mail bleibt in der Warteschlange liegen.

Um die Prüfung für alle Ziele abzuschalten, fügen Sie Folgendes in die Postfix [extra.cf](u_e-postfix-extra_cf.de.md) ein:

```bash
smtp_tls_security_level = may
smtp_dns_support_level = enabled
smtp_tls_policy_maps = proxy:mysql:/opt/postfix/conf/sql/mysql_tls_policy_override_maps.cf
```

- `smtp_tls_security_level = may` - opportunistisches TLS: verschlüsselt, wenn der Zielserver `STARTTLS` anbietet, andernfalls wird unverschlüsselt zugestellt. Der mailcow-Standard ist `dane`.
- `smtp_dns_support_level = enabled` - einfache DNS-Abfragen anstelle der DNSSEC-validierten, die nur für DANE benötigt werden. Der mailcow-Standard ist `dnssec`.
- `smtp_tls_policy_maps` - derselbe Wert wie in der `main.cf`, jedoch ohne den Eintrag `socketmap:inet:postfix-tlspol:8642:QUERY`, sodass Postfix postfix-tlspol nicht mehr nach MTA-STS- und DANE-Richtlinien fragt. Die oben beschriebenen TLS-Richtlinien aus der mailcow-UI funktionieren weiterhin.

Ohne `smtp_dns_support_level = dnssec` weist Postfix die Richtlinien `dane` und `dane-only` zurück, kombinieren Sie diese Einstellung daher nicht mit solchen Einträgen in der TLS-Richtlinientabelle.

Starten Sie Postfix neu, um die Änderung zu übernehmen:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow
    ```

Lassen Sie den Container `postfix-tlspol-mailcow` laufen, `postfix-mailcow` hängt von ihm ab. Er erhält lediglich keine Anfragen mehr.

!!! info "Geltungsbereich"
    Diese `smtp_*`-Parameter gelten ausschließlich für **ausgehende** Zustellungen von Postfix an andere Mailserver über Port 25. Eingehende E-Mails, die Einlieferung über Port 465/587 sowie die TLS-Erzwingung pro Mailbox bleiben unberührt.

!!! warning "Hinweis"
    Das Deaktivieren der Prüfung entfernt den Downgrade-Schutz für **alle** Empfänger, ein Angreifer auf dem Übertragungsweg kann `STARTTLS` dann unbemerkt entfernen. Verwenden Sie eine Richtlinie pro Domain, solange das Problem einzelne Empfänger betrifft, und greifen Sie nur dann hierauf zurück, wenn Ihr gesamter ausgehender Verkehr betroffen ist.
 