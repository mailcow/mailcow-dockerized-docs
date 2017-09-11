Open/create `data/web/inc/vars.local.inc.php` and add your changes to the configuration array.

Changes will be merged with "$autodiscover_config" in `data/web/inc/vars.inc.php`):

```
$autodiscover_config = array(
  // Enable the autodiscover service for Outlook desktop clients
  'useEASforOutlook' => 'yes',
  // General autodiscover service type: "activesync" or "imap"
  'autodiscoverType' => 'activesync',
  // Please don't use STARTTLS-enabled service ports here.
  // The autodiscover service will always point to SMTPS and IMAPS (TLS-wrapped services).
  'imap' => array(
    'server' => $mailcow_hostname,
    'port' => getenv('IMAPS_PORT'),
  ),
  'smtp' => array(
    'server' => $mailcow_hostname,
    'port' => getenv('SMTPS_PORT'),
  ),
  'activesync' => array(
    'url' => 'https://'.$mailcow_hostname.'/Microsoft-Server-ActiveSync'
  ),
  'caldav' => array(
    'url' => 'https://'.$mailcow_hostname
  )
  'carddav' => array(
    'url' => 'https://'.$mailcow_hostname
  )
);
```

To always use IMAP and SMTP instead of EAS, set `'autodiscoverType' => 'imap'`.

Disable ActiveSync for Outlook desktop clients by setting "useEASforOutlook" to "no".
