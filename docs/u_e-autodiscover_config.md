Open/create `data/web/vars.local.inc.php` and add this configuration array (as a copy of `$autodiscover_config` from `data/web/vars.inc.php`):

```
$autodiscover_config = array(
  // Enable the autodiscover service for Outlook desktop clients
  'useEASforOutlook' => 'yes',
  // General autodiscover service type: "activesync" or "imap"
  'autodiscoverType' => 'activesync',
  'imap' => array(
    'server' => $mailcow_hostname,
    'port' => getenv('IMAPS_PORT'),
    'ssl' => 'on',
  ),
  'smtp' => array(
    'server' => $mailcow_hostname,
    'port' => getenv('SMTPS_PORT'),
    'ssl' => 'on'
  ),
  'activesync' => array(
    'url' => 'https://'.$mailcow_hostname.'/Microsoft-Server-ActiveSync'
  )
);
```

To always use IMAP and SMTP instead of EAS, set `'autodiscoverType' => 'imap'`.

Disable ActiveSync for Outlook desktop clients by setting "useEASforOutlook" to "no".