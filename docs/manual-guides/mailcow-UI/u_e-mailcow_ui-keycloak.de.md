### **Konfigurieren**  

Ein **Identity Provider** wird als Administrator in der *mailcow UI* unter  
`System > Konfiguration > Zugang > Identity Provider` konfiguriert. Dort **Keycloak** im Dropdown-Menü auswählen.  

**Verbindung**

* `Server URL`: Die Basis-URL des Keycloak-Servers.  
* `Realm`: Das Keycloak-Realm, in dem der mailcow Client konfiguriert ist.  
* `Version`: Die verwendete Keycloak-Version.  
* `Client ID`: Die Client-ID, die dem mailcow Client in Keycloak zugewiesen wurde.  
* `Client Secret`: Das Client-Secret des mailcow Clients in Keycloak.  
* `Ignoriere SSL Fehler`: Wenn aktiviert, wird die Überprüfung des SSL-Zertifikats deaktiviert.  

**Anmeldung**

* `Redirect URL`: Die Redirect-URL, die Keycloak nach der Authentifizierung verwendet. Diese sollte auf die mailcow UI verweisen. Beispiel: `https://mail.mailcow.tld`. Über **Redirect-URL hinzufügen** lassen sich weitere URLs eintragen, z. B. für zusätzliche Hostnamen.  
* `Mailpassword Flow`: Wenn aktiviert, versucht mailcow, Benutzeranmeldeinformationen über die **Keycloak Admin REST API** zu validieren, anstatt sich ausschließlich auf den Authorization Code Flow zu verlassen.  
    * Dies erfordert, dass der Benutzer in Keycloak ein **mailcow_password**-Attribut gesetzt hat. Das **mailcow_password** sollte ein gehashtes Passwort enthalten.  
    * Der mailcow Client in Keycloak muss über ein **Service Account** und die Berechtigung **view-users** verfügen.  
