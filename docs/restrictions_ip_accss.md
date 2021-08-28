_WIP_

# Protocol restrictions and IP access

Denied access will be shown to the user as failed login attempts.

## Protocol restrictions in Dovecot

Protocol restrictions work by filtering the passdb query for IMAP and POP3 as well as reading the JSON value for %s_access where %s reflects the protocol seen by Dovecot.

In the future we may use virtual colums in SQL to add an index on these values.

## Protocol restrictions in Postfix

Filtering SMTP protocol access works by using a check_sasl_map in the smtpd_recipient_restrictions.
