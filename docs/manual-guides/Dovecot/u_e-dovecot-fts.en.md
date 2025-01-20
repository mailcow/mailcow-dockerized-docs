!!! success "New Full-Text Search Engine"
    As of January 2025, Solr has been replaced by Flatcurve. All existing FTS indices are therefore **obsolete** and can be removed.

    mailcow references the old solr-vol-1 and prompts during every update process to remove it if it still exists.

Flatcurve is the new full-text search engine that works better even on less powerful systems. Additionally, it is expected to become the default full-text search engine for Dovecot in the long term.

Unlike Solr, Flatcurve does **not** require an additional Docker volume. Flatcurve stores its FTS databases in the `vmail-index` volume, resulting in a similar folder structure as:

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

Each subfolder in the IMAP server thus receives its own `fts-flatcurve` folder with the respective indices of the folder's emails.

!!! danger "Important"
    If you have been using Solr, a complete reindexing is required, as the two FTS engines are **not** **compatible** with each other.

    **An automatic indexing of the mailbox is activated as soon as 20 or more emails are received or a full-text search is performed.**

    We recommend performing a manual reindexing only under supervision, as excessive system load cannot be ruled out despite low system requirements.

    [Learn more about how to trigger a reindexing further down](#reindex-fts-database).

## FTS-Related Dovecot Commands

### Check and Repair FTS Database for Errors

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

Dovecot Wiki: "Scans which emails are present in the full-text search index and compares them with the emails actually present in the mailboxes. This removes emails from the index that have already been deleted and ensures that the next doveadm index indexes all missing emails (if any)."

This does **not** reindex a mailbox but merely repairs an existing index.

### Reindex FTS Database

If you want to reindex the data immediately, you can use the following command, where `*` can also be a mailbox mask such as 'Sent'. These commands are optional but can speed up the process:

=== "docker compose (Plugin)"

    ```bash
    # Single user
    docker compose exec dovecot-mailcow doveadm index -u user@domain '*'
    # All users, slower and riskier
    docker compose exec dovecot-mailcow doveadm index -A '*'
    ```

=== "docker-compose (Standalone)"

    ```bash
    # Single user
    docker-compose exec dovecot-mailcow doveadm index -u user@domain '*'
    # All users, slower and riskier
    docker-compose exec dovecot-mailcow doveadm index -A '*'
    ```

!!! info "Note"
    Indexing **will** take some time.

    Excessive system load, up to and including system crashes in rare cases, is possible. **Monitor the indexing process and your system load closely!**

Since reindexing can be resource-intensive, it has not been integrated into the mailcow UI.

**You must manually address any errors during reindexing via the CLI.**

### Delete FTS Database

mailcow automatically deletes a user's index data when the corresponding mailbox is deleted.

Alternatively, you can manually remove the index for Flatcurve via CLI:

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

## FTS-Specific Options in mailcow.conf

mailcow provides low default settings for the new FTS engine to ensure functionality even on less powerful systems.

For more powerful systems, you can adjust some parameters to enable more efficient indexing.

### `SKIP_FTS` (Disable Full-Text Search)

In mailcow.conf, you can completely disable full-text search. This is still recommended for low-end systems which are struggeling to run mailcow and the indexing process(es) at the same time.

Flatcurve is less resource-intensive than Solr but requires more storage and possibly more CPU power (depending on the setup).

!!! abstract "mailcow Default"
    ^^By default,^^ this parameter is set to **n**, meaning full-text search is enabled.

??? success "Best Practice"
    Initially, leave the indexing enabled. If the new FTS engine uses too many resources, you can change the setting later.

### `FTS_PROCS` (Number of Indexing Processes)

With the `FTS_PROCS` variable in mailcow.conf, you can adjust the number of indexing processes that can run simultaneously.

!!! abstract "mailcow Default"
    ^^By default,^^ this value is limited to **1 thread**.

!!! danger "**CAUTION**"
    Indexing processes are single-threaded applications that fully utilize a CPU thread. Systems with few cores should use a lower number to avoid overloading the system.

??? success "Best Practice"
    Plan for about **half of your system's CPU threads** for the indexing processes. For odd numbers of CPU threads, use the lower count to leave sufficient resources for the main system.

    **Dual-core** or **single-core systems** should disable full-text search.

### `FTS_HEAP` (Max Memory Per Indexing Process)

With `FTS_HEAP` in mailcow.conf, you can set the memory allocated per indexing process.

!!! abstract "mailcow Default"
    ^^By default,^^ this value is limited to **128 MB** ==per process==.

??? success "Best Practice"
    Ideally, allocate **512 MB** of memory per process. Systems with less than 8 GB RAM should stick to **128 MB** or increase to 256 MB, but reduce the number of processes to avoid OOM errors.

    While Dovecot continues to operate when RAM is exhausted per worker, it may become significantly slower.

## Advanced Configuration Options

Flatcurve integration allows for customizing FTS options as needed.

!!! notice "Note"
    Every setup is unique, so there is no universal "right" or "wrong" configuration.

    **Experience with the engine varies by system.**

For example, you can enable more detailed full-text search (substring search), which provides more accurate results but requires more storage and longer indexing times.

### Enable Substring Search (More Detailed Full-Text Search)

Edit the file `data/conf/dovecot/conf.d/fts.conf`:

```conf
plugin {
    [...]

    fts_flatcurve_substring_search=yes # Can be yes or no
}
```

Restart Dovecot to apply the changes:

=== "docker compose (Plugin)"

    ```bash
    docker compose restart dovecot-mailcow
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose restart dovecot-mailcow
    ```

### Additional Tweaks

We welcome community contributions for useful tweaks over time.

Meanwhile, you can refer to the official Dovecot and Flatcurve documentation for an overview of available parameters:

- [Dovecot FTS Module Documentation](https://doc.dovecot.org/2.3/settings/plugin/fts-plugin/){:target="_blank"}
- [Flatcurve FTS Engine Documentation](https://slusarz.github.io/dovecot-fts-flatcurve/configuration.html){:target="_blank"}