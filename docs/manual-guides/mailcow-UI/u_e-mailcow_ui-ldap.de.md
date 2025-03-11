### **Konfigurieren**  

Um einen **Identity Provider** zu konfigurieren, melden Sie sich als Administrator in der *mailcow UI* an, navigieren Sie zu  
`System > Konfiguration > Zugriff > Identity Provider` und wählen Sie **LDAP** aus dem Dropdown-Menü aus.  

* `Host`: Die Adresse Ihres LDAP-Servers. Sie können entweder eine einzelne Hostadresse oder eine durch Kommas getrennte Liste von Hosts angeben, die als Fallbacks verwendet werden können.  
* `Port`: Der Port, über den die Verbindung zum LDAP-Server hergestellt wird.  
* `Benutze SSL`: Aktiviert eine LDAPS-Verbindung. Wenn der Port auf `389` gesetzt ist, wird er automatisch auf `636` geändert.  
* `Benutze TLS`: Aktiviert eine TLS-Verbindung. **TLS wird gegenüber SSL empfohlen**. SSL-Ports können nicht verwendet werden.  
* `Ignoriere SSL Fehler`: Wenn aktiviert, wird die Überprüfung des SSL-Zertifikats deaktiviert.  
* `Base DN`: Der Distinguished Name (DN), von dem aus Suchanfragen durchgeführt werden.  
* `Username Feld`: Das LDAP-Attribut, das zur Identifizierung von Benutzern bei der Authentifizierung verwendet wird. Standardwert: `mail`.  
* `Filter`: Ein optionaler LDAP-Suchfilter, um einzuschränken, welche Benutzer sich authentifizieren können.  
* `Attribut Feld`: Gibt ein LDAP-Attribut an, dessen Wert einer Mailbox-Vorlage über die **Attribut Mapping** zugeordnet werden kann.  
* `Bind DN`: Der Distinguished Name (DN) des LDAP-Benutzers, der für die Authentifizierung und LDAP-Suchanfragen verwendet wird. Dieses Konto sollte ausreichende Berechtigungen zum Lesen der erforderlichen Attribute haben.  
* `Bind-Passwort`: Das Passwort für den **Bind DN**-Benutzer. Es wird für die Authentifizierung beim Herstellen einer Verbindung mit dem LDAP-Server benötigt.  
* `Attribut Mapping`:
    * `Attribut`: Definiert den LDAP-Attributwert, der zugeordnet werden soll.  
    * `Vorlage`: Gibt an, welche Mailbox-Vorlage für den definierten LDAP-Attributwert angewendet werden soll.  
* `Periodic Full Sync`: Wenn aktiviert, wird regelmäßig eine vollständige Synchronisation aller LDAP-Benutzer durchgeführt.  
* `Import Users`: Wenn aktiviert, werden neue Benutzer automatisch aus LDAP in mailcow importiert.  
* `Sync / Import interval (min)`: Definiert das Zeitintervall (in Minuten) für den "Periodic Full Sync" und den "Import Users".  

---

### **Automatische Benutzerbereitstellung**  

Wenn ein Benutzer in **mailcow** ^^nicht^^ existiert und sich über **Mail-Protokolle** (IMAP, SIEVE, POP3, SMTP) oder die **mailcow UI** anmeldet, wird er **automatisch erstellt**, sofern ein passendes **Attribut Mapping** konfiguriert ist.

#### **Funktionsweise**  
1. Bei der Anmeldung führt **mailcow** einen **LDAP-Bind** durch und ruft bei Erfolg die LDAP-Attribute des Benutzers ab.  
2. **mailcow** sucht nach dem angegebenen **`Attribut Feld`** und ruft dessen Wert ab.  
3. Wenn der Wert mit einem Attribut in der **Attribut Mapping** übereinstimmt, wird die entsprechende **Mailbox-Vorlage** angewendet.  

#### **Beispielkonfiguration**  
- Der Benutzer hat das LDAP-Attribut **`otherMailbox`** mit dem Wert **`default`**.  
- In **mailcow** wird das **`Attribut Feld`** auf **`otherMailbox`** gesetzt.  
- Unter **Attribut Mapping** wird das **`Attribut`** auf **`default`** gesetzt und eine geeignete Mailbox-Vorlage ausgewählt.

!!! info "Hinweis"
	Der Attribut Wert (in dem Fall `default`) muss von mailcow auf eine Mailbox Vorlage gemappt werden, damit neue Mailboxen mit dieser Vorlage erstellt werden.

	Es sind mehrere Mappings möglich.

#### **Updates bei der Anmeldung**  
Jedes Mal, wenn sich ein Benutzer anmeldet, überprüft **mailcow**, ob sich die zugewiesene Vorlage geändert hat. Falls ja, werden die Mailbox-Einstellungen entsprechend aktualisiert.  

#### **Import und Updates über Crontasks**  

Wenn die Option **Benutzer importieren** aktiviert ist, wird ein geplanter Cron-Job ausgeführt, der Benutzer aus dem LDAP in mailcow importiert. Dies erfolgt in dem festgelegten **Sync / Import interval (min)**.  

Wenn die Option **Vollsynchronisation** aktiviert ist, aktualisiert der Cron-Job auch **bestehende Benutzer** im festgelegten **Sync / Import interval (min)** und übernimmt Änderungen aus LDAP in mailcow.  

Logs zu Importen und Synchronisationen können unter `System > Information > Logs > Crontasks` eingesehen werden.  

---

### **Authentifizierungsquelle für bestehende Benutzer ändern**  

Nachdem ein **LDAP Identity Provider** konfiguriert wurde, kann die Authentifizierungsquelle bestehender Benutzer von **mailcow** auf **LDAP** umgestellt werden. 

1. Navigieren Sie zu **`E-Mail > Konfiguration > Mailboxen`**.  
2. Bearbeiten Sie den Benutzer.  
3. Wählen Sie im **Identity Provider**-Dropdown **LDAP** aus.  
4. Speichern Sie die Änderungen.    

!!! note "Hinweis"

    Das bestehende SQL-Passwort wird **nicht überschrieben**. Falls die Authentifizierungsquelle wieder auf **mailcow** umgestellt wird, kann der Benutzer sich wieder mit seinem vorherigen Passwort anmelden.  

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

4. **LDAP-Filter prüfen**  
    - Falls ein **LDAP-Filter** konfiguriert wurde, stellen Sie sicher, dass er die richtigen Benutzer einschließt.  

Falls Probleme mit den Optionen **`Vollsynchronisation`** oder **`Benutzer importieren`** auftreten, überprüfen Sie die Logs unter:  
`System > Information > Logs > Crontasks`.  
