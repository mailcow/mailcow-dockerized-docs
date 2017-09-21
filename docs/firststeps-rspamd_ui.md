At first you may want to setup Rspamds web interface which provides some useful features and information.

1\. Generate a Rspamd controller password hash:
```
docker-compose exec rspamd-mailcow rspamadm pw
```

2\. Add a line with your newly-generated hash to `data/conf/rspamd/override.d/worker-controller.inc`:
```
enable_password = "myhash";
```

You can use `password = "myhash";` instead of `enable_password` to disable write-access in the web UI.

3\. Restart rspamd:
```
docker-compose restart rspamd-mailcow
```

Open https://${MAILCOW_HOSTNAME}/rspamd in a browser and login!
