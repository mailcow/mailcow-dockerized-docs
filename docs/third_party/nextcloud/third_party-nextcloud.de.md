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

8\. Klicken Sie auf die Schaltfläche _Speichern_.

9\. Scrollen Sie nach unten zu _Custom OAuth2_ und klicken Sie auf die Schaltfläche _+_.

10\. Konfigurieren Sie die Parameter wie folgt:

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

Wenn Sie zuvor Nextcloud mit mailcow-Authentifizierung über user_external/IMAP verwendet haben, müssen Sie einige zusätzliche Schritte durchführen, um Ihre bestehenden Benutzerkonten mit OAuth2 zu verknüpfen.

1. Klicken Sie oben rechts auf den Button und wählen Sie _Apps_. Scrollen Sie nach unten zur App _External user authentication_ und klicken Sie auf _Entfernen_ daneben.
2. Führen Sie die folgenden Abfragen in Ihrer Nextcloud-Datenbank aus:

    ```sql
    INSERT INTO oc_users (uid, uid_lower) SELECT DISTINCT uid, LOWER(uid) FROM oc_users_external;
    INSERT INTO oc_sociallogin_connect (uid, identifier) SELECT DISTINCT uid, CONCAT("mailcow-", uid) FROM oc_users_external;
    ```

---

Wenn Sie zuvor Nextcloud ohne mailcow-Authentifizierung verwendet haben, aber mit denselben Benutzernamen wie in mailcow, können Sie Ihre bestehenden Benutzerkonten ebenfalls mit OAuth2 verknüpfen.

1. Führen Sie die folgenden Abfragen in Ihrer Nextcloud-Datenbank aus:

    ```sql
    INSERT INTO oc_sociallogin_connect (uid, identifier) SELECT DISTINCT uid, CONCAT("mailcow-", uid) FROM oc_users;
    ```