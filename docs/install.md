**WARNING**: Please use Ubuntu 16.04 instead of Debian 8 or [switch to the kernel 4.9 from jessie backports](https://packages.debian.org/jessie-backports/linux-image-amd64) because there is a bug (kernel panic) with the kernel 3.16 when running docker containers with healthchecks! Full details here: [github.com/docker/docker/issues/30402](https://github.com/docker/docker/issues/30402) and [forum.mailcow.email/t/solved-mailcow-docker-causes-kernel-panic-edit/448](https://forum.mailcow.email/t/solved-mailcow-docker-causes-kernel-panic-edit/448)

You need Docker and Docker Compose.

1\. Learn how to install [Docker](https://docs.docker.com/engine/installation/linux/) and [Docker Compose](https://docs.docker.com/compose/install/).

Quick installation for most operation systems:

- Docker
```
curl -sSL https://get.docker.com/ | sh
``` 

- Docker-Compose
```
curl -L https://github.com/docker/compose/releases/download/$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

Please use the latest Docker engine available and do not use the engine that ships with your distros repository.

2\. Clone the master branch of the repository
```
git clone https://github.com/andryyy/mailcow-dockerized && cd mailcow-dockerized
```

3\. Generate a configuration file. Use a FQDN (`host.domain.tld`) as hostname when asked.
```
./generate_config.sh
```

4\. Change configuration if you want or need to.
```
nano mailcow.conf
```
If you plan to use a reverse proxy, you can, for example, bind HTTPS to 127.0.0.1 on port 8443 and HTTP to 127.0.0.1 on port 8080.

You may need to stop an existing pre-installed MTA which blocks port 25/tcp. See [this chapter](https://andryyy.github.io/mailcow-dockerized/first_steps/#install-a-local-mta) to learn how to reconfigure Postfix to run besides mailcow after a successful installation.

5\. Pull the images and run the composer file. The paramter `-d` will start mailcow: dockerized detached:
```
docker-compose pull
docker-compose up -d
```

Done!

You can now access **https://${MAILCOW_HOSTNAME}** with the default credentials `admin` + password `moohoo`.

The database will be initialized right after a connection to MySQL can be established.
