!!! warning "Important"
    First read [the overview](r_p.md).

!!! warning
    This is an unsupported community contribution. Feel free to provide fixes.

**Important**: This config only covers the "reverseproxing" of the webpannel (nginx-mailcow) using Traefik v2, if you also want to reverseproxy the mail services such as dovecot, postfix... you'll just need to adapt the following config to each container and create an [EntryPoint](https://docs.traefik.io/routing/entrypoints/) on your `traefik.toml` or `traefik.yml` (depending which config you use) for each port. 

For this section we'll assume you have your Traefik 2 `[certificatesresolvers]` properly configured on your traefik configuration file, and also using acme, also, the following example uses Lets Encrypt, but feel free to change it to your own cert resolver. You can find a basic Traefik 2 toml config file with all the above implemented which can be used for this example here [traefik.toml](https://github.com/Frenzoid/TraefikBasicConfig/blob/master/traefik.toml) if you need one, or a hint on how to adapt your config.


So, first of all, we are going to disable the acme-mailcow container since we'll use the certs that traefik will provide us.
For this we'll have to set `SKIP_LETS_ENCRYPT=y` on our `mailcow.conf`, and run the following command to apply the changes:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

Then we'll create a `docker-compose.override.yml` file in order to override the main `docker-compose.yml` found in your mailcow root folder. 

```yaml
services:
    nginx-mailcow:
      networks:
        # Add Traefik's network
        web:
      labels:
        - traefik.enable=true
        # Creates a router called "moo" for the container, and sets up a rule to link the container to certain rule,
        #   in this case, a Host rule with our MAILCOW_HOSTNAME var.
        - traefik.http.routers.moo.rule=Host(`${MAILCOW_HOSTNAME}`)
        # Enables tls over the router we created before.
        - traefik.http.routers.moo.tls=true
        # Specifies which kind of cert resolver we'll use, in this case le (Lets Encrypt).
        - traefik.http.routers.moo.tls.certresolver=le
        # Creates a service called "moo" for the container, and specifies which internal port of the container
        #   should traefik route the incoming data to.
        - traefik.http.services.moo.loadbalancer.server.port=${HTTP_PORT}
        # Specifies which entrypoint (external port) should traefik listen to, for this container.
        #   websecure being port 443, check the traefik.toml file liked above.
        - traefik.http.routers.moo.entrypoints=websecure
        # Make sure traefik uses the web network, not the mailcowdockerized_mailcow-network
        - traefik.docker.network=traefik_web

    certdumper:
        image: ghcr.io/kereis/traefik-certs-dumper
        command: --restart-containers ${COMPOSE_PROJECT_NAME}-postfix-mailcow-1,${COMPOSE_PROJECT_NAME}-nginx-mailcow-1,${COMPOSE_PROJECT_NAME}-dovecot-mailcow-1
        network_mode: none
        volumes:
          # Mount the volume which contains Traefik's `acme.json' file
          #   Configure the external name in the volume definition
          - acme:/traefik:ro
          # Mount mailcow's SSL folder
          - ./data/assets/ssl/:/output:rw
          # Mount docker socket to restart containers
          - /var/run/docker.sock:/var/run/docker.sock:ro
        restart: always
        environment:
          # only change this, if you're using another domain for mailcow's web frontend compared to the standard config
          - DOMAIN=${MAILCOW_HOSTNAME}

networks:
  web:
    external: true
    # Name of the external network
    name: traefik_web

volumes:
  acme:
    external: true
    # Name of the external docker volume which contains Traefik's `acme.json' file
    name: traefik_acme
```

Start the new containers with:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```


Now, there's only one thing left to do, which is setup the certs so that the mail services can use them as well, since Traefik 2 uses an acme v2 format to save ALL the license from all the domains we have, we'll need to find a way to dump the certs, lucky we have [this tiny container](https://hub.docker.com/r/humenius/traefik-certs-dumper) which grabs the `acme.json` file through a volume, and a variable `DOMAIN=example.org`, and with these, the container will output the `cert.pem` and `key.pem` files, for this we'll simply run the `traefik-certs-dumper` container binding the `/traefik` volume to the folder where our `acme.json` is saved, bind the `/output` volume to our mailcow `data/assets/ssl/` folder, and set up the `DOMAIN=example.org` variable to the domain we want the certs dumped from. 

This container will watch over the `acme.json` file for any changes, and regenerate the `cert.pem` and `key.pem` files directly into `data/assets/ssl/` being the path binded to the container's `/output` path.

You can use the command line to run it, or use the docker-compose.yml shown [here](https://hub.docker.com/r/humenius/traefik-certs-dumper).

After we have the certs dumped, we'll have to reload the configs from our postfix and dovecot containers, and check the certs, you can see how [here](https://docs.mailcow.email/firststeps-ssl/#how-to-use-your-own-certificate).

Aaand that should be it 😊, you can check if the Traefik router works fine through Traefik's dashboard / traefik logs / accessing the setted domain through https, or / and check HTTPS, SMTP and IMAP through the commands shown on the page linked before.
