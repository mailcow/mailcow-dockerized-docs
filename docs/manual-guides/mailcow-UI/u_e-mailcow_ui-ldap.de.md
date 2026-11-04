### **Konfigurieren**  

Ein **Identity Provider** wird als Administrator in der *mailcow UI* unter  
`System > Konfiguration > Zugang > Identity Provider` konfiguriert. Dort **LDAP** im Dropdown-Menü auswählen.  

**Verbindung**

* `Host`: Die Adresse des LDAP-Servers. Möglich ist eine einzelne Hostadresse oder eine durch Kommas getrennte Liste von Hosts, die als Fallbacks dienen.  
* `Port`: Der Port, über den die Verbindung zum LDAP-Server hergestellt wird.  
* `Verschlüsselung`: `Keine`, `StartTLS` (nutzt den normalen Port, meist `389`) oder `SSL (LDAPS)`. Bei SSL wird Port `389` automatisch auf `636` geändert.  
* `Ignoriere SSL Fehler`: Wenn aktiviert, wird die Überprüfung des SSL-Zertifikats deaktiviert.  
* `Bind DN`: Der Distinguished Name (DN) des LDAP-Benutzers, der für die Authentifizierung und LDAP-Suchanfragen verwendet wird. Dieses Konto sollte ausreichende Berechtigungen zum Lesen der erforderlichen Attribute haben.  
* `Bind Passwort`: Das Passwort für den **Bind DN**-Benutzer. Es wird für die Authentifizierung beim Herstellen einer Verbindung mit dem LDAP-Server benötigt.  

**Benutzer**

