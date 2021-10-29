Watchdog has default values for all thresholds which fit great for most of setups.

Thresholds variables don't added to `mailcow.conf` by default.
To adjust them just add needed threshold variable to `mailcow.conf` and run `docker-compose up -d`.

## Thresholds description

### MAILQ_CRIT and MAILQ_THRESHOLD

Notificaty administrators if number of emails in the postfix queue is greater then `MAILQ_CRIT` for periond of `MAILQ_THRESHOLD * (60±30)` seconds.
