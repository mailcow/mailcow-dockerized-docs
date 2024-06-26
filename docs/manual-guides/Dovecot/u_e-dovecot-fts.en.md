
## FTS Solr (Deprecated)

!!! danger "Warning"
    Solr will only be supported until December 2024 and will then be removed from mailcow and replaced with Flatcurve.

Solr is used for setups with memory >= 3.5 GiB to enable full-text search in Dovecot.

Please note that applications like Solr _may_ need to be maintained from time to time.

Additionally, Solr consumes a lot of RAM, depending on your server's usage. Please avoid using it on machines with less than 3 GiB RAM.

The default heap size (1024 M) is defined in `mailcow.conf`.

Since we run in Docker and create our containers with the "restart: always" flag, an OOM situation will at least only trigger a container restart.

## FTS Flatcurve (Experimental since 2024-06)

Flatcurve will soon replace the current FTS engine Solr to allow full-text search to function better on lower-performance systems.

Starting with the June 2024 update, experimental support for Flatcurve as a full-text search has been implemented, which can only be activated via a `mailcow.conf` variable during the experimental phase.

!!! info "Note"
    During the transition period, mailcow will specify the configuration for the FTS engine within Dovecot and overwrite any custom changes (unless explicitly defined in the `extra.conf`). This will no longer be the case with the full release of the engine within mailcow.

### Activating the Experimental Flatcurve Usage

Activation is simple and requires only two small steps:

1. Edit `mailcow.conf` and add the following value:

    ```bash
    FLATCURVE_EXPERIMENTAL=y
    ```

2. Restart mailcow:

    === "docker compose (Plugin)"

        ```bash
        docker compose up -d
        ```

    === "docker-compose (Standalone)"

        ```bash
        docker-compose up -d
        ```

mailcow will now use Flatcurve as the FTS backend.

Unlike Solr, Flatcurve **does not** require an additional Docker volume. Flatcurve stores its FTS databases in the `vmail-index` volume and results in a similar folder structure as:

```
/var/vmail_index/tester@develcow.de/.INBOX/
├── dovecot.index
├── dovecot.index.cache
├── dovecot.index.log
└── fts-flatcurve
    └── index.814
        ├── flintlock
        ├── iamglass
        ├── postlist.glass
        └── termlist.glass
```

Each subfolder on the IMAP server thus receives its own `fts-flatcurve` folder with the respective indices of the mails in the folder.

!!! info "Note"
    The Solr container will still remain during the transition period (expected until December 2024) to allow for a smooth transition.

!!! warning "Warning"
    If you decide to switch the FTS engine, a complete reindexing is necessary, as the two systems are not compatible with each other.
    [Learn below how to initiate a reindexing](#reindex-fts-database).

    However, we recommend performing this reindexing only under supervision, as excessive system load cannot be ruled out despite low system requirements!

## FTS-Related Dovecot Commands

### Check FTS Database for Errors and Repair if Necessary

=== "docker compose (Plugin)"

    ```bash
    # Single user
    docker compose exec dovecot-mailcow doveadm fts rescan -u user@domain
    # All users
    docker compose exec dovecot-mailcow doveadm fts rescan -A
    ```

=== "docker-compose (Standalone)"

    ```bash
    # Single user
    docker-compose exec dovecot-mailcow doveadm fts rescan -u user@domain
    # All users
    docker-compose exec dovecot-mailcow doveadm fts rescan -A
    ```

Dovecot Wiki: "Scans which mails are present in the full-text search index and compares them with the mails actually present in the mailboxes. This removes mails from the index that have already been deleted and ensures that the next doveadm index indexes all missing mails (if any)."

This does **not** reindex a mailbox. It essentially repairs a given index.

### Reindex FTS Database

If you want to reindex the data immediately, you can run the following command, where `*` can also be a mailbox mask like 'Sent'. You do not have to run these commands, but it will speed things up a bit:

=== "docker compose (Plugin)"

    ```bash
    # Single user
    docker compose exec dovecot-mailcow doveadm index -u user@domain '*'
    # All users, but obviously slower and more dangerous
    docker compose exec dovecot-mailcow doveadm index -A '*'
    ```

=== "docker-compose (Standalone)"

    ```bash
    # Single user
    docker-compose exec dovecot-mailcow doveadm index -u user@domain '*'
    # All users, but obviously slower and more dangerous
    docker-compose exec dovecot-mailcow doveadm index -A '*'
    ```

!!! info "Note"
    The indexing **will** take some time.
    
    Depending on the FTS engine, there is a possibility of excessive system usage, even leading to system crashes in rare cases. **So, monitor the indexing process and your system load closely!**

Since reindexing can be somewhat fragile and particularly sensitive to system resources, we have not integrated it into the mailcow UI.

**You must manually handle any errors when reindexing a mailbox via CLI.**

### Delete FTS Database

mailcow will automatically delete a user's index data when the corresponding mailbox is deleted.

Alternatively, the index for Flatcurve can be manually deleted via CLI:

=== "docker compose (Plugin)"

    ```bash
    # Single user
    docker compose exec dovecot-mailcow doveadm fts-flatcurve remove -u user@domain '*'
    # All users
    docker compose exec dovecot-mailcow doveadm fts-flatcurve remove -A '*'
    ```

=== "docker-compose (Standalone)"

    ```bash
    # Single user
    docker-compose exec dovecot-mailcow doveadm fts-flatcurve remove -u user@domain '*'
    # All users
    docker-compose exec dovecot-mailcow doveadm fts-flatcurve remove -A '*'
    ```
