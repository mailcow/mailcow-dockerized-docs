# Borgmatic Backup

## Introduction

Borgmatic is a great way to run backups on your mailcow setup as it securely encrypts your data and is extremely easy to
set up.

Due to it's deduplication capabilities you can store a great number of backups without wasting large amounts of disk
space. This allows you to run backups in very short intervals to ensure minimal data loss when the need arises to
recover data from a backup.

This document guides you through the process to enable continuous backups for mailcow with borgmatic. The borgmatic
functionality is provided by the [borgmatic Docker image](https://github.com/borgmatic-collective/docker-borgmatic). Check out
the `README` in that repository to find out about the other options (such as push notifications) that are available.
This guide only covers the basics.

---

## Setting up borgmatic

### Create or amend `docker-compose.override.yml`

In the mailcow-dockerized root folder create or edit `docker-compose.override.yml` and insert the following
configuration:

```yaml
services:
  borgmatic-mailcow:
    image: ghcr.io/borgmatic-collective/borgmatic
    hostname: mailcow
    restart: always
    dns: ${IPV4_NETWORK:-172.22.1}.254
    volumes:
      - vmail-vol-1:/mnt/source/vmail:ro
      - crypt-vol-1:/mnt/source/crypt:ro
      - redis-vol-1:/mnt/source/redis:ro
      - rspamd-vol-1:/mnt/source/rspamd:ro
      - postfix-vol-1:/mnt/source/postfix:ro
      - mysql-socket-vol-1:/var/run/mysqld/
      - borg-config-vol-1:/root/.config/borg
      - borg-cache-vol-1:/root/.cache/borg
      - ./data/conf/borgmatic/etc:/etc/borgmatic.d:Z
      - ./data/conf/borgmatic/ssh:/root/.ssh:Z
    environment:
      - TZ=${TZ}
      - BORG_PASSPHRASE=${BORG_PASSPHRASE}
      - DBNAME=${DBNAME}
      - DBUSER=${DBUSER}
      - DBPASS=${DBPASS}
    networks:
      mailcow-network:
        aliases:
          - borgmatic

volumes:
  borg-cache-vol-1:
  borg-config-vol-1:
```

Append `BORG_PASSPHRASE=YouBetterPutSomethingRealGoodHere` to your `mailcow.conf` and ensure that you change the `BORG_PASSPHRASE` to a secure passphrase of your choosing.

For security reasons we mount the maildir as read-only. If you later want to restore data you will need to remove
the `ro` flag prior to restoring the data. This is described in the section on restoring backups.

### Create `data/conf/borgmatic/etc/config.yaml`

Next, we need to create the borgmatic configuration. Borgmatic supports environment variable interpolation, this way we can get the correct MySQL credentials from Docker or more specifically from our `mailcow.conf` without exposing them in our config.

Make sure to copy all the following lines!

```bash
cat <<EOF > data/conf/borgmatic/etc/config.yaml
source_directories:
    - /mnt/source/vmail
    - /mnt/source/crypt
    - /mnt/source/redis
    - /mnt/source/rspamd
    - /mnt/source/postfix
repositories:
    - path: ssh://uXXXXX@uXXXXX.your-storagebox.de:23/./mailcow
      label: rsync
exclude_patterns:
    - '/mnt/source/postfix/public/'
    - '/mnt/source/postfix/private/'
    - '/mnt/source/rspamd/rspamd.sock'

keep_hourly: 24
keep_daily: 7
keep_weekly: 4
keep_monthly: 6

mariadb_databases:
    - name: ${DBNAME}
      username: ${DBUSER}
      password: ${DBPASS}
      options: "--default-character-set=utf8mb4 --skip-ssl"
      list_options: "--skip-ssl"
      restore_options: "--skip-ssl"
EOF
```

!!! warning
    Starting with borgmatic 1.8.0 (released July 19th, 2023), the configuration file syntax was
    [changed](https://github.com/borgmatic-collective/borgmatic/releases/tag/1.8.0). You can check the Docker logs
    of the borgmatic container for deprecation warnings to see if you are affected, i.e. if your config file was
    generated for an older borgmatic version. In this case, you should create a new `config.yaml` file as described
    above to avoid problems with future borgmatic releases.

!!! warning
    Starting with borgmatic 1.9.4 (released December 11th, 2024), the included MariaDB tools try to force encrypted connections
    by default. Edit your `config.yaml` and add `--skip-ssl` to `options`, `restore_options`, and `list_options` as shown above. Also make
    sure to change `mysql_databases` to `mariadb_databases` to avoid problems with future borgmatic and MariaDB releases.

This file is a minimal example for using borgmatic with an account `uXXXXX` on a Storage Box from the cloud storage provider `Hetzner`. The repository is called `mailcow` (see `repositories` setting). This must be changed accordingly.

It will backup both the maildir and MySQL database, which is
all you should need to restore your mailcow setup after an incident.

The retention settings will keep one archive for
each hour of the past 24 hours, one per day of the week, one per week of the month and one per month of the past half
year.

Check the [borgmatic documentation](https://torsion.org/borgmatic/) on how to use other types of repositories or
configuration options. If you choose to use a local filesystem as a backup destination make sure to mount it into the
container. The container defines a volume called `/mnt/borg-repository` for this purpose.

### Create a crontab

Create a new text file in `data/conf/borgmatic/etc/crontab.txt` with the following content:

```
14 * * * * PATH=$PATH:/usr/local/bin /usr/local/bin/borgmatic --stats -v 0 2>&1
```

This file expects crontab syntax. The example shown here will trigger the backup to run every hour at 14 minutes past
the hour and log some nice stats at the end.

### Place SSH keys in folder

Place the SSH keys you intend to use for remote repository connections in `data/conf/borgmatic/ssh`. OpenSSH expects the
usual `id_rsa`, `id_ed25519` or similar to be in this directory. Ensure the file is `chmod 600` and not world readable
or OpenSSH will refuse to use the SSH key.

### Bring up the container

For the next step we need the container to be up and running in a configured state. To do that run:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

### Initialize the repository

By now your borgmatic container is up and running, but the backups will currently fail due to the repository not being
initialized.

To initialize the repository run:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic init --encryption repokey-blake2
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic init --encryption repokey-blake2
    ```

You will be asked you to authenticate the SSH host key of your remote repository server. See if it matches and confirm
the prompt by entering `yes`. The repository will be initialized with the passphrase you set in the `BORG_PASSPHRASE`
environment variable earlier.

When using any of the `repokey` encryption methods the encryption key will be stored in the repository itself and not on
the client, so there is no further action required in this regard. If you decide to use a `keyfile` instead of
a `repokey` make sure you export the key and back it up separately. Check the [Exporting Keys](#exporting-keys) section
for how to retrieve the key.

### Restart container

Now that we finished configuring and initializing the repository restart the container to ensure it is in a defined
state:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart borgmatic-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart borgmatic-mailcow
    ```

---

## Restoring from a backup

Restoring a backup assumes you are starting off with a fresh installation of mailcow, and you currently do not have
any custom data in your maildir or your mailcow database.

### Restore maildir (completely)

!!! warning
    Doing this will overwrite files in your maildir! Do not run this unless you actually intend to recover mail
    files from a backup.

!!! note "If you use SELinux in Enforcing mode"
    If you are using mailcow on a host with SELinux in Enforcing mode you will have to temporarily disable it during
    extraction of the archive as the mailcow setup labels the vmail volume as private, belonging to the dovecot container
    exclusively. SELinux will (rightfully) prevent any other container, such as the borgmatic container, from writing to
    this volume.

Before running a restore you must make the vmail volume writeable in `docker-compose.override.yml` by removing
the `ro` flag from the volume.
Then you can use the following command to restore the maildir from a backup:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic extract --path mnt/source --archive latest
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic extract --path mnt/source --archive latest
    ```

Alternatively you can specify any archive name from the list of archives (see
[Listing all available archives](#listing-all-available-archives))

### Restore maildir (per mailbox)

It is also possible to restore only a single mailbox from a backup. Suppose you want to restore the mailbox for `user@example.com`.

Again, before restoring you must remove the `ro` flag from the volume in `docker-compose.override.yml` before proceeding.

If you used the configuration above, borgmatic stores the backups under mnt/source/vmail/example.com/user/ (in this example for our user `user@example.com`).

To restore this mailbox, use the following command:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic extract --path mnt/source/vmail/example.com/user --archive latest
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic extract --path mnt/source/vmail/example.com/user --archive latest
    ```

!!! info "Note"
    Instead of `latest` you can also specify any archive name from the list of archives (see [Listing all available archives](#listing-all-available-archives))

Depending on how long ago the original data was deleted, you may need to trigger a reindex of the mailbox via Dovecot so the restored emails appear in your mail client:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec dovecot-mailcow doveadm index -u user@example.com '*'
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec dovecot-mailcow doveadm index -u user@example.com '*'
    ```

### Restore MySQL

!!! warning
    Running this command will delete and recreate the mailcow database! Do not run this unless you actually
    intend to recover the mailcow database from a backup.

To restore the MySQL database from the latest archive use this command:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic restore --archive latest
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic restore --archive latest
    ```

Alternatively you can specify any archive name from the list of archives (see
[Listing all available archives](#listing-all-available-archives))

### After restoring

After restoring you need to restart mailcow. If you disabled SELinux enforcing mode now would be a good time to
re-enable it.

To restart mailcow use the follwing command:

=== "docker compose (Plugin)"

    ``` bash
    docker compose down && docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose down && docker-compose up -d
    ```

If you use SELinux this will also trigger the re-labeling of all files in your vmail volume. Be patient, as this may
take a while if you have lots of files.

---

## Useful commands

### Manual archiving run (with debugging output)

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic -v 2
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic -v 2
    ```

### Listing all available archives

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic list
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic list
    ```

### Break lock

When borg is interrupted during an archiving run it will leave behind a stale lock that needs to be cleared before any
new operations can be performed:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic break-lock
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic break-lock
    ```


Now would be a good time to do a manual archiving run to ensure it can be successfully performed.

### Exporting keys

When using any of the `keyfile` methods for encryption you **MUST** take care of backing up the key files yourself. The
key files are generated when you initialize the repository. The `repokey` methods store the key file within the
repository, so a manual backup isn't as essential.

Note that in either case you also must have the passphrase to decrypt any archives.

To fetch the keyfile run:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec -e BORG_RSH="ssh -p 23" borgmatic-mailcow borg key export --paper uXXXXX@uXXXXX.your-storagebox.de:mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec -e BORG_RSH="ssh -p 23" borgmatic-mailcow borg key export --paper uXXXXX@uXXXXX.your-storagebox.de:mailcow
    ```

Where `uXXXXX@uXXXXX.your-storagebox.de:mailcow` is the URI to your repository.
