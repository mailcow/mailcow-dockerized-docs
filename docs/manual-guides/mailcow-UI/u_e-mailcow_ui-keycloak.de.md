### **Konfigurieren**  

Um einen **Identity Provider** zu konfigurieren, melden Sie sich als Administrator in der *mailcow UI* an, navigieren Sie zu  
`System > Konfiguration > Zugriff > Identity Provider` und wählen Sie **Keycloak** aus dem Dropdown-Menü aus.  

* `Server URL`: Die Basis-URL Ihres Keycloak-Servers.  
* `Realm`: Das Keycloak-Realm, in dem der mailcow Client konfiguriert ist.  
* `Client ID`: Die Client-ID, die dem mailcow Client in Keycloak zugewiesen wurde.  
* `Client Secret`: Das Client-Secret des mailcow Clients in Keycloak.  
* `Redirect URL`: Die Redirect-URL, die Keycloak nach der Authentifizierung verwendet. Diese sollte auf die mailcow UI verweisen. Beispiel: `https://mail.mailcow.tld`  
* `Version`: Die verwendete Keycloak-Version.  
* `Attribut Mapping`:
    * `Attribut`: Definiert den Attributwert, der zugeordnet werden soll.  
    * `Vorlage`: Bestimmt, welche Mailbox-Vorlage für den definierten LDAP-Attributwert angewendet werden soll.  
* `Mailpassword Flow`: Wenn aktiviert, versucht mailcow, Benutzeranmeldeinformationen über die **Keycloak Admin REST API** zu validieren, anstatt sich ausschließlich auf den Authorization Code Flow zu verlassen.  
    * Dies erfordert, dass der Benutzer in Keycloak ein **mailcow_password**-Attribut gesetzt hat. Das **mailcow_password** sollte ein gehashtes Passwort enthalten.  
    * Der mailcow Client in Keycloak muss über ein **Service Account** und die Berechtigung **view-users** verfügen.  
* `Ignoriere SSL Fehler`: Wenn aktiviert, wird die Überprüfung des SSL-Zertifikats deaktiviert.  
* `Vollsynchronisation`: Wenn aktiviert, synchronisiert mailcow regelmäßig alle Benutzer aus Keycloak.  
* `Importiere Benutzer`: Wenn aktiviert, werden neue Benutzer automatisch aus Keycloak in mailcow importiert.  
* `Sync / Import interval (min)`: Definiert das Zeitintervall (in Minuten) für die Option "Vollsynchronisation" und die Option "Importiere Benutzer".  

---

### **Automatische Benutzerbereitstellung**  

Wenn ein Benutzer in **mailcow** nicht existiert und sich über die **mailcow UI** anmeldet, wird er **automatisch erstellt**, sofern ein passendes **Attribut Mapping** konfiguriert ist.  

#### **Funktionsweise**  
1. Bei der Anmeldung initialisiert **mailcow** einen **Authorization Code Flow** und ruft bei Erfolg das **OIDC-Token** des Benutzers ab.  
2. **mailcow** sucht dann im User Info Endpoint nach dem Wert von **`mailcow_template`** und ruft ihn ab.  
3. Wenn der Wert mit einem Attribut in dem **Attribut Mapping** übereinstimmt, wird die entsprechende **Mailbox-Vorlage** angewendet.  

#### **Beispielkonfiguration**  
- Der Benutzer hat das Attribut **`mailcow_template`** mit dem Wert **`default`**, das vom User Info Endpoint abgerufen werden kann.  
- Unter **Attribut Mapping** wird das **`Attribut`** auf **`default`** gesetzt und eine geeignete **Mailbox-Vorlage** ausgewählt.  

#### **Updates bei der Anmeldung**  
Jedes Mal, wenn sich ein Benutzer über die **mailcow UI** anmeldet, überprüft **mailcow**, ob sich die zugewiesene **Mailbox-Vorlage** geändert hat. Falls ja, werden die Mailbox-Einstellungen entsprechend aktualisiert.  

#### **Import und Updates über Crontasks**  
!!! warning "Voraussetzung"

    Dies erfordert, dass **mailcow** Zugriff auf die **Keycloak Admin REST API** hat.  
    Stellen Sie sicher, dass der **mailcow Client** ein **Service Account** hat und diesem die Service Account Role **view-users** zugewiesen wurde.  

Wenn **Importiere Benutzer** aktiviert ist, wird ein geplanter Cron-Job ausgeführt, der Benutzer aus Keycloak nach mailcow importiert. Dies erfolgt in dem festgelegten **Sync / Import interval (min)**.  

