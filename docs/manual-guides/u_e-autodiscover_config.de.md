**Sie brauchen diese Datei nicht zu ändern oder zu erstellen, autodiscover funktioniert sofort**. Diese Anleitung ist nur für Anpassungen des Autodiscover- oder Autokonfigurationsprozesses gedacht.

Neuere Outlook-Clients (insbesondere solche, die mit O365 ausgeliefert werden) führen keine automatische Erkennung von E-Mail-Profilen durch.
Denken Sie daran, dass **ActiveSync NICHT mit einem Desktop-Client** verwendet werden sollte.

Öffnen/erstellen Sie `data/web/inc/vars.local.inc.php` und fügen Sie Ihre Änderungen in das Konfigurationsfeld ein.

Die Änderungen werden mit "$autodiscover_config" in `data/web/inc/vars.inc.php` zusammengeführt):

```
<?php
$autodiscover_config = array(
  // General autodiscover service type: "activesync" or "imap"
  // emClient uses autodiscover, but does not support ActiveSync. mailcow excludes emClient from ActiveSync.
  'autodiscoverType' => 'activesync',
  // If autodiscoverType => activesync, also use ActiveSync (EAS) for Outlook desktop clients (>= Outlook 2013 on Windows)
  // Outlook for Mac does not support ActiveSync
  'useEASforOutlook' => 'yes',
  // Please don't use STARTTLS-enabled service ports in the "port" variable.
  // The autodiscover service will always point to SMTPS and IMAPS (TLS-wrapped services).
  // The autoconfig service will additionally announce the STARTTLS-enabled ports, specified in the "tlsport" variable.
  'imap' => array(
    'server' => $mailcow_hostname,
    'port' => array_pop(explode(':', getenv('IMAPS_PORT'))),
    'tlsport' => array_pop(explode(':', getenv('IMAP_PORT'))),
  ),
  'pop3' => array(
    'server' => $mailcow_hostname,
    'port' => array_pop(explode(':', getenv('POPS_PORT'))),
    'tlsport' => array_pop(explode(':', getenv('POP_PORT'))),
  ),
  'smtp' => array(
    'server' => $mailcow_hostname,
    'port' => array_pop(explode(':', getenv('SMTPS_PORT'))),
    'tlsport' => array_pop(explode(':', getenv('SUBMISSION_PORT'))),
  ),
  'activesync' => array(
    'url' => 'https://'.$mailcow_hostname.($https_port == 443 ? '' : ':'.$https_port).'/Microsoft-Server-ActiveSync',
  ),
  'caldav' => array(
    'server' => $mailcow_hostname,
    'port' => $https_port,
  ),
  'carddav' => array(
    'server' => $mailcow_hostname,
    'port' => $https_port,
  ),
);
```

Um immer IMAP und SMTP anstelle von EAS zu verwenden, setzen Sie `'autodiscoverType' => 'imap'`.

Deaktivieren Sie ActiveSync für Outlook-Desktop-Clients, indem Sie "useEASforOutlook" auf "no" setzen.