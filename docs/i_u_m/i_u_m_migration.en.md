!!! warning
    This guide assumes you intend to migrate an existing mailcow server (source) over to a brand new, empty server (target). It takes no care about preserving any existing data on your target server and will erase anything within `/var/lib/docker/volumes` and thus any Docker volumes you may have already set up.

!!! tip
    Alternatively, you can use the `./helper-scripts/backup_and_restore.sh` script to create a full backup on the source machine, then install mailcow on the target machine as usual, copy over your `mailcow.conf` and use the same script to restore your backup to the target machine.

**1\.**
Follow the [installation guide](i_u_m_install.en.md) to install Docker and Compose.

**2\.** Stop Docker and assure Docker has stopped:
```
systemctl stop docker.service
systemctl status docker.service
```

**3\.**	Run the following commands on the source machine (take care of adding the trailing slashes in the first path parameter as shown below!) - **WARNING: This command will erase anything that may already exist under `/var/lib/docker/volumes` on the target machine**:
```
rsync -aHhP --numeric-ids --delete /opt/mailcow-dockerized/ root@target-machine.example.com:/opt/mailcow-dockerized
rsync -aHhP --numeric-ids --delete /var/lib/docker/volumes/ root@target-machine.example.com:/var/lib/docker/volumes
```

**4\.** Shut down mailcow and stop Docker on the source machine.
=== "docker compose (Plugin)"

    ``` bash
    cd /opt/mailcow-dockerized
    docker compose down
    systemctl stop docker.service
    ```

=== "docker-compose (Standalone)"

    ``` bash
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
=== "docker compose (Plugin)"

    ``` bash
    cd /opt/mailcow-dockerized
    docker compose pull
    ```

=== "docker-compose (Standalone)"

    ``` bash
    cd /opt/mailcow-dockerized
    docker-compose pull
    ```

**8\.** Start the whole mailcow stack and everything should be done!
=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker compose up -d
    ```

**9\.** Finally, change your DNS settings to point to the target server.
