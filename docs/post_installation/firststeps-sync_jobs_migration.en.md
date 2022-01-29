Sync jobs are used to copy or move existing emails from an external IMAP server or within mailcow's existing mailboxes.

!!! info
    Depending on your mailbox's ACL you may not have the option to add a sync job. Please contact your domain administrator if so.

## Setup a Sync Job
1. In the "Mail Setup" or "User Settings" interface, create a new sync job.

2. If you are an administrator, select the username of the downstream mailcow mailbox in the "Username" dropdown.

3. Fill in the "Host" and "Port" fields with their respective correct values from the upstream IMAP server.

4. In the "Username" and "Password" fields, supply the correct access credentials from the upstream IMAP server.

5. Select the "Encryption Method". If the upstream IMAP server uses port 143, it is likely that the encryption method is TLS and SSL for port 993. Nevertheless, you can use PLAIN authentication, but it is stongly discouraged.

6. For all ther other fields, you can leave them as is or modify them as desired.

7. Make sure to tick "Active" and click "Add".

!!! info
    Once Completed, log into the mailbox and check if all emails are imported correctly. If all goes well, all your mails shall end up in your new mailbox. And don't forget to delete or deactivate the sync job after it is used.