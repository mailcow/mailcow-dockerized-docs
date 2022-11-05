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

1. **CalDAV**  <span class="client_variables_unavailable">https://mail.example.com/SOGo/dav/user@example.com/Calendar/personal/</span><span class="client_variables_available">https://<span class="client_var_host"></span>/SOGo/dav/<span class="client_var_email"></span>/Calendar/personal/</span>

2. **CardDAV**  <span class="client_variables_unavailable">https://mail.example.com/SOGo/dav/user@example.com/Contacts/personal/</span><span class="client_variables_available">https://<span class="client_var_host"></span>/SOGo/dav/<span class="client_var_email"></span>/Contacts/personal/</span>

Einige Anwendungen verlangen möglicherweise die Verwendung von <span class="client_variables_unavailable">https://mail.example.com/SOGo/dav/</span><span class="client_variables_available">https://<span class="client_var_host"></span>/SOGo/dav/</span> _oder_ den vollständigen Pfad zu Ihrem Kalender, der in SOGo gefunden und kopiert werden kann.