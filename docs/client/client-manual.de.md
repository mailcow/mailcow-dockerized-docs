Diese Anweisungen gelten nur für unveränderte Portbindungen!

## E-Mail
|Dienst|Verschlüsselung|Host|Port|
|--- |--- |--- |--- |
|IMAP|STARTTLS|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|143|
|IMAPS|SSL|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|993|
|POP3|STARTTLS|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|110|
|POP3S|SSL|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|995|
|SMTP|STARTTLS|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|587|
|SMTPS|SSL|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|465|

Bitte verwenden Sie "plain" als Authentifizierungsmechanismus. Entgegen der Annahme werden keine Passwörter im Klartext übertragen, da ohne TLS keine Authentifizierung stattfinden darf.

## Kontakte und Kalender

SOGos Standard-URLs für Kalender (CalDAV) und Kontakte (CardDAV):

1. **CalDAV** - https://mail.example.com/SOGo/dav/user@example.com/Calendar/personal/
2. **CardDAV** - https://mail.example.com/SOGo/dav/user@example.com/Contacts/personal/

Einige Anwendungen verlangen möglicherweise die Verwendung von https://mail.example.com/SOGo/dav/ _oder_ den vollständigen Pfad zu Ihrem Kalender, der in SOGo gefunden und kopiert werden kann.