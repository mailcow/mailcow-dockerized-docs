This disables ActiveSync in the autodiscover service for Outlook and configures it with IMAP and SMTP instead:

Open `data/web/autodiscover.php` and set `'useEASforOutlook' => 'yes'` to `'useEASforOutlook' => 'no'`.

To always use IMAP and SMTP instead of EAS, set `'autodiscoverType' => 'imap'`.
