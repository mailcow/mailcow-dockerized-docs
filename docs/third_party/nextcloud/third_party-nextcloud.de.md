## Nextcloud konfigurieren, um mailcow für die Authentifizierung zu verwenden

Im Folgenden wird beschrieben, wie die Authentifizierung über mailcow unter Verwendung des OAuth2-Protokolls eingerichtet wird. Wir nehmen nur an, dass Sie Nextcloud bereits unter _cloud.example.com_ eingerichtet haben und dass Ihre mailcow unter _mail.example.com_ läuft. Es spielt keine Rolle, wenn Ihre Nextcloud auf einem anderen Server läuft, Sie können immer noch mailcow für die Authentifizierung verwenden.

1\. Melden Sie sich bei mailcow als Administrator an.

2\. Klicken Sie im Dropdown Menü (oben rechts) auf Konfiguration.

3\. Wählen Sie dann im Reiter "Zugang" den Dropdown Punkt OAuth2 aus.

4\. Scrollen Sie nach unten und klicken Sie auf die Schaltfläche _Füge OAuth2 Client hinzu_. Geben Sie die Redirect URI als `https://cloud.example.com/index.php/apps/sociallogin/custom_oauth2/mailcow` an und klicken Sie auf _Hinzufügen_. Speichern Sie die Client-ID und das Geheimnis für später.

!!! info
    Einige Installationen, einschließlich derer, die früher mit dem entfernten Helper-Skript von mailcow eingerichtet wurden, müssen index.php/ aus der URL entfernen, um einen erfolgreichen Redirect zu erhalten: `https://cloud.example.com/apps/sociallogin/custom_oauth2/mailcow`

3\. Melden Sie sich bei Nextcloud als Administrator an.

4\. Klicken Sie auf die Schaltfläche in der oberen rechten Ecke und wählen Sie _Apps_. Klicken Sie auf die Schaltfläche "Suchen" in der Symbolleiste, suchen Sie nach dem Plugin [_Social Login_](https://apps.nextcloud.com/apps/sociallogin) und klicken Sie daneben auf _Herunterladen und aktivieren_.

5\. Klicken Sie auf die Schaltfläche in der oberen rechten Ecke und wählen Sie _Einstellungen_. Scrollen Sie zum Abschnitt _Administration_ auf der linken Seite und klicken Sie auf _Social Login_.

6\. Entfernen Sie das Häkchen bei den folgenden Punkten:

- "Automatische Erstellung neuer Benutzer deaktivieren"
- "Benutzern erlauben, soziale Logins mit ihren Konten zu verbinden".
- "Nicht verfügbare Benutzergruppen bei der Anmeldung nicht entfernen"
- "Gruppen automatisch erstellen, wenn sie nicht vorhanden sind"
- "Anmeldung für Benutzer ohne zugeordnete Gruppen einschränken".

7\. Überprüfen Sie die folgenden Punkte:

- "Die Erstellung eines Kontos verhindern, wenn die E-Mail-Adresse in einem anderen Konto existiert"
- "Benutzerprofil bei jeder Anmeldung aktualisieren"
- "Benachrichtigung der Administratoren über neue Benutzer deaktivieren".

Klicken Sie auf die Schaltfläche _Speichern_.

8\. Scrollen Sie nach unten zu _Custom OAuth2_ und klicken Sie auf die Schaltfläche _+_.
9\. Konfigurieren Sie die Parameter wie folgt:

- Interner Name: `mailcow`
- Titel: `mailcow`
- API Basis-URL: `https://mail.example.com`
- Autorisierungs-URL: `https://mail.example.com/oauth/authorize`
- Token-URL: `https://mail.example.com/oauth/token`
- Profil-URL: `https://mail.example.com/oauth/profile`
- Abmelde-URL: (leer lassen)
- Kunden-ID: (die Sie in Schritt 1 erhalten haben)
- Client Secret: (was Sie in Schritt 1 erhalten haben)
- Bereich: `Profil`

Klicken Sie auf die Schaltfläche _Speichern_ ganz unten auf der Seite.