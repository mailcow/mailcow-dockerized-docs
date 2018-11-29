Create a folder for RainLoop and install it (here `rl/`):
```bash
cd data/web && mkdir rl && cd rl
curl -sL https://repository.rainloop.net/installer.php | php
```
Create `data/conf/nginx/site.rl.custom`

```ǹginx
location ^~ /rl/data {
    deny all;
}
```
After that restart the nginx docker container
```bash
docker-compose up -d && docker-compose restart nginx-mailcow
```

Navigate to https://${MAILCOW_HOSTNAME}/***rl/?admin*** login and change the **admin** password `12345`.

Optionally, you can add RainLoop's link to the mailcow Apps list.
To do this, open or create `data/web/inc/vars.local.inc.php` and add the following code-block or do it in the web panel:

*NOTE: Don't forget to add the `<?php` delimiter on the first line*

````php
...
$MAILCOW_APPS = array(
  array(
    'name' => 'SOGo',
    'link' => '/SOGo/'
  ),
  array(
    'name' => 'RainLoop',
    'link' => '/rl/'
   )
);
...
````
Don't forget to add your domains to the RainLoop Adminpanel to get access to your mailbox.
