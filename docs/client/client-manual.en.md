These instructions are valid for unchanged port bindings only!

## Email

|Service|Encryption|Host|Port|
|--- |--- |--- |--- |
|IMAP|STARTTLS|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|143|
|IMAPS|SSL|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|993|
|POP3|STARTTLS|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|110|
|POP3S|SSL|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|995|
|SMTP|STARTTLS|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|587|
|SMTPS|SSL|<span class="client_variables_available"> <code><span class="client_var_host"></span><span class="client_var_port"></span></code></span><span class="client_variables_unavailable">mailcow hostname</span>|465|

Please use the "plain" password setting as the authentication mechanism. Contrary to what the name implies, the password will not be transferred to the server in plain text as no authentication is allowed to take place without TLS.

## Contacts and calendars

SOGos default calendar (CalDAV) and contacts (CardDAV) URLs:

1. **CalDAV**  <span class="client_variables_unavailable">https://mail.example.com/SOGo/dav/user@example.com/Calendar/personal/</span><span class="client_variables_available">https://<span class="client_var_host"></span>/SOGo/dav/<span class="client_var_email"></span>/Calendar/personal/</span>

2. **CardDAV**  <span class="client_variables_unavailable">https://mail.example.com/SOGo/dav/user@example.com/Contacts/personal/</span><span class="client_variables_available">https://<span class="client_var_host"></span>/SOGo/dav/<span class="client_var_email"></span>/Contacts/personal/</span>

Some applications may require you to use <span class="client_variables_unavailable">https://mail.example.com/SOGo/dav/</span><span class="client_variables_available">https://<span class="client_var_host"></span>/SOGo/dav/</span> _or_ the full path to your calendar, which can be found and copied from within SOGo.