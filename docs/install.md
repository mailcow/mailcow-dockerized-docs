You need Docker and Docker Compose.

**1\.** Learn how to install [Docker](https://docs.docker.com/engine/installation/linux/) and [Docker Compose](https://docs.docker.com/compose/install/).

Quick installation for most operation systems:

- Docker
```
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
# After the installation process is finished, you may need to enable the service and make sure it is started (e.g. CentOS 7)
systemctl enable docker.service
systemctl start docker.service
```

- Docker-Compose
```
curl -#L https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d '"' -f 4)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

Please use the latest Docker engine available and do not use the engine that ships with your distros repository.

**2\.** Clone the master branch of the repository, make sure your umask equals 0022.
```
# umask
0022
# cd /opt
# git clone https://github.com/mailcow/mailcow-dockerized
# cd mailcow-dockerized
```

**3\.** Generate a configuration file. Use a FQDN (`host.domain.tld`) as hostname when asked.
```
./generate_config.sh
```

**4\.** Change configuration if you want or need to.
```
nano mailcow.conf
```
If you plan to use a reverse proxy, you can, for example, bind HTTPS to 127.0.0.1 on port 8443 and HTTP to 127.0.0.1 on port 8080.

You may need to stop an existing pre-installed MTA which blocks port 25/tcp. See [this chapter](https://mailcow.github.io/mailcow-dockerized-docs/firststeps-local_mta/) to learn how to reconfigure Postfix to run besides mailcow after a successful installation.

**4\.1\.** OpenStack users and users with a MTU not equal to 1500:

Edit `docker-compose.yml` and change the network settings according to your MTU.
Add the new driver_opts parameter like this:
```
networks:
  mailcow-network:
    ...
    driver_opts:
      com.docker.network.driver.mtu: 1450
    ...
```

**5\.** Pull the images and run the composer file. The parameter `-d` will start mailcow: dockerized detached:
```
docker-compose pull
docker-compose up -d
```

Done!

You can now access **https://${MAILCOW_HOSTNAME}** with the default credentials `admin` + password `moohoo`.

The database will be initialized right after a connection to MySQL can be established.
