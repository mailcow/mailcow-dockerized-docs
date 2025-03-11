### **Konfigurieren**  

Um einen **Identity Provider** zu konfigurieren, melde Sie sich als Administrator in der *mailcow UI* an, navigieren Sie zu  
`System > Konfiguration > Zugriff > Identity Provider` und wählen Sie **Generic-OIDC** aus dem Dropdown-Menü aus.  

* `Authorization Endpoint`: Die URL des Authorization Endpoints des Provider's.  
* `Token Endpoint`: Die URL des Token Endpoints des Provider's.  
* `User Info Endpoint`: Die URL des User Info Endpoint des Provider's.  
* `Client ID`: Die Client-ID, die dem mailcow Client im OIDC-Provider zugewiesen wurde.  
* `Client Secret`: Das Client-Secret, das dem mailcow Client im OIDC-Provider zugewiesen wurde.  
* `Redirect URL`: Die Redirect-URL, die der OIDC-Provider nach der Authentifizierung verwendet. Diese sollte auf die mailcow UI verweisen. Beispiel: `https://mail.mailcow.tld`  
* `Client Scopes`: Gibt die während der Authentifizierung angeforderten **OIDC-Scopes** an. Die Standard-Scopes sind `openid profile email mailcow_template`.  
* `Attribut Mapping`:
    * `Attribut`: Definiert den Attributwert, der zugeordnet werden soll.  
    * `Vorlage`: Gibt an, welche Mailbox-Vorlage für den definierten Attributwert angewendet werden soll.  
* `Ignoriere SSL Errors`: Wenn aktiviert, wird die Überprüfung des SSL-Zertifikats deaktiviert.  

---

### **Automatische Benutzerbereitstellung**  

Wenn ein Benutzer in **mailcow** nicht existiert und sich über die **mailcow UI** anmeldet, wird er **automatisch erstellt**, sofern eine passende **Attribut Mapping** konfiguriert ist.  

#### **Funktionsweise**  
1. Bei der Anmeldung initialisiert **mailcow** einen **Authorization Code Flow** und ruft bei Erfolg das **OIDC-Token** des Benutzers ab.  
2. **mailcow** sucht dann im User Info Endpoint nach dem Wert von `mailcow_template` und ruft ihn ab.  
3. Wenn der Wert mit einem Attribut in der **Attribut Mapping** übereinstimmt, wird die entsprechende **Mailbox-Vorlage** angewendet.  

#### **Beispielkonfiguration**  
- Der Benutzer hat das Attribut `mailcow_template` mit dem Wert `default`, das vom **User Info Endpoint** abgerufen werden kann.  
- Unter **Attribut Mapping** setzt du `Attribut` auf `default` und wählst eine geeignete **Mailbox-Vorlage** aus.  

#### **Updates bei der Anmeldung**  
Jedes Mal, wenn sich ein Benutzer über die **mailcow UI** anmeldet, überprüft **mailcow**, ob sich die zugewiesene **Vorlage** geändert hat. Falls ja, werden die Mailbox-Einstellungen entsprechend aktualisiert.  

---

### **Authentifizierungsquelle für bestehende Benutzer ändern**  

Nachdem ein **Generic-OIDC Identity Provider** konfiguriert wurde, kann die Authentifizierungsquelle bestehender Benutzer von **mailcow** auf **Generic-OIDC** umgestellt werden.  

1. Navigiere Sie zu `E-Mail > Konfiguration > Mailboxen`.  
2. Bearbeiten Sie den Benutzer.  
3. Wählen Sie im **Identity Provider**-Dropdown **Generic-OIDC** aus.  
4. Speichern Sie die Änderungen. 

!!! note "Hinweis"

    Das bestehende SQL-Passwort wird **nicht überschrieben**. Falls die Authentifizierungsquelle wieder auf **mailcow** umgestellt wird, kann der Benutzer sich weiterhin mit seinem vorherigen Passwort anmelden.  

---

### **Fehlersuche**  

Wenn Benutzer sich nicht anmelden können, überprüfen Sie zuerst die Logs unter:  
`System > Information > Logs > mailcow UI`.  

Danach können Sie diesen Schritten zur Fehlerbehebung folgen:  

1. **Verbindung testen**  
    - Gehen Sie zu `System > Konfiguration > Zugriff > Identity Provider`.  
    - Klicken Sie den **Verbindung Testen** Button und stellen Sie sicher, dass er erfolgreich abgeschlossen wird.  

2. **Client-Daten überprüfen**  
    - Gehe zu `System > Konfiguration > Zugriff > Identity Provider`.  
    - Stelle sicher, dass **Client-ID** und **Client-Secret** mit den Daten des OIDC-Provider's übereinstimmen.  

3. **Mail Domain des Benutzers prüfen**  
    - Stellen Sie sicher, dass die Domain des Benutzers in mailcow existiert.  
    - Überprüfen Sie, ob die Domain durch **"Max. Mailboxanzahl"** oder **"Domain Speicherplatz gesamt (MiB)"** eingeschränkt ist.  

3. **Attribut Mapping prüfen**  
    - Stellen Sie sicher, dass eine passendes **Attribut Mapping** für die Benutzer konfiguriert ist.  

Falls Probleme mit `Periodic Full Sync` oder `Import Users` auftreten, überprüfen Sie die Logs unter:  
`System > Information > Logs > Crontasks`. 
