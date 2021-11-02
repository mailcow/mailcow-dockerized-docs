# Borgmatic Backup

## Introduction

Borgmatic is a great way to run backups on your Mailcow setup as it securely encrypts your data and is extremely easy to
set up.

Due to it's deduplication capabilities you can store a great number of backups without wasting large amounts of disk
space. This allows you to run backups in very short intervals to ensure minimal data loss when the need arises to
recover data from a backup.

This document guides you through the process to enable continuous backups for mailcow with borgmatic. The borgmatic
functionality is provided by the [borgmatic Docker image by b3vis](https://github.com/b3vis/docker-borgmatic). Check out
the `README` in that repository to find out about the other options (such as push notifications) that are available.
This guide only covers the basics.

## Setting up borgmatic

### Create or amend `docker-compose.override.yml`

In the mailcow-dockerized root folder create or edit `docker-compose.override.yml` and insert the following
configuration:

```yaml
version: '2.1'
services:
  borgmatic-mailcow:
    image: b3vis/borgmatic
    restart: always
    dns: ${IPV4_NETWORK:-172.22.1}.254
    volumes:
      - vmail-vol-1:/mnt/source/vmail:ro
      - crypt-vol-1:/mnt/source/crypt:ro
      - mysql-socket-vol-1:/var/run/mysqld/:z
      - ./data/conf/borgmatic/etc:/etc/borgmatic.d:Z
      - ./data/conf/borgmatic/state:/root/.config/borg:Z
      - ./data/conf/borgmatic/ssh:/root/.ssh:Z
    environment:
      - TZ=${TZ}
      - BORG_PASSPHRASE=YouBetterPutSomethingRealGoodHere
    networks:
      mailcow-network:
        aliases:
          - borgmatic
```

Ensure that you change the `BORG_PASSPHRASE` to a secure passphrase of your choosing.

For security reasons we mount the maildir as read-only. If you later want to restore data you will need to remove
the `ro` flag prior to restoring the data. This is described in the section on restoring backups.

### Create `data/conf/borgmatic/etc/config.yaml`

Next, we need to create the borgmatic configuration.

```shell
source mailcow.conf
cat <<EOF > data/conf/borgmatic/etc/config.yaml
location:
    source_directories:
        - /mnt/source
    repositories:
        - user@rsync.net:mailcow
    remote_path: borg1

retention:
    keep_hourly: 24
    keep_daily: 7
    keep_weekly: 4
    keep_monthly: 6

hooks:
    mysql_databases:
        - name: ${DBNAME}
          username: ${DBUSER}
          password: ${DBPASS}
          options: --default-character-set=utf8mb4
EOF
```

Creating the file in this way ensures the correct MySQL credentials are pulled in from `mailcow.conf`.

This file is a minimal example for using borgmatic with an account `user` on the cloud storage provider `rsync.net` for
a repository called `mailcow` (see `repositories` setting). It will backup both the maildir and MySQL database, which is
all you should need to restore your mailcow setup after an incident. The retention settings will keep one archive for
each hour of the past 24 hours, one per day of the week, one per week of the month and one per month of the past half
year.

Check the [borgmatic documentation](https://torsion.org/borgmatic/) on how to use other types of repositories or
configuration options. If you choose to use a local filesystem as a backup destination make sure to mount it into the
container. The container defines a volume called `/mnt/borg-repository` for this purpose.

!!! note
    If you do not use rsync.net you can most likely drop the `remote_path` element from your config.

### Create a crontab

Create a new text file in `data/conf/borgmatic/etc/crontab.txt` with the following content:

```
14 * * * * PATH=$PATH:/usr/bin /usr/bin/borgmatic --stats -v 0 2>&1
```

This file expects crontab syntax. The example shown here will trigger the backup to run every hour at 14 minutes past
the hour and log some nice stats at the end.

### Place SSH keys in folder

Place the SSH keys you intend to use for remote repository connections in `data/conf/borgmatic/ssh`. OpenSSH expects the
usual `id_rsa`, `id_ed25519` or similar to be in this directory. Ensure the file is `chmod 600` and not world readable
or OpenSSH will refuse to use the SSH key.

### Bring up the container

For the next step we need the container to be up and running in a configured state. To do that run:

```shell
docker-compose up -d
```

### Initialize the repository

By now your borgmatic container is up and running, but the backups will currently fail due to the repository not being
initialized.

To initialize the repository run:

```shell
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

```shell
docker-compose restart borgmatic-mailcow
```

## Restoring from a backup

Restoring a backup assumes you are starting off with a fresh installation of mailcow, and you currently do not have
any custom data in your maildir or your mailcow database.

### Restore maildir

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

```shell
docker-compose exec borgmatic-mailcow borgmatic extract --path mnt/source --archive latest
```

Alternatively you can specify any archive name from the list of archives (see
[Listing all available archives](#listing-all-available-archives))

### Restore MySQL

!!! warning
    Running this command will delete and recreate the mailcow database! Do not run this unless you actually
    intend to recover the mailcow database from a backup.

To restore the MySQL database from the latest archive use this command:

```shell
docker-compose exec borgmatic-mailcow borgmatic restore --archive latest
```

Alternatively you can specify any archive name from the list of archives (see
[Listing all available archives](#listing-all-available-archives))

### After restoring

After restoring you need to restart mailcow. If you disabled SELinux enforcing mode now would be a good time to
re-enable it.

To restart mailcow use the follwing command:

```shell
docker-compose down && docker-compose up -d
```

If you use SELinux this will also trigger the re-labeling of all files in your vmail volume. Be patient, as this may
take a while if you have lots of files.

## Useful commands

### Manual archiving run (with debugging output)

```shell
docker-compose exec borgmatic-mailcow borgmatic -v 2
```

### Listing all available archives

```shell
docker-compose exec borgmatic-mailcow borgmatic list
```

### Break lock

When borg is interrupted during an archiving run it will leave behind a stale lock that needs to be cleared before any
new operations can be performed:

```shell
docker-compose exec borgmatic-mailcow borg break-lock user@rsync.net:mailcow
```

Where `user@rsync.net:mailcow` is the URI to your repository.

Now would be a good time to do a manual archiving run to ensure it can be successfully performed.

### Exporting keys

When using any of the `keyfile` methods for encryption you **MUST** take care of backing up the key files yourself. The
key files are generated when you initialize the repository. The `repokey` methods store the key file within the
repository, so a manual backup isn't as essential.

Note that in either case you also must have the passphrase to decrypt any archives.

To fetch the keyfile run:

```shell
docker-compose exec borgmatic-mailcow borg key export --paper user@rsync.net:mailcow
```

Where `user@rsync.net:mailcow` is the URI to your repository.
