mailcow hält die Mailboxen mit dem Identity Provider (IdP) synchron: Es legt Mailboxen an, aktualisiert Name und Vorlage, sperrt den Login ausgeschiedener Benutzer und synchronisiert Gruppenmitgliedschaften. Die Synchronisation funktioniert mit **Keycloak** und **LDAP** (inkl. Active Directory). Mit Generic-OIDC werden Mailboxen nur bei der ersten Anmeldung angelegt.

Die Einstellungen stehen unter `System > Konfiguration > Zugang > Identity Provider` in den Abschnitten **Synchronisation** und **Gruppen**. Die Verbindung selbst ist auf den Seiten zu [Keycloak](u_e-mailcow_ui-keycloak.md) und [LDAP](u_e-mailcow_ui-ldap.md) beschrieben.

!!! warning "Keycloak"
    Der mailcow Client in Keycloak benötigt einen **Service Account** mit der Rolle **view-users**. Der Gruppen-Sync benötigt zusätzlich **query-groups**. Ab Keycloak 26.8.2 braucht der Client außerdem den Client Scope **kc-admin-api** als Default Scope.

---

## Synchronisation

* `Importiere Benutzer`: Legt Mailboxen für alle IdP-Benutzer mit passender Vorlage an (siehe [Vorlagen](#vorlagen)), ohne auf ihre erste Anmeldung zu warten. Deaktivierte Benutzer und Benutzer, deren Domain in mailcow nicht existiert, werden übersprungen.
* `Vollsynchronisation`: Aktualisiert Name und Vorlage bestehender Mailboxen.
* `Offboarding`: Sperrt den Login von Benutzern, die im IdP deaktiviert oder entfernt wurden, siehe [Offboarding](#offboarding).
* `Sync / Import interval (min)`: Zeit zwischen zwei Sync-Läufen. Standard: 15 Minuten.
* `Änderungslimit (%)`: Sicherheitsgrenze, siehe [Sicherheit](#sicherheit). Standard: 10 %.

---

## Verknüpfung von Mailboxen und IdP-Benutzern

mailcow speichert, zu welchem IdP-Benutzer eine Mailbox gehört, und nutzt dafür eine ID, die sich nicht ändert:

* Keycloak: die Benutzer-ID.
* LDAP: das Attribut aus `ID-Attribut`. Ist es leer, nutzt mailcow `objectGUID` (Active Directory), `entryUUID` (OpenLDAP), `nsUniqueId` oder `ipaUniqueID`, sonst den DN.
* Generic-OIDC: den Claim `sub`. Mailboxen werden bei der ersten Anmeldung verknüpft.

Synchronisiert werden nur Mailboxen, die den IdP als Authentifizierungsquelle nutzen, Mailboxen mit der Authentifizierungsquelle mailcow bleiben unberührt. Bestehende Mailboxen werden beim ersten Sync oder Login über ihre E-Mail-Adresse verknüpft. Danach kann ein IdP-Benutzer, der später die Adresse eines anderen Benutzers erhält, die Mailbox nicht übernehmen. mailcow meldet solche Fälle als Konflikt.

E-Mail-Adressen müssen im IdP eindeutig sein:

* Haben mehrere IdP-Benutzer dieselbe E-Mail-Adresse, verknüpft und importiert der Sync keinen davon und meldet „Several IdP users have the email …“.
* LDAP: Der Login wird abgelehnt, wenn der Anmeldename zu mehr als einem Eintrag passt.
* Keycloak mit `Mailpassword Flow`: Der Login setzt genau einen Benutzer mit dieser E-Mail-Adresse voraus.
* Keycloak und Generic-OIDC: Passen E-Mail-Adresse oder Benutzer im IdP nicht mehr zur Mailbox, endet die Sitzung in der mailcow UI mit ihrer nächsten Aktualisierung.

Die Bearbeiten-Seite einer Mailbox zeigt die Verknüpfung unter **IdP-Verknüpfung**. Wurde eine Adresse bewusst an eine andere Person vergeben, kann ein Administrator **Verknüpfung lösen** klicken: Die Mailbox wird dann erneut über die E-Mail-Adresse verknüpft. Domain-Administratoren sehen die Verknüpfung nur. Eine Änderung des `ID-Attribut` verknüpft alle Mailboxen erneut über die E-Mail-Adresse.

---

## Offboarding

Ist `Offboarding` aktiv, setzt mailcow Mailboxen auf **Login verbieten (Mails werden weiterhin angenommen)**, wenn der Benutzer

* im IdP deaktiviert ist (Keycloak: Benutzer deaktiviert; Active Directory: Konto in `userAccountControl` deaktiviert; andere LDAP-Server: Treffer im `Filter für deaktivierte Benutzer`) oder
* in zwei vollständigen Sync-Läufen hintereinander fehlt (gelöscht oder aus Base DN bzw. Filter herausgefallen).

Die Mailbox und ihre Mails bleiben erhalten, Mails werden weiter zugestellt. Gelöscht wird die Mailbox nicht automatisch.

Wird der Benutzer im IdP wieder aktiviert, erlaubt mailcow den Login wieder. Das gilt nur für Mailboxen, die der Sync gesperrt hat. Eine von Hand gesperrte Mailbox bleibt gesperrt. Wird eine vom Sync gesperrte Mailbox von Hand wieder aktiviert, während der Benutzer im IdP noch deaktiviert ist, lässt der Sync sie aktiv. Erneut gesperrt wird sie erst, wenn der Benutzer im IdP wieder aktiviert und erneut deaktiviert wurde.

* Der `Filter für deaktivierte Benutzer` wird nur vom Sync ausgewertet, nicht bei der Anmeldung.
* Sync-Läufe erfassen fehlende Benutzer auch, solange `Offboarding` aus ist. Der erste Lauf mit Offboarding sperrt deshalb die Mailboxen von Benutzern, die bereits fehlen oder im IdP deaktiviert sind. Vor dem Aktivieren die Zahl **Fehlen im IdP** in der Karte **Sync-Status** prüfen.

---

## Sicherheit

* Ein Lauf ändert nur etwas, wenn der IdP die vollständige Liste der Benutzer und Gruppen geliefert hat. Verbindungsfehler oder LDAP-Größenlimits brechen den Lauf ohne jede Änderung ab.
* Ein Lauf wird **Blockiert**, wenn er mehr als `Änderungslimit (%)` der aktiven IdP-Mailboxen sperren oder mehr als `Änderungslimit (%)` der IdP-Gruppenmitgliedschaften entfernen würde, jeweils mindestens 5. Ein blockierter Lauf ändert gar nichts: Er legt auch keine Mailboxen an und verknüpft oder aktualisiert keine. Die Änderungen lassen sich mit **Vorschau** prüfen. Sind sie gewollt, **Ohne Limit ausführen** nutzen.

!!! warning "LDAP-Größenlimit"
    mailcow liest die Benutzer seitenweise (Paged Search). Begrenzt der LDAP-Server die Anzahl der Ergebnisse trotzdem (z. B. OpenLDAP mit dem Standardlimit von 500 Einträgen), muss das Limit für den Bind-Benutzer erhöht werden. Sonst bricht jeder Lauf ab.

---

## Gruppen

Ist `Gruppen-Sync` aktiv, synchronisiert mailcow die Mitglieder von IdP-Gruppen in [mailcow-Gruppen](u_e-mailcow_ui-groups.md).

**Keycloak**

* `Gruppenpfade`: Kommagetrennte Gruppenpfade, z. B. `/Vertrieb`, `/mailcow/*` für alle Gruppen unterhalb von `/mailcow` oder `/*` für alle Gruppen.
* Nur direkte Mitglieder einer Gruppe zählen, Mitglieder ihrer Untergruppen nicht.
* Die Mailadresse einer Gruppe stammt aus ihrem Gruppenattribut `mail`.

**LDAP**

* `Gruppen-Base-DN`: Wo die Gruppen gesucht werden. Leer = `Base DN`.
* `Gruppenfilter`: Pflichtfeld, z. B. `(objectClass=group)` für Active Directory oder `(objectClass=groupOfNames)` für OpenLDAP. Ist er leer, während `Gruppen-Sync` aktiv ist, schlägt jeder Lauf fehl.
* `Attribut für Gruppennamen`: Attribut mit dem Gruppennamen. Standard: `cn`.
* `Mitgliedschaften`: Wie Mitgliedschaften gelesen werden:
    * `memberOf der Benutzer`: Das Attribut `memberOf` der Benutzer (Active Directory, OpenLDAP mit memberOf-Overlay).
    * `Mitglieder-Attribut der Gruppen`: Das Attribut aus `Mitglieder-Attribut` der Gruppen, z. B. `member` oder `uniqueMember`. Active Directory liefert die Mitglieder großer Gruppen in Teilbereichen (Ranges), mailcow bricht den Lauf dann ab. Für Active Directory einen der beiden anderen Modi nutzen.
    * `Active Directory inkl. verschachtelter Gruppen`: Mitglieder verschachtelter Gruppen zählen ebenfalls als Mitglieder.
* Die Mailadresse einer Gruppe stammt aus ihrem Attribut `mail`.

**Beide**

* `Gruppen anlegen` (Standard: an): Legt für jede IdP-Gruppe ohne mailcow-Gruppe eine an, und zwar in der Domain der Mailadresse der Gruppe. Gruppen ohne Mailadresse einer mailcow-Domain landen in der `Standard-Domain für Gruppen`. Die Mailadresse wird zur Gruppenadresse, wenn sie frei ist und die Domain noch Aliasse übrig hat.
* Eine gleichnamige mailcow-Gruppe, die nicht mit der IdP-Gruppe verknüpft ist, wird nicht übernommen, mailcow meldet einen Konflikt. Verknüpfen lässt sie sich über ihr Feld `idp_ref` in der [API](u_e-mailcow_ui-api.md).
* Nur Mailboxen mit dem IdP als Authentifizierungsquelle werden IdP-Mitglieder.
* Im IdP umbenannte Gruppen werden in mailcow umbenannt. Wird eine verknüpfte Gruppe in mailcow umbenannt, setzt der nächste Lauf wieder den Namen aus dem IdP.
* Verschwindet eine Gruppe aus dem IdP oder passt sie nicht mehr zu `Gruppenpfade` bzw. `Gruppenfilter`, entfernt mailcow ihre IdP-Mitglieder, siehe [Sicherheit](#sicherheit). Die Gruppe und ihre manuellen Mitglieder bleiben.

Mitglieder aus dem IdP sind in mailcow mit **IdP** markiert, in mailcow hinzugefügte Mitglieder bleiben. Adresse, Senden als, Freigaben und Vorlage einer Gruppe werden in mailcow gepflegt.

---

## Vorlagen

Eine Mailbox aus dem IdP erhält:

1. die Vorlage ihrer Gruppe mit der höchsten Priorität, sonst
2. die Vorlage aus dem `Attribut Mapping`, sonst
3. die `Standardvorlage`, nur beim Anlegen der Mailbox.

Passt keine Vorlage, wird die Mailbox nicht angelegt und der Lauf meldet einen Konflikt.

Bei jeder Anmeldung und mit `Vollsynchronisation` wendet mailcow die Vorlage erneut an, wenn die Mailbox inzwischen geändert wurde. Manuelle Änderungen an IdP-Mailboxen werden dabei überschrieben. Verlässt eine Mailbox alle Gruppen, erhält sie wieder die Vorlage aus dem Attribut Mapping.

---

## Sync-Status

Die Karte **Sync-Status** unter den Einstellungen zeigt die letzten Läufe mit Modus, Ergebnis und Änderungen. Konflikte stehen in den Details eines Laufs.

* **Vorschau**: Zeigt die Änderungen eines Laufs, ohne sie anzuwenden.
* **Jetzt ausführen**: Startet einen Lauf, ohne auf das Intervall zu warten.
* **Ohne Limit ausführen**: Startet einmalig einen Lauf, der das Änderungslimit ignoriert.

Läufe starten innerhalb einer Minute. Das Log steht unter `System > Information > Protokolle > Crontasks` (Task `Identity Sync`).
