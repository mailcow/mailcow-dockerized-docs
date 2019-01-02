To migrate across a mailbox or domain from one mailcow installation to another (or to import a mailbox from any IMAP server) follow the following instructions:

> IMPORTANT: Read all of the steps at least once before trying to execute the process as even the slightest mess can cause irreversable damage. You may not be able to recover the emails from source or destination if anything is not set properly. 


Step #1: On the Destination mailcow, Add the domain and create the mailbox(es) with sufficient Quota. 

Step #2: Visit the Sync Jobs tab, Select the Relevant email account,

  a. Select Create a new Sync Job.

  b. Select the Correct username (This is the Recepient Inbox Account). 

  c. Fill in Host (The Donor Mailcow Server address) & Port (Use 143 or 993).

  d. Fill in the Username & Password (This is the login for the mailbox you're trying to import).

  e.  Select Encryption method (Plain in case of Port 143 or SSL in case of Port 993).

  f. Polling Interval may be set to a Lower Number e.g. 1 for syncing faster. (Set this depending upon mailbox size and server load.) 

  g. Sync into Folder: Keep it blank for a 1:1 folder mapping or all your emails will be stored in a separate folder e.g. external of your mailbox. 

Step #3: Tweak other options if required, All of the options are self-explanatory. 

Step #4: Monitor! Check the logs of the sync job after ~5 minutes of first run to make sure it executed correctly. If there were any errors, resolve them and wait for the Job to be executed again. 

Step #5: Once Completed, Log into the mailbox and check if all emails are imported correctly. If all goes well, All your mails shall end up in your new mailbox.

Step #6: If migrating a domain across mailcow installations, Now is the time that You update the DNS records in order to reflect the changes. Easiest way to find correct DNS records is to visit the domains tab on mailcow admin page and click on the DNS button corresponding to your domain. Make relevant adjustments to your DNS records and all new emails shall arrive to your new new inbox now. 

Step #7: Inactive the Sync Job once the transition is complete. 
