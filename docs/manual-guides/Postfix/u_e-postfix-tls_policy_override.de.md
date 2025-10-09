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
 