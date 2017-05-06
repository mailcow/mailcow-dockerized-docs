**WARNING** Please be adviced that this guide is a first draft. Mailcow: dockerized changed quite a lot on its DB configuration. It now uses the InnoDB file format `Barracuda` and the `utf8mb4` character set. There is also some change to the DB / TABLE structure.

Also note that this guide doesn't touch on the users settings like *Spamlevels*, *TLS Settings*, etc. nor the export / import of your roundcube or SOGo settings.

Lastly please check the section on how to [import / restore](backup_maildir/#restore) your maildir backup to get an idea how to migrate your mails.

## Create mailcow db backups

First you need to modify the table `mailcow`. Mailcow-dockerized adds three and moves two existing columns in the table `mailbox`. The columns `tls_enforce_in` and `tls_enforce_out` get moved two rows up (behind `domain`). The columns `key`, `multiple_bookings` and `wants_tagged_subject` need to be added after `tls_enforce_out`.

It should look like this:

```
MariaDB [mailcow]> desc mailbox;
+----------------------+--------------+------+-----+-------------------+-----------------------------+
| Field                | Type         | Null | Key | Default           | Extra                       |
+----------------------+--------------+------+-----+-------------------+-----------------------------+
| username             | varchar(255) | NO   | PRI | NULL              |                             |
| password             | varchar(255) | NO   |     | NULL              |                             |
| name                 | varchar(255) | YES  |     | NULL              |                             |
| maildir              | varchar(255) | NO   |     | NULL              |                             |
| quota                | bigint(20)   | NO   |     | 0                 |                             |
| local_part           | varchar(255) | NO   |     | NULL              |                             |
| domain               | varchar(255) | NO   | MUL | NULL              |                             |
| tls_enforce_in       | tinyint(1)   | NO   |     | 0                 |                             |
| tls_enforce_out      | tinyint(1)   | NO   |     | 0                 |                             |
| kind                 | varchar(100) | NO   |     |                   |                             |
| multiple_bookings    | tinyint(1)   | NO   |     | 0                 |                             |
| wants_tagged_subject | tinyint(1)   | NO   |     | 0                 |                             |
| created              | datetime     | NO   |     | CURRENT_TIMESTAMP |                             |
| modified             | datetime     | YES  |     | NULL              | on update CURRENT_TIMESTAMP |
| active               | tinyint(1)   | NO   |     | 1                 |                             |
+----------------------+--------------+------+-----+-------------------+-----------------------------+
```

You can do this with a UI like [Adminer](https://www.adminer.org/#download) or use the MySQL CLI like :

```
MariaDB [mailcow]> ALTER TABLE mailbox MODIFY COLUMN tls_enforce_in TINYINT(1) NOT NULL DEFAULT '0' AFTER domain,
MODIFY COLUMN tls_enforce_out TINYINT(1) NOT NULL DEFAULT '0' AFTER tls_enforce_in;
MariaDB [mailcow]> ALTER TABLE mailbox ADD COLUMN `kind` VARCHAR(255) NOT NULL AFTER `tls_enforce_out`,
ADD COLUMN `multiple_bookings` TINYINT(1) NOT NULL DEFAULT '0' AFTER `kind`,
ADD COLUMN `wants_tagged_subject` TINYINT(1) NOT NULL DEFAULT '0' AFTER `multiple_bookings`;
MariaDB [mailcow]> DESC mailbox;
```

When this is done we can backup the tables:

```bash
# Load your mysql variables into environment
DBHOST=$(grep database_host /var/www/mail/inc/vars.inc.php | cut -d'"' -f2)
DBNAME=$(grep database_name /var/www/mail/inc/vars.inc.php | cut -d'"' -f2)
DBUSER=$(grep database_user /var/www/mail/inc/vars.inc.php | cut -d'"' -f2)
DBPASS=$(grep database_pass /var/www/mail/inc/vars.inc.php | cut -d'"' -f2)

# Backup your tables
mysqldump --replace --no-create-info --default-character-set=utf8mb4 \
    --host &{DBHOST}-u${DBUSER} -p${DBPASS} ${DBNAME} \
    alias alias_domain domain domain_admins mailbox quota2 sender_acl > backup_mailcow.sql
```

- **--replace**: Write `REPLACE` statements rather than `INSERT` statements
- **--no-create-info**: Don't write `CREATE TABLE` statements.
- **--default-character-set** make sure our exported default charset is *utf8mb4*.


## Prepare mailcow: dockerized

To initiate your fresh installed database, visit **https://${MAILCOW_HOSTNAME}** with a browser of your choice. Check if the DB is initiated correctly afterwards:

```
# source mailcow.conf
# docker-compose exec mysql-mailcow mysql -u${DBUSER} -p${DBPASS} ${DBNAME}
MariaDB [mailcow]> show tables;
+-------------------------------+
| Tables_in_mailcow             |
+-------------------------------+
| admin                         |
| alias                         |
[...]
```

## Import your backups:

  ```
  # source mailcow.conf
  # docker exec -i $(docker-compose ps -q mysql-mailcow) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} < backup_mailcow.sql
  ```

  Recalculate used quota with `doveadm`:

  ```
  # docker-compose exec dovecot-mailcow doveadm quota recalc -A
  ```

  Restart services:

  ```
  # docker-compose restart
  ```
