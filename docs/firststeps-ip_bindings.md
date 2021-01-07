!!! warning
    Changing the binding does not affect source NAT. See [SNAT](https://mailcow.github.io/mailcow-dockerized-docs/firststeps-snat/) for required steps.

## IPv4 binding

To adjust one or multiple IPv4 bindings, open `mailcow.conf` and edit one, multiple or all variables as per your needs:

```
# For technical reasons, http bindings are a bit different from other service bindings.
# You will find the following variables, separated by a bind address and its port:
# Example: HTTP_BIND=1.2.3.4

HTTP_PORT=80
HTTP_BIND=
HTTPS_PORT=443
HTTPS_BIND=

# Other services are bound by using the following format:
# SMTP_PORT=1.2.3.4:25 will bind SMTP to the IP 1.2.3.4 on port 25
# Important! Specifying an IPv4 address will skip all IPv6 bindings since Docker 20.x.
# doveadm, SQL as well as Solr are bound to local ports only, please do not change that, unless you know what you are doing.

SMTP_PORT=25
SMTPS_PORT=465
SUBMISSION_PORT=587
IMAP_PORT=143
IMAPS_PORT=993
POP_PORT=110
POPS_PORT=995
SIEVE_PORT=4190
DOVEADM_PORT=127.0.0.1:19991
SQL_PORT=127.0.0.1:13306
SOLR_PORT=127.0.0.1:18983
```

To apply your changes, run `docker-compose down` followed by `docker-compose up -d`.

## IPv6 binding

Changing IPv6 bindings is different from IPv4. Again, this has a technical background.

A `docker-compose.override.yml` file will be used instead of editing the `docker-compose.yml` file directly. This is to maintain updatability, as the `docker-compose.yml` file gets updated regularly and your changes will most likely be overwritten.

Edit to create a file  `docker-compose.override.yml` with the following content. Its content will be merged with the productive `docker-compose.yml` file.

An imaginary IPv6 **2a00:dead:beef::abc** is given. The first suffix `:PORT1` defines the external port, while the second suffix `:PORT2` routes to the corresponding port inside the container and must not be changed.

```
version: '2.1'
services:

    dovecot-mailcow:
      ports:
        - '2a00:dead:beef::abc:143:143'
        - '2a00:dead:beef::abc:993:993'
        - '2a00:dead:beef::abc:110:110'
        - '2a00:dead:beef::abc:995:995'
        - '2a00:dead:beef::abc:4190:4190'

    postfix-mailcow:
      ports:
        - '2a00:dead:beef::abc:25:25'
        - '2a00:dead:beef::abc:465:465'
        - '2a00:dead:beef::abc:587:587'

    nginx-mailcow:
      ports:
        - '2a00:dead:beef::abc:80:80'
        - '2a00:dead:beef::abc:443:443'
```

To apply your changes, run `docker-compose down` followed by `docker-compose up -d`.
