# MTA-STS einrichten

!!! info "Hinweis"
    Für diese Anleitung ist mailcow in Version **2025-09** oder höher erforderlich.

!!! danger "Wenn Sie zuvor manuell eingerichtet haben, beachten Sie bitte"
    Wenn Sie MTA‑STS manuell für Ihre Domain in mailcow konfiguriert haben, beachten Sie, dass nach diesem Update keine vorhandenen MTA‑STS-Dateien (z. B. .well-known/mta-sts.txt) mehr erreichbar sind. mailcow bedient jetzt MTA‑STS-Richtlinien dynamisch basierend auf den MTA‑STS-Einstellungen der Domain in der UI und verwendet die dort gespeicherte Konfiguration.

    mailcow erstellt keine MTA-STS Dateien im .well-known-Verzeichnis, alle Inhalte werden dynamisch über PHP-Code generiert.

!!! warning "Wichtig"
    MTA-STS ist insbesondere für Domains sinnvoll, die DANE nicht unterstützen (können). Wenn Sie DANE (DNS-based Authentication of Named Entities) bereits verwenden, ist MTA-STS nicht zwingend erforderlich, kann aber zusätzlich genutzt werden, um die Sicherheit weiter zu erhöhen.

## Was ist MTA-STS?
MTA-STS (Mail Transfer Agent Strict Transport Security) ist ein Sicherheitsstandard, der entwickelt wurde, um die Sicherheit von E-Mail-Übertragungen zu verbessern. Er ermöglicht es Domain-Inhabern, Richtlinien zu veröffentlichen, die vorschreiben, dass E-Mails nur über sichere Verbindungen (TLS) übertragen werden dürfen. Dies hilft, Man-in-the-Middle-Angriffe zu verhindern und die Integrität sowie Vertraulichkeit der E-Mail-Kommunikation zu gewährleisten.

mailcow unterstützt die Verwaltung von MTA-STS-Richtlinien nun direkt über die mailcow UI, welches nun aufgrund der Initiative "E-Mail-Sicherheitsjahr 2025" des Bundesamts für Sicherheit in der Informationstechnik (BSI) realisiert wurde, an welchem sich mailcow aktiv beteiligt um eine generelle Verbesserung der E-Mail-Sicherheit zu fördern und die Konfiguration dieser zu erleichtern.

