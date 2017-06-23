This disables ActiveSync in the autodiscover service for Outlook and configures it with IMAP and SMTP instead:

Open or create `data/web/inc/vars.local.inc.php` and paste the following code-block at the last line:
> Note: make sure that the file starts with `<?php`.
````
$config['useEASforOutlook'] = 'no';
````

Tell Outlook clients to use SMTP and IMAP `'useEASforOutlook' => 'yes'` to `'useEASforOutlook' => 'no'`.