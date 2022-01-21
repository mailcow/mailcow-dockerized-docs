The Dovecot parameter `sieve_vacation_dont_check_recipient` - which was by default set to `yes` in mailcow configurations pre 21st July - allows for vacation replies even when a mail is sent to non-existent mailboxes like a catch-all addresses.

We decided to switch this parameter back to `no` and allow a user to specify which recipient address triggers a vacation reply. The triggering recipients can also be configured in SOGos autoresponder feature.

