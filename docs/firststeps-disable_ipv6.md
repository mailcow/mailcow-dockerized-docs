This is **ONLY** recommended if you do not have an IPv6 enabled network on your host!

If you need to, you can disable the usage of IPv6 in the compose file.
Additionally, you can  also disable the startup of container "ipv6nat-mailcow", as it's not needed if you won't use IPv6.

Instead of editing docker-compose.yml directly, it is preferrable to create an override file for it 
and implement your changes there.

Go to your mailcow directory and Create a new file called "docker-compose.override.yml": 
```
# cd /opt/mailcow-dockerized
# touch docker-compose.override.yml
```
**NOTE:** If you already have an override file, of course don't recreate it, but merge the lines below int your existing one accordingly!

Open the file in your favourite text editor and fill in the following:

```
version: '2.1'
services:

    ipv6nat-mailcow:
      restart: "no"
      entrypoint: ["echo", "pv6nat disabled in compose.override.yml"]
      
networks:
  mailcow-network:
    enable_ipv6: false
```

For these changes to be effective, you need to fully stop and then restart the stack, so containers and networks are recreated:
```
docker-compose down
docker-compose up -d
```

