Random master usernames and passwords are automatically created on every restart of dovecot-mailcow.

**That's recommended and should not be changed.**

If you need the user to be static anyway, please specify two variables in `mailcow.conf`.

**Both** parameters must not be empty!

```
DOVECOT_MASTER_USER=mymasteruser
DOVECOT_MASTER_PASS=mysecretpass
```

Run `docker-compose up -d` to apply your changes.

The static master username will be expanded to `DOVECOT_MASTER_USER@mailcow.local`.

To login as `test@example.org` this would equal to `test@example.org*mymasteruser@mailcow.local` with the specified password above.

A login to SOGo is not possible with this username. A click-to-login function for SOGo is available for admins as described [here](https://mailcow.github.io/mailcow-dockerized-docs/debug-admin_login_sogo/)
No master user is required.
