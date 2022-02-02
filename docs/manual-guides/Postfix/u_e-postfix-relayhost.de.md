Seit dem 12. September 2018 können Sie Relayhosts als Admin über die mailcow UI einrichten.

Dies ist nützlich, wenn Sie ausgehende E-Mails für eine bestimmte Domain an einen Drittanbieter-Spamfilter oder einen Dienst wie Mailgun oder Sendgrid weiterleiten möchten. Dies ist auch bekannt als ein _smarthost_.
Falls nicht, überprüfen Sie den Fehler und beheben Sie ihn.

## Einen neuen Relayhost hinzufügen
Gehen Sie auf die Registerkarte "Routing" im Abschnitt "Konfiguration und Details" der mailcow UI.
Hier sehen Sie eine Liste der derzeit eingerichteten Relayhosts.

Blättern Sie zum Abschnitt "Absenderabhängigen Transport hinzufügen".

Fügen Sie unter `Host` den Host hinzu, an den Sie weiterleiten möchten.<br>
_Beispiel: Wenn Sie Mailgun zum Senden von E-Mails anstelle Ihrer Server-IP verwenden möchten, geben Sie smtp.mailgun.org ein._

Wenn der Relay-Host zur Authentifizierung einen Benutzernamen und ein Passwort benötigt, geben Sie diese in die entsprechenden Felder ein.<br>
Beachten Sie, dass die Anmeldedaten im Klartext gespeichert werden.

### Testen Sie einen Relayhost
Um zu testen, ob die Verbindung zum Host funktioniert, klicken Sie in der Liste der Relayhosts auf `Test` und geben Sie eine _Von:_-Adresse ein. Führen Sie dann den Test aus.

Sie sehen dann die Ergebnisse der SMTP-Übertragung. Wenn alles klappt, sollten Sie Folgendes sehen:
`SERVER -> CLIENT: 250 2.0.0 Ok: queued as A093B401D4` als eine der letzten Zeilen.

Ist dies nicht der Fall, überprüfen Sie den angegebenen Fehler und beheben Sie ihn.

**Hinweis:** Einige Hosts, insbesondere solche, die keine Authentifizierung verlangen, verweigern Verbindungen von Servern, die nicht zuvor in ihr System aufgenommen wurden. Lesen Sie unbedingt die Dokumentation des Relayhosts, um sicherzustellen, dass Sie Ihre Domain und/oder die Server-IP zu ihrem System hinzugefügt haben.

**Tipp:** Sie können die standardmäßige _Von:_-Adresse, die der Test verwendet, von _null@mailcow.email_ auf eine beliebige E-Mail-Adresse ändern, indem Sie die Variable _$RELAY_TO_ in der Datei _vars.inc.php_ unter _/opt/mailcow-dockerized/data/web/inc_ ändern. <br> Auf diese Weise können Sie überprüfen, ob das Relay funktioniert hat, indem Sie das Zielpostfach überprüfen.

## Relayhost für eine Domain festlegen
Wechseln Sie auf die Registerkarte "Domains" im Abschnitt "E-Mail-Setup" der mailcow UI.

Bearbeiten Sie die gewünschte Domain.

Wählen Sie den neu hinzugefügten Host in der Dropdown-Liste "Absenderabhängige Transporte" aus und speichern Sie die Änderungen.

Senden Sie eine E-Mail von einer Mailbox auf dieser Domain und Sie sollten in den Protokollen sehen, dass Postfix die Nachricht an den Relayhost weiterleitet.