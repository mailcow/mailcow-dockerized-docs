If you want to migrate your old mailcow:dockerized installation to a new server you can follow this:

**1\.** 
Install [Docker](https://docs.docker.com/engine/installation/linux/) and [Docker Compose](https://docs.docker.com/compose/install/) on your new server.

Quick installation for most operation systems:

- Docker
```
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
# After the installation process is finished, you may need to enable the service and make sure it is started (e.g. CentOS 7)
systemctl enable docker.service
```

- docker-compose
```
curl -L https://github.com/docker/compose/releases/download/$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

Please use the latest Docker engine available and do not use the engine that ships with your distros repository.

**2\.** Make sure that Docker is stopped:
```
systemctl status docker.service
```
    
**3\.**	Run the following commands on the source machine (take care of adding the trailing slashes in the first path parameter as shown below!):
```
rsync -aHhP --numeric-ids --delete /opt/mailcow-dockerized/ root@some.other.machine.net:/opt/mailcow-dockerized
rsync -aHhP --numeric-ids --delete /var/lib/docker/volumes/ root@some.other.machine.net:/var/lib/docker/volumes
```

**4\.**    Shut down Mailcow via `docker-compose down` and stop Docker on the source machine.

**5\.**    Repeat step 3 with the same commands (this will be much quicker than the first time).

**6\.**    Start docker on the target machine `systemctl start docker.service`.

**7\.**    Go into the /opt/mailcow-dockerized directory and run `docker-compose pull`.

**8\.**    Start the whole mailcow stack with `docker-compose up -d` and everything should be fine.

**9\.**    Change your DNS settings.