Wenn **Vollsynchronisation** aktiviert ist, aktualisiert der Cron-Job auch bestehende Benutzer im festgelegten **Sync / Import interval (min)** und übernimmt Änderungen aus Keycloak in mailcow.  

Logs zu Importen und Synchronisationen können unter `System > Information > Logs > Crontasks` eingesehen werden.  

---

### **Mailpassword Flow**  
!!! warning "Voraussetzung"

    Dies erfordert, dass **mailcow** Zugriff auf die **Keycloak Admin REST API** hat.  
    Stellen Sie sicher, dass der **mailcow Client** ein **Service Account** hat und diesem die Service Account Role **view-users** zugewiesen wurde.   

Der **Mailpassword Flow** ist eine direkte Authentifizierungsmethode, die **nicht** das **OIDC-Protokoll** verwendet. Sie dient als Alternative zum **Authorization Code Flow**.  

Mit dem **Mailpassword Flow** funktioniert die automatische Benutzerbereitstellung auch für Anmeldungen über **Mail-Protokolle** (IMAP, SIEVE, POP3, SMTP).  

#### **Funktionsweise**  
1. Bei der Anmeldung ruft **mailcow** die Benutzerattribute über die **Keycloak Admin REST API** ab.  
2. **mailcow** sucht nach dem **`mailcow_password`**-Attribut.  
3. Der Wert von **`mailcow_password`** muss ein [**kompatibles, gehashtes Passwort**](../../models/model-passwd.md) enthalten, das zur Authentifizierung verwendet wird.  

Dies gewährleistet eine nahtlose Authentifizierung und automatische Mailbox-Erstellung für Anmeldungen über mailcow UI und Mail-Protokolle.  

#### **Generieren eines BLF-CRYPT-gehashten Passworts**  
Der folgende Befehl erstellt ein bcrypt-gehashtes Passwort und fügt `{BLF-CRYPT}` als Präfix hinzu:  

```bash
mkpasswd -m bcrypt | sed 's/^/{BLF-CRYPT}/'
```

---

### **Authentifizierungsquelle für bestehende Benutzer ändern**  

Nachdem ein **Keycloak Identity Provider** konfiguriert wurde, kann die Authentifizierungsquelle bestehender Benutzer von **mailcow** auf **Keycloak** umgestellt werden.  

1. Navigieren Sie zu **`E-Mail > Konfiguration > Mailboxen`**.  
2. Bearbeiten Sie den Benutzer.  
3. Wählen Sie im **Identity Provider**-Dropdown **Keycloak** aus.  
4. Speichern Sie die Änderungen.  

!!! info "Hinweis"

    Das bestehende SQL-Passwort wird **nicht überschrieben**. Falls die Authentifizierungsquelle wieder auf **mailcow** umgestellt wird, kann der Benutzer sich wieder mit seinem vorherigen Passwort anmelden.  

---

### **Authentifizierung für externe Mail-Clients (IMAP, SIEVE, POP3, SMTP)**  
!!! info "Hinweis"

    Dies gilt nicht zwingend für Benutzer, die den Mailpassword Flow verwenden.

Bevor Benutzer externe Mail-Clients nutzen können, müssen sie sich zunächst in die mailcow UI einloggen und zu den **Mailbox-Einstellungen** navigieren.  
Im Tab **App-Passwörter** können sie ein neues App-Passwort erstellen, das anschließend zur Authentifizierung im externen Mail-Client verwendet werden kann.

---

### **Fehlersuche**  

Wenn Benutzer sich nicht anmelden können, überprüfen Sie zuerst die Logs unter: `System > Information > Logs > mailcow UI`.  
Danach können Sie diesen Schritten zur Fehlerbehebung folgen:  

1. **Verbindung testen**  
    - Gehen Sie zu **`System > Konfiguration > Zugriff > Identity Provider`**.  
    - Klicken Sie den **Verbindung Testen** Button und stellen Sie sicher, dass er erfolgreich abgeschlossen wird.  

2. **Mail Domain des Benutzers prüfen**  
    - Stellen Sie sicher, dass die Domain des Benutzers in mailcow existiert.  
    - Überprüfen Sie, ob die Domain durch **"Max. Mailboxanzahl"** oder **"Domain Speicherplatz gesamt (MiB)"** eingeschränkt ist.  

3. **Attribut Mapping prüfen**  
    - Stellen Sie sicher, dass eine passendes **Attribut Mapping** für die Benutzer konfiguriert ist.  

Falls Probleme mit **`Vollsynchronisation`** oder **`Importiere Benutzer`** auftreten, überprüfen Sie die Logs unter:  
`System > Information > Logs > Crontasks`.  