* `Base DN`: Der Distinguished Name (DN), von dem aus Suchanfragen durchgeführt werden.  
* `Filter`: Ein optionaler LDAP-Suchfilter, um einzuschränken, welche Benutzer sich authentifizieren können und synchronisiert werden, z. B. `(objectClass=person)`.  
* `Username Feld`: Das LDAP-Attribut mit der E-Mail-Adresse der Benutzer, sie wird zum Mailbox-Namen. Standardwert: `mail`.  
* `ID-Attribut`: Attribut mit einer unveränderlichen Benutzer-ID, damit werden [Mailboxen und LDAP-Benutzer verknüpft](u_e-mailcow_ui-idp-sync.md#verknupfung-von-mailboxen-und-idp-benutzern). Ist es leer, nutzt mailcow `objectGUID`, `entryUUID`, `nsUniqueId` oder `ipaUniqueID`, sonst den DN.  
* `Filter für deaktivierte Benutzer`: Optionaler LDAP-Filter für deaktivierte Benutzer, genutzt für das [Offboarding](u_e-mailcow_ui-idp-sync.md#offboarding). Active-Directory-Konten, die in `userAccountControl` deaktiviert sind, gelten immer als deaktiviert.  

**Anmeldung**

* `Benutzer beim Login erstellen`: Wenn aktiviert, werden Mailboxen bei der ersten Anmeldung eines Benutzers angelegt, siehe [Automatische Benutzerbereitstellung](#automatische-benutzerbereitstellung).  

**Postfach-Vorlagen**

* `Attribut Feld`: Gibt ein LDAP-Attribut an, dessen Wert einer Mailbox-Vorlage über die **Attribut Mapping** zugeordnet werden kann.  
* `Standardvorlage`: Wird beim Anlegen einer Mailbox verwendet, wenn kein Attribut Mapping passt. Auf bestehende Mailboxen wird sie nicht angewendet.  
* `Attribut Mapping`:
    * `Attribut`: Definiert den LDAP-Attributwert, der zugeordnet werden soll.  
    * `Vorlage`: Gibt an, welche Mailbox-Vorlage für den definierten LDAP-Attributwert angewendet werden soll.  

**Synchronisation** und **Gruppen**

* Import von Benutzern, Vollsynchronisation, Offboarding und Gruppen-Sync sind unter [Identity Provider Synchronisation](u_e-mailcow_ui-idp-sync.md) beschrieben.  

---

### **Automatische Benutzerbereitstellung**  

Wenn ein Benutzer in **mailcow** ^^nicht^^ existiert und sich über **Mail-Protokolle** (IMAP, SIEVE, POP3, SMTP) oder die **mailcow UI** anmeldet, wird er **automatisch erstellt**, sofern `Benutzer beim Login erstellen` aktiv ist und ein passendes **Attribut Mapping** oder eine **Standardvorlage** konfiguriert ist.

#### **Funktionsweise**  
1. Bei der Anmeldung führt **mailcow** einen **LDAP-Bind** durch und ruft bei Erfolg die LDAP-Attribute des Benutzers ab.  
2. **mailcow** sucht nach dem angegebenen **`Attribut Feld`** und ruft dessen Wert ab.  
3. Wenn der Wert mit einem Attribut in der **Attribut Mapping** übereinstimmt, wird die entsprechende **Mailbox-Vorlage** angewendet. Andernfalls wird die **Standardvorlage** verwendet.  

#### **Beispielkonfiguration**  
- Der Benutzer hat das LDAP-Attribut **`otherMailbox`** mit dem Wert **`default`**.  
- In **mailcow** wird das **`Attribut Feld`** auf **`othermailbox`** gesetzt.  
- Unter **Attribut Mapping** wird das **`Attribut`** auf **`default`** gesetzt und eine geeignete Mailbox-Vorlage ausgewählt.

#### **Updates bei der Anmeldung**  
Jedes Mal, wenn sich ein Benutzer anmeldet, überprüft **mailcow**, ob sich die zugewiesene Vorlage geändert hat. Falls ja, werden die Mailbox-Einstellungen entsprechend aktualisiert. Vorlagen von [Gruppen](u_e-mailcow_ui-groups.md#mailbox-template) haben Vorrang vor dem Attribut Mapping.  

#### **Import und Updates über Crontasks**  
Benutzer lassen sich auch im Hintergrund importieren und aktualisieren, ohne auf ihre Anmeldung zu warten. Deaktivierte oder gelöschte Benutzer können automatisch ihren Login verlieren (Offboarding), und LDAP-Gruppen lassen sich in mailcow-Gruppen synchronisieren. Siehe [Identity Provider Synchronisation](u_e-mailcow_ui-idp-sync.md).  

---

### **Authentifizierungsquelle für bestehende Benutzer ändern**  

Nachdem ein **LDAP Identity Provider** konfiguriert wurde, kann die Authentifizierungsquelle bestehender Benutzer von **mailcow** auf **LDAP** umgestellt werden. 

1. **`E-Mail > Konfiguration > Mailboxen`** öffnen.  
2. Den Benutzer bearbeiten.  
3. Im **Identity Provider**-Dropdown **LDAP** auswählen.  
4. Die Änderungen speichern.    

!!! info "Hinweis"

    Das bestehende SQL-Passwort wird **nicht überschrieben**. Falls die Authentifizierungsquelle wieder auf **mailcow** umgestellt wird, kann der Benutzer sich wieder mit seinem vorherigen Passwort anmelden.  

---

### **Eigenes CA Zertifikat für TLS/SSL Verbindungen nutzen**  

Um ein eigenes CA-Zertifikat für die TLS/SSL-Verbindung zum LDAP-Server zu verwenden, muss eine `docker-compose.override.yml` erstellt werden.  
Das CA-Zertifikat sollte unter `data/assets/ssl/ldap-ca.crt` abgelegt werden.  
Die `docker-compose.override.yml` sieht dann wie folgt aus:  
```yaml
services:

  php-fpm-mailcow:
    environment:
      - LDAPTLS_CACERT=/etc/ssl/certs/ldap-ca.crt
    volumes:
      - ./data/assets/ssl/ldap-ca.crt:/etc/ssl/certs/ldap-ca.crt:z
```

Danach den PHP-FPM Container neu erstellen mit:  
=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

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

4. **LDAP-Filter prüfen**  
    - Ist ein **LDAP-Filter** konfiguriert, muss er die richtigen Benutzer einschließen.  

5. **Eindeutigen Anmeldenamen prüfen**  
    - Der Anmeldename (`Username Feld`) muss innerhalb von `Base DN` und `Filter` zu genau einem Eintrag passen, sonst wird der Login abgelehnt. E-Mail-Adressen müssen eindeutig sein, siehe [Verknüpfung von Mailboxen und IdP-Benutzern](u_e-mailcow_ui-idp-sync.md#verknupfung-von-mailboxen-und-idp-benutzern).  

Bei einem Ausfall des LDAP-Servers siehe [Ausfall des Identity Providers](u_e-mailcow_ui-netfilter.md#ausfall-des-identity-providers).

Bei Problemen mit der Synchronisation helfen die Karte **Sync-Status** in den Identity-Provider-Einstellungen und die Logs unter:  
`System > Information > Protokolle > Crontasks`.  
