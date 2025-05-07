Sync jobs are used to copy or move existing emails either from an external IMAP server or between existing mailboxes within mailcow.

!!! warning "Notice"
    Depending on your mailbox’s access control list (ACL), you may not have permission to create a sync job. In this case, please contact your domain administrator.

## Creating a Sync Job

1. Navigate to “E-Mail :material-arrow-right: Configuration :material-arrow-right: Synchronizations” (if logged in as an admin or domain admin) or “User Settings :material-arrow-right: Sync Jobs” (as a regular mailbox user) to create a new sync job.

2. If you are an administrator, select the mailbox username from the “Username” dropdown menu where the emails should be copied to (target mailbox).

3. Fill in the “Host” and “Port” fields with the correct connection details of the source IMAP server (the server from which the emails will be fetched).

4. Enter the correct login credentials for the source IMAP server in the “Username” and “Password” fields.

5. Select the appropriate encryption method. If the source IMAP server uses port 143, TLS is likely the correct choice, while SSL is typically used with port 993. PLAIN authentication is also possible, but strongly discouraged.

6. All other fields can be left at their default values or adjusted as needed.

7. Make sure to check the “Active” box and click “Add” to finalize the sync job.

!!! notice "Please remember..."
    Once you’re done, log in to the target mailbox and verify that all emails were imported correctly. If everything worked as expected, all your emails will appear in the new inbox. Don’t forget to disable or delete the sync job once it’s no longer needed.