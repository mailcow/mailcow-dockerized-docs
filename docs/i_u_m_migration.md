#### Please note: This guide assumes you intend to migrate an existing mailcow server (source) over to a brand new, empty server (target). It takes no care about preserving any existing data on your target server and will erase anything within `/var/lib/docker/volumes` and thus any Docker volumes you may have already set up.

##### Alternatively, you can use the `./helper-scripts/backup_and_restore.sh` script to create a full backup on the source machine, then install mailcow on the target machine as usual, copy over your `mailcow.conf` and use the same script to restore your backup to the target machine.

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
    
**3\.**	Run the following commands on the source machine (take care of adding the trailing slashes in the first path parameter as shown below!) - **WARNING: This command will erase anything that may already exist under `/var/lib/docker/volumes` on the target machine**:
```
rsync -aHhP --numeric-ids --delete /opt/mailcow-dockerized/ root@target-machine.example.com:/opt/mailcow-dockerized
rsync -aHhP --numeric-ids --delete /var/lib/docker/volumes/ root@target-machine.example.com:/var/lib/docker/volumes
```

**4\.** Shut down mailcow and stop Docker on the source machine.
```
cd /opt/mailcow-dockerized
docker-compose down
systemctl stop docker.service
```

**5\.** Repeat step 3 with the same commands. This will be much quicker than the first time.

**6\.** Switch over to the target machine and start Docker.
```
systemctl start docker.service
```

**7\.** Now pull the mailcow Docker images on the target machine.
```
cd /opt/mailcow-dockerized
docker-compose pull
```

**8\.** Start the whole mailcow stack and everything should be done!
```
docker-compose up -d
```

**9\.** Finally, change your DNS settings to point to the target server.
