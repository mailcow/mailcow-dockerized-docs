## Logs

You can use `docker-compose logs $service-name` for all containers.

Run `docker-compose logs` for all logs at once.

Follow the log output by running docker-compose with `logs -f`.

Limit the output by calling logs with `--tail=300` like `docker-compose logs --tail=300 mysql-mailcow`.

## Reset admin password
Reset mailcow admin to `admin:moohoo`:

```
cd mailcow_path
bash mailcow-reset-admin.sh
```

## What container does what

Here is a brief overview of what container does what:

| Container Name  | Service Descriptions                                                      |
| --------------- | ------------------------------------------------------------------------- |
| bind9-mailcow   | Local (DNSSEC) DNS Resolver                                               |
| mysql-mailcow   | Stores most of mailcow's settings                                         |
| postfix-mailcow | Receives and sends mails                                                  |
| dovecot-mailcow | User logins and sieve filter                                              |
| redis-mailcow   | Storage backend for DKIM keys, Rmilter and Rspamd                         |
| rspamd-mailcow  | Mail filtering system. Used for av handling, dkim signing, spam handling  |
| rmilter-mailcow | Integrates Rspamd into postfix                                            |
| clamd-mailcow   | Scans attachments for viruses                                             |
| sogo-mailcow    | Webmail client that handles Microsoft ActiveSync and Cal- / CardDav       |
| nginx-mailcow   | Nginx remote proxy that handles all mailcow related HTTP / HTTPS requests |
