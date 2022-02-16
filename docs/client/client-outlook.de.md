<div class="client_outlookEAS_enabled" markdown="1">
## Outlook 2016 oder höher von Office 365 unter Windows

<div class="client_variables_unavailable" markdown="1">
  Dies gilt nur, wenn Ihr Serveradministrator EAS für Outlook nicht deaktiviert hat. Wenn es deaktiviert ist, folgen Sie bitte stattdessen der Anleitung für Outlook 2007.
</div>

Outlook 2016 hat ein [Problem mit der automatischen Erkennung](https://github.com/mailcow/mailcow-dockerized/issues/615). Nur Outlook von Office 365 ist betroffen. Wenn Sie Outlook aus einer anderen Quelle installiert haben, folgen Sie bitte der Anleitung für Outlook 2013 oder höher. 

Für EAS müssen Sie den alten Assistenten verwenden, indem Sie `C:\Program Files (x86)\Microsoft Office\root\Office16\OLCFG.EXE` starten. Wenn diese Anwendung geöffnet wird, können Sie mit Schritt 4 der Anleitung für Outlook 2013 unten fortfahren.

Wenn die Anwendung nicht geöffnet wird, können Sie den [Assistenten zum Erstellen eines neuen Kontos vollständig deaktivieren](https://support.microsoft.com/en-us/help/3189194/how-to-disable-simplified-account-creation-in-outlook) und die nachstehende Anleitung für Outlook 2013 befolgen.

## Outlook 2007 oder höher auf Windows (Kalender/Kontakte via CalDav Synchronizer)

</div>

1. Downloaden und installieren Sie [Outlook CalDav Synchronizer](https://caldavsynchronizer.org).
2. Starten Sie Outlook.
3. Wenn Sie Outlook zum ersten Mal gestartet haben, werden Sie aufgefordert, Ihr Konto einzurichten. Fahren Sie mit Schritt 5 fort.
4. Gehen Sie zum Menü *Datei* und klicken Sie auf *Konto hinzufügen*.
5. Geben Sie Ihren Namen<span class="client_variables_available"> (<code><span class="client_var_name"></span></code>)</span>, Ihre E-Mail Adresse<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> und Ihr Passwort ein. Klicken Sie auf *Weiter*.
6. Klicken Sie auf *Finish*.
7. Gehen Sie zur Multifunktionsleiste *CalDav Synchronizer* und klicken Sie auf *Synchronisationsprofile*.
8. Klicken Sie auf die zweite Schaltfläche oben (*Mehrere Profile hinzufügen*), wählen Sie *Sogo* und klicken Sie auf *Ok*.
9. Klicken Sie auf die Schaltfläche *IMAP/POP3-Kontoeinstellungen abrufen*.
10. Klicken Sie auf *Ressourcen erkennen und Outlook-Ordnern zuweisen*.
11. Wählen Sie im Fenster *Ressource auswählen* Ihren Hauptkalender (in der Regel *Persönlicher Kalender*), klicken Sie auf die Schaltfläche *...*, weisen Sie ihn dem Ordner *Kalender* zu, und klicken Sie auf *OK*. Gehen Sie zu den Registerkarten *Adressbücher* und *Aufgaben* und wiederholen Sie den Vorgang entsprechend. Weisen Sie nicht mehreren Kalendern, Adressbüchern oder Aufgabenlisten zu!
12. Schließen Sie alle Fenster mit den Tasten *OK*.

## Outlook 2013 oder höher unter Windows (Active Sync - nicht empfohlen)

<div class="client_variables_unavailable" markdown="1">
  Dies gilt nur, wenn Ihr Serveradministrator EAS für Outlook nicht deaktiviert hat. Wenn es deaktiviert ist, folgen Sie bitte stattdessen der Anleitung für Outlook 2007.
</div>

1. Starten Sie Outlook.
2. Wenn Sie Outlook zum ersten Mal gestartet haben, werden Sie aufgefordert, Ihr Konto einzurichten. Fahren Sie mit Schritt 4 fort.
3. Öffnen Sie das Menü *Datei* und klicken Sie auf *Konto hinzufügen*.
4. Geben Sie Ihren Namen<span class="client_variables_available"> (<code><span class="client_var_name"></span></code>)</span>, Ihre E-Mail Adresse<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> und Ihr Passwort ein. Klicken Sie auf *Weiter*.
5. Wenn Sie dazu aufgefordert werden, geben Sie Ihr Passwort erneut ein, markieren Sie *Meine Anmeldedaten speichern* und klicken Sie auf *OK*.
6. Klicken Sie auf die Schaltfläche *Zulassen*.
7. Klicken Sie auf *Fertigstellen*.

## Outlook 2011 oder höher unter macOS

Die Mac-Version von Outlook synchronisiert keine Kalender und Kontakte und wird daher nicht unterstützt.
