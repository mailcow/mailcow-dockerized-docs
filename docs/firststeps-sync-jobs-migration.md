To migrate across a mailbox or domain from one mailcow installation to another (or to import a mailbox from any IMAP server) follow these instructions:

> IMPORTANT: Read all of the steps at least once before trying to execute the process as even the slightest mess can cause irreversable damage. You may not be able to recover the emails from source or destination if anything is not set properly. 


Step #1: On the target mailcow server, open "Configuration -> Mail Setup" and add the domain and create the mailbox(es) with sufficient quota. 

Step #2: Select the "Sync jobs" tab and proceed with the following steps:

  a. Select "Create a new sync job".

  b. Select the correct username as destination

  c. Fill in host (the donor mail server address) and port

  d. Fill in the username and password (this is the login for the mailbox you're trying to import)

  e. Select an encryption method of the remote server (plain or TLS in case of port 143 or SSL for port 993)

  f. Polling interval may be set to a lower number, i.e. 5, to sync more frequently. Set this depending upon mailbox size and server load.

  g. "Sync into subfolder on destination": Keep it blank for a 1:1 folder mapping or all your emails will be stored in a separate folder (default: "External") of your mailbox. 

Step #3: Tweak other options if required, all of the options are self-explanatory. 

Step #4: Monitor! Check the logs of the sync job after a few minutes of their first run to make sure it executed correctly. If there were any errors, resolve them and wait for the job to be executed again. 

Step #5: Once completed, log into the mailbox and check if all emails are imported correctly. If all goes well, all your mails shall end up in your new mailbox.

Step #6: If migrating a domain across mailcow installations, now is the time that you update the DNS records in order to reflect the changes. Easiest way to find correct DNS records is to visit the domains tab on mailcow admin page and click on the DNS button corresponding to your domain. Make relevant adjustments to your DNS records and all new emails shall arrive to your new new inbox now. 

Step #7: Set the sync jobs to inactive once the transfers are completed.
