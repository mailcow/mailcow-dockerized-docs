### **Konfigurieren**  

Ein **Identity Provider** wird als Administrator in der *mailcow UI* unter  
`System > Konfiguration > Zugang > Identity Provider` konfiguriert. Dort **Generic-OIDC** im Dropdown-Menü auswählen.  

**Verbindung**

* `Authorization Endpoint`: Die URL des Authorization Endpoints des Provider's.  
* `Token Endpoint`: Die URL des Token Endpoints des Provider's.  
* `User Info Endpoint`: Die URL des User Info Endpoint des Provider's.  
* `Client ID`: Die Client-ID, die dem mailcow Client im OIDC-Provider zugewiesen wurde.  
* `Client Secret`: Das Client-Secret, das dem mailcow Client im OIDC-Provider zugewiesen wurde.  
* `Client Scopes`: Gibt die während der Authentifizierung angeforderten **OIDC-Scopes** an. Die Standard-Scopes sind `openid profile email mailcow_template`.  
* `Ignoriere SSL Fehler`: Wenn aktiviert, wird die Überprüfung des SSL-Zertifikats deaktiviert.  

**Anmeldung**

* `Redirect URL`: Die Redirect-URL, die der OIDC-Provider nach der Authentifizierung verwendet. Diese sollte auf die mailcow UI verweisen. Beispiel: `https://mail.mailcow.tld`. Über **Redirect-URL hinzufügen** lassen sich weitere URLs eintragen, z. B. für zusätzliche Hostnamen.  
* `Benutzer beim Login erstellen`: Wenn aktiviert, werden Mailboxen bei der ersten Anmeldung eines Benutzers angelegt, siehe [Automatische Benutzerbereitstellung](#automatische-benutzerbereitstellung).  

**Postfach-Vorlagen**

* `Standardvorlage`: Wird beim Anlegen einer Mailbox verwendet, wenn kein Attribut Mapping passt. Auf bestehende Mailboxen wird sie nicht angewendet.  
* `Attribut Mapping`:
    * `Attribut`: Definiert den Attributwert, der zugeordnet werden soll.  
    * `Vorlage`: Gibt an, welche Mailbox-Vorlage für den definierten Attributwert angewendet werden soll.  

!!! info "Hinweis"

    Generic-OIDC unterstützt keine Synchronisation im Hintergrund (Import, Offboarding, Gruppen-Sync). Diese gibt es für [Keycloak und LDAP](u_e-mailcow_ui-idp-sync.md).

Bei der ersten Anmeldung verknüpft mailcow die Mailbox über den Claim `sub` mit dem OIDC-Benutzer. Der OIDC-Provider muss einen `sub` liefern, der sich nicht ändert, und eindeutige E-Mail-Adressen. Die Verknüpfung steht auf der Bearbeiten-Seite der Mailbox unter **IdP-Verknüpfung**, Administratoren lösen sie mit **Verknüpfung lösen**. Siehe [Verknüpfung von Mailboxen und IdP-Benutzern](u_e-mailcow_ui-idp-sync.md#verknupfung-von-mailboxen-und-idp-benutzern).

---

### **Automatische Benutzerbereitstellung**  

Wenn ein Benutzer in **mailcow** nicht existiert und sich über die **mailcow UI** anmeldet, wird er **automatisch erstellt**, sofern `Benutzer beim Login erstellen` aktiv ist und ein passendes **Attribut Mapping** oder eine **Standardvorlage** konfiguriert ist.  

#### **Funktionsweise**  
1. Bei der Anmeldung initialisiert **mailcow** einen **Authorization Code Flow** und ruft bei Erfolg das **OIDC-Token** des Benutzers ab.  
2. **mailcow** sucht dann im User Info Endpoint nach dem Wert von `mailcow_template` und ruft ihn ab.  
3. Wenn der Wert mit einem Attribut in dem **Attribut Mapping** übereinstimmt, wird die entsprechende **Mailbox-Vorlage** angewendet. Andernfalls wird die **Standardvorlage** verwendet.  

#### **Beispielkonfiguration**  
- Der Benutzer hat das Attribut `mailcow_template` mit dem Wert `default`, das vom **User Info Endpoint** abgerufen werden kann.  
- Unter **Attribut Mapping** wird `Attribut` auf `default` gesetzt und eine geeignete **Mailbox-Vorlage** ausgewählt.  

#### **Updates bei der Anmeldung**  
Jedes Mal, wenn sich ein Benutzer über die **mailcow UI** anmeldet, überprüft **mailcow**, ob sich die zugewiesene **Mailbox-Vorlage** geändert hat. Falls ja, werden die Mailbox-Einstellungen entsprechend aktualisiert. Vorlagen von [Gruppen](u_e-mailcow_ui-groups.md#mailbox-template) haben Vorrang vor dem Attribut Mapping.  

---

### **Authentifizierungsquelle für bestehende Benutzer ändern**  

Nachdem ein **Generic-OIDC Identity Provider** konfiguriert wurde, kann die Authentifizierungsquelle bestehender Benutzer von **mailcow** auf **Generic-OIDC** umgestellt werden.  

1. `E-Mail > Konfiguration > Mailboxen` öffnen.  
2. Den Benutzer bearbeiten.  
3. Im **Identity Provider**-Dropdown **Generic-OIDC** auswählen.  
4. Die Änderungen speichern. 

!!! info "Hinweis"

    Das bestehende SQL-Passwort wird **nicht überschrieben**. Falls die Authentifizierungsquelle wieder auf **mailcow** umgestellt wird, kann der Benutzer sich weiterhin mit seinem vorherigen Passwort anmelden.  

---

### **Authentifizierung für externe Mail-Clients (IMAP, SIEVE, POP3, SMTP)**  

Bevor Benutzer externe Mail-Clients nutzen können, müssen sie sich zunächst in die mailcow UI einloggen und zu den **Mailbox-Einstellungen** navigieren.  
Im Tab **App-Passwörter** können sie ein neues App-Passwort erstellen, das anschließend zur Authentifizierung im externen Mail-Client verwendet werden kann.

Der Tab setzt die Mailbox-ACL **App-Passwörter verwalten** voraus. Ein App-Passwort erlaubt nie ein Protokoll, das die Mailbox selbst nicht erlaubt.

---

### **Fehlersuche**  

Wenn Benutzer sich nicht anmelden können, zuerst die Logs unter `System > Information > Protokolle > mailcow UI` prüfen.  
Danach helfen diese Schritte:  

1. **Verbindung testen**  
    - `System > Konfiguration > Zugang > Identity Provider` öffnen.  
    - Auf **Verbindung Testen** klicken, der Test muss erfolgreich sein.  

2. **Client-Daten überprüfen**  
    - `System > Konfiguration > Zugang > Identity Provider` öffnen.  
    - **Client-ID** und **Client-Secret** müssen mit den Daten des OIDC-Providers übereinstimmen.  

3. **Mail Domain des Benutzers prüfen**  
    - Die Domain des Benutzers muss in mailcow existieren.  
    - Prüfen, ob die Domain durch **"Max. Mailboxanzahl"** oder **"Domain Speicherplatz gesamt (MiB)"** eingeschränkt ist.  

4. **Attribut Mapping prüfen**  
    - Für die Benutzer muss ein passendes **Attribut Mapping** konfiguriert sein.  

5. **`sub` und E-Mail-Adresse prüfen**  
    - Der OIDC-Provider muss die Claims `email` und `sub` liefern. Steht im Log „The mailbox is linked to another IdP user“, die **IdP-Verknüpfung** der Mailbox prüfen.