* `Benutzer beim Login erstellen`: Wenn aktiviert, werden Mailboxen bei der ersten Anmeldung eines Benutzers angelegt, siehe [Automatische Benutzerbereitstellung](#automatische-benutzerbereitstellung).  

**Postfach-Vorlagen**

* `Standardvorlage`: Wird beim Anlegen einer Mailbox verwendet, wenn kein Attribut Mapping passt. Auf bestehende Mailboxen wird sie nicht angewendet.  
* `Attribut Mapping`:
    * `Attribut`: Definiert den Attributwert, der zugeordnet werden soll.  
    * `Vorlage`: Bestimmt, welche Mailbox-Vorlage für den definierten Attributwert angewendet werden soll.  

**Synchronisation** und **Gruppen**

* Import von Benutzern, Vollsynchronisation, Offboarding und Gruppen-Sync sind unter [Identity Provider Synchronisation](u_e-mailcow_ui-idp-sync.md) beschrieben.  

!!! info "Keycloak 24 und neuer"
    Keycloak speichert nur Benutzerattribute, die im User Profile definiert sind. `mailcow_template` (und für den Mailpassword Flow `mailcow_password`) muss deshalb im User Profile des Realms angelegt sein, alternativ in den Realm-Einstellungen **Unmanaged attributes** aktivieren.

---

### **Automatische Benutzerbereitstellung**  

Wenn ein Benutzer in **mailcow** nicht existiert und sich über die **mailcow UI** anmeldet, wird er **automatisch erstellt**, sofern `Benutzer beim Login erstellen` aktiv ist und ein passendes **Attribut Mapping** oder eine **Standardvorlage** konfiguriert ist.  

#### **Funktionsweise**  
1. Bei der Anmeldung initialisiert **mailcow** einen **Authorization Code Flow** und ruft bei Erfolg das **OIDC-Token** des Benutzers ab.  
2. **mailcow** sucht dann im User Info Endpoint nach dem Wert von **`mailcow_template`** und ruft ihn ab.  
3. Wenn der Wert mit einem Attribut in dem **Attribut Mapping** übereinstimmt, wird die entsprechende **Mailbox-Vorlage** angewendet. Andernfalls wird die **Standardvorlage** verwendet.  

#### **Beispielkonfiguration**  
- Der Benutzer hat das Attribut **`mailcow_template`** mit dem Wert **`default`**, das vom User Info Endpoint abgerufen werden kann.  
- Unter **Attribut Mapping** wird das **`Attribut`** auf **`default`** gesetzt und eine geeignete **Mailbox-Vorlage** ausgewählt.  

#### **Updates bei der Anmeldung**  
Jedes Mal, wenn sich ein Benutzer über die **mailcow UI** (mit dem [Mailpassword Flow](#mailpassword-flow) auch über Mail-Protokolle) anmeldet, überprüft **mailcow**, ob sich die zugewiesene **Mailbox-Vorlage** geändert hat. Falls ja, werden die Mailbox-Einstellungen entsprechend aktualisiert. Vorlagen von [Gruppen](u_e-mailcow_ui-groups.md#mailbox-template) haben Vorrang vor dem Attribut Mapping.  

#### **Import und Updates über Crontasks**  
Benutzer lassen sich auch im Hintergrund importieren und aktualisieren, ohne auf ihre Anmeldung zu warten. Deaktivierte oder gelöschte Benutzer können automatisch ihren Login verlieren (Offboarding), und Keycloak-Gruppen lassen sich in mailcow-Gruppen synchronisieren. Siehe [Identity Provider Synchronisation](u_e-mailcow_ui-idp-sync.md).  

---

### **Mailpassword Flow**  
!!! warning "Voraussetzung"

    Dies erfordert, dass **mailcow** Zugriff auf die **Keycloak Admin REST API** hat.  
    Der **mailcow Client** braucht einen **Service Account**, dem die Service Account Role **view-users** zugewiesen ist.   

Der **Mailpassword Flow** ist eine direkte Authentifizierungsmethode, die **nicht** das **OIDC-Protokoll** verwendet. Er dient als Alternative zum **Authorization Code Flow**.  

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

1. **`E-Mail > Konfiguration > Mailboxen`** öffnen.  
2. Den Benutzer bearbeiten.  
3. Im **Identity Provider**-Dropdown **Keycloak** auswählen.  
4. Die Änderungen speichern.  

!!! info "Hinweis"

    Das bestehende SQL-Passwort wird **nicht überschrieben**. Falls die Authentifizierungsquelle wieder auf **mailcow** umgestellt wird, kann der Benutzer sich wieder mit seinem vorherigen Passwort anmelden.  

---

### **Authentifizierung für externe Mail-Clients (IMAP, SIEVE, POP3, SMTP)**  
!!! info "Hinweis"

    Dies gilt nicht zwingend für Benutzer, die den Mailpassword Flow verwenden.

Bevor Benutzer externe Mail-Clients nutzen können, müssen sie sich zunächst in die mailcow UI einloggen und zu den **Mailbox-Einstellungen** navigieren.  
Im Tab **App-Passwörter** können sie ein neues App-Passwort erstellen, das anschließend zur Authentifizierung im externen Mail-Client verwendet werden kann.

Der Tab setzt die Mailbox-ACL **App-Passwörter verwalten** voraus. Ein App-Passwort erlaubt nie ein Protokoll, das die Mailbox selbst nicht erlaubt.

---

### **Fehlersuche**  

Wenn Benutzer sich nicht anmelden können, zuerst die Logs unter `System > Information > Protokolle > mailcow UI` prüfen.  
Danach helfen diese Schritte:  

1. **Verbindung testen**  
    - **`System > Konfiguration > Zugang > Identity Provider`** öffnen.  
    - Auf **Verbindung Testen** klicken, der Test muss erfolgreich sein.  

2. **Mail Domain des Benutzers prüfen**  
    - Die Domain des Benutzers muss in mailcow existieren.  
    - Prüfen, ob die Domain durch **"Max. Mailboxanzahl"** oder **"Domain Speicherplatz gesamt (MiB)"** eingeschränkt ist.  

3. **Attribut Mapping prüfen**  
    - Für die Benutzer muss ein passendes **Attribut Mapping** konfiguriert sein.  

4. **E-Mail-Adresse prüfen**  
    - Die E-Mail-Adresse muss in Keycloak eindeutig sein. Der **Mailpassword Flow** setzt genau einen Benutzer mit dieser E-Mail-Adresse voraus, siehe [Verknüpfung von Mailboxen und IdP-Benutzern](u_e-mailcow_ui-idp-sync.md#verknupfung-von-mailboxen-und-idp-benutzern).  

Bei einem Ausfall von Keycloak siehe [Ausfall des Identity Providers](u_e-mailcow_ui-netfilter.md#ausfall-des-identity-providers).

Bei Problemen mit der Synchronisation helfen die Karte **Sync-Status** in den Identity-Provider-Einstellungen und die Logs unter:  
`System > Information > Protokolle > Crontasks`.  
