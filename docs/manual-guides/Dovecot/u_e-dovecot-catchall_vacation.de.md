Der Dovecot-Parameter `sieve_vacation_dont_check_recipient` - der in mailcow-Konfigurationen vor dem 21. Juli 2021 standardmäßig auf `yes` gesetzt war - erlaubt Urlaubsantworten auch dann, wenn eine Mail an nicht existierende Mailboxen wie Catch-All-Adressen gesendet wird.

Wir haben uns entschlossen, diesen Parameter wieder auf `nein` zu setzen und dem Benutzer zu erlauben, die Empfängeradresse zu spezifizieren, die eine Urlaubsantwort auslöst. Die auslösenden Empfänger können auch in SOGos Autoresponder-Funktion konfiguriert werden.