## Voraussetzungen
- mailcow in Version **2025-09** oder höher
- Eine Domain, die auf Ihre mailcow-Installation zeigt
- Ein gültiges SSL-Zertifikat für Ihre Domain (z.B. von Let's Encrypt)
- Zugriff auf die DNS-Einstellungen Ihrer Domain

## Schritt 1: MTA-STS in der mailcow UI aktivieren
1. Melden Sie sich in der mailcow UI als Administrator an.
2. Navigieren Sie zu **E-Mail** :material-arrow-right: **Konfiguration**, gefolgt vom Reiter **Domains**.
3. Bearbeiten Sie die gewünschte Domain, für die Sie MTA-STS aktivieren möchten (Klicken auf **Bearbeiten**).
4. Sie sollten nun den Reiter **MTA-STS** sehen, welcher ähnlich wie folgt aussieht: ![MTA-STS Tab](../assets/images/post_installation/mta-sts-tab.png)
5. Gehen wir nun einmal alle Optionen kurz durch:
    - **Version**: Die aktuelle Version der MTA-STS-Richtlinie. Derzeit ist nur Version 1 (STSv1) per RFC Standard definiert.
    - **Modus**: Wählen Sie den gewünschten Modus aus:
        - `none`: Richtlinie ist deaktiviert (nur Monitoring)
        - `testing`: Richtlinie ist aktiv, aber Verstöße werden nur protokolliert
        - `enforce`: Richtlinie ist aktiv und Verstöße werden blockiert
    - **Maximales Alter**: Geben Sie an, wie lange E-Mail-Server die Richtlinie zwischenspeichern sollen (in Sekunden). Der empfohlene Wert ist 86400 Sekunden (1 Tag).
    - **MX-Einträge**: Tragen Sie hier die MX-Einträge Ihrer Domain ein, getrennt durch Kommas. Diese Einträge geben an, welche Mailserver autorisiert sind, E-Mails für Ihre Domain zu empfangen.
6. Nachdem Sie die gewünschten Einstellungen vorgenommen haben, setzen Sie den Haken bei **Aktiv** und klicken Sie auf **Änderungen speichern**.

## Schritt 2: DNS-Eintrag für MTA-STS hinzufügen
1. Erstellen Sie einen neuen DNS-TXT-Eintrag für Ihre Domain mit dem Namen `_mta-sts.ihredomain.tld` (ersetzen Sie `ihredomain.tld` durch Ihre tatsächliche Domain).
2. Der Wert des TXT-Eintrags sollte wie folgt aussehen:
   ```
    v=STSv1; id=2024090101
   ```
   - `v=STSv1`: Gibt die Version der MTA-STS-Richtlinie an.
   - `id=2024090101`: Eine eindeutige Kennung für die Richtlinie, die bei jeder Änderung erhöht werden sollte (z.B. Datum der Änderung im Format JJJJMMTTHH).

    !!! info "Hinweis"
        Bei einer Änderung der MTA-STS Richtlinie (z.B. Änderung des Modus oder der MX-Einträge) muss die `id` im DNS-Eintrag erhöht werden, damit empfangende Mailserver die neue Richtlinie erkennen.

        mailcow generiert automatisch eine neue `id`, wenn Sie Änderungen in der mailcow UI vornehmen und diese speichern.

        Die aktuell gültige id können Sie sich jederzeit mit dem DNS Check innerhalb der mailcow UI (blauer DNS Check Button) abrufen.

        Generell sollten Sie nach der aktivierung von MTA-STS in der mailcow UI immer den DNS Check nutzen, um sicherzustellen, dass die DNS-Einträge (TXT u. CNAME) korrekt gesetzt und propagiert sind.

3. Erstellen Sie einen weiteren DNS-CNAME-Eintrag für Ihre Domain mit dem Namen `mta-sts.ihredomain.tld`, der auf den mailcow FQDN zeigt (bspw. `mail.ihredomain.tld`, ersetzen Sie `mail.ihredomain.tld` durch Ihre tatsächlichen FQDN).

    !!! warning "Wichtig"
        Der CNAME-Eintrag ist erforderlich, damit ein gültiges SSL Zertifikat generiert werden kann (vorausgesetzt mailcow generiert die Zertifikate) und empfangende Mailserver die MTA-STS-Richtlinie abrufen können. mailcow hostet die Richtliniendatei zentral, um die Verwaltung zu erleichtern.

4. Warten Sie, bis die DNS-Änderungen propagiert sind. Dies kann je nach TTL-Einstellungen Ihrer DNS-Einträge einige Zeit dauern.

## Schritt 3: Überprüfung der MTA-STS Konfiguration
1. Nachdem die DNS-Einträge propagiert sind, können Sie die MTA-STS-Konfiguration überprüfen.
2. Verwenden Sie ein Online-Tool wie [Hardenize](https://www.hardenize.com/) oder den [MTA-STS Validator von Mailhardener](https://www.mailhardener.com/tools/mta-sts-validator) um zu überprüfen, ob Ihre MTA-STS-Richtlinie korrekt eingerichtet ist.
3. Alternativ können Sie auch den DNS Check in der mailcow UI verwenden, um sicherzustellen, dass die DNS-Einträge korrekt gesetzt sind.

## Schritt 4: Monitoring und Anpassungen
1. Überwachen Sie die E-Mail-Logs in der mailcow UI, um sicherzustellen, dass keine legitimen E-Mails blockiert werden.
2. Wenn Sie feststellen, dass legitime E-Mails blockiert werden, können Sie den Modus vorübergehend auf `testing` setzen, um Verstöße zu protokollieren, ohne E-Mails zu blockieren.
3. Passen Sie die MX-Einträge und andere Einstellungen nach Bedarf an und erhöhen Sie die `id` im DNS-Eintrag bei jeder Änderung.
4. Sobald Sie sicher sind, dass alles korrekt funktioniert, können Sie den Modus auf `enforce` setzen, um die Richtlinie vollständig durchzusetzen.