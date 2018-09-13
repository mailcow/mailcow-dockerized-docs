Editing a domain administrator or a mailbox user allows to set restrictions to that account.

**Important**: For overlapping modules like sync jobs, which both domain administrators and mailbox users can be granted access to, the domain administrators permissions are inherited, when logging in as mailbox user.

Some examples:

1.

- A domain administror has **not** access to sync jobs but can login as mailbox user
- When logging in as mailbox user, he does not gain access to sync jobs, even if the given mailbox user _has_ access when logging in directly

2.

- A domain administror **has** access to sync jobs and can login as mailbox user
- The mailbox user he tries to login as has **not** access to sync jobs
- The domain administrator, now logged in as mailbox user, inherits its permission to the mailbox user and can access sync jobs

3.

- A domain administrator logs in as mailbox user
- Every permission, that does **not** exist in a domain administrators ACL, is automatically granted (example: time-limited alias, TLS policy etc.)
