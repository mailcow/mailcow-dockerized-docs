This disables ActiveSync in the autodiscover service for Outlook and configures it with IMAP and SMTP instead:

Open or create `data/web/inc/vars.local.inc.php` and paste the following code-block at the last line:
> Note: don't forget to add the `<?php` delimiter.
````
$config = array(
     'useEASforOutlook' => 'no',
     'autodiscoverType' => 'imap',
);
````

Tell Outlook clients to use SMTP and IMAP `'useEASforOutlook' => 'yes'` to `'useEASforOutlook' => 'no'`.

To always use IMAP and SMTP instead of EAS, set `'autodiscoverType' => 'imap'`.
