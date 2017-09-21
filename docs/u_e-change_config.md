The most important configuration files are mounted from the host into the related containers:

```
data/conf
├── unbound
│   └── unbound.conf
├── dovecot
│   ├── dovecot.conf
│   ├── dovecot-master.passwd
│   ├── sieve_after
│   └── sql
│       ├── dovecot-dict-sql.conf
│       └── dovecot-mysql.conf
├── mysql
│   └── my.cnf
├── nginx
│   ├── dynmaps.conf
│   ├── site.conf
│   └── templates
│       ├── listen_plain.template
│       ├── listen_ssl.template
│       └── server_name.template
├── postfix
│   ├── main.cf
│   ├── master.cf
│   ├── postscreen_access.cidr
│   ├── smtp_dsn_filter
│   └── sql
│       ├── mysql_relay_recipient_maps.cf
│       ├── mysql_tls_enforce_in_policy.cf
│       ├── mysql_tls_enforce_out_policy.cf
│       ├── mysql_virtual_alias_domain_catchall_maps.cf
│       ├── mysql_virtual_alias_domain_maps.cf
│       ├── mysql_virtual_alias_maps.cf
│       ├── mysql_virtual_domains_maps.cf
│       ├── mysql_virtual_mailbox_maps.cf
│       ├── mysql_virtual_relay_domain_maps.cf
│       ├── mysql_virtual_sender_acl.cf
│       └── mysql_virtual_spamalias_maps.cf
├── rmilter
│   └── rmilter.conf
├── rspamd
│   ├── dynmaps
│   │   ├── authoritative.php
│   │   ├── settings.php
│   │   ├── tags.php
│   │   └── vars.inc.php -> ../../../web/inc/vars.inc.php
│   ├── local.d
│   │   ├── dkim.conf
│   │   ├── metrics.conf
│   │   ├── options.inc
│   │   ├── redis.conf
│   │   ├── rspamd.conf.local
│   │   ├── statistic.conf
│   │   ├── logging.inc
│   │   ├── worker-controller.inc
│   │   └── worker-normal.inc
│   ├── lua
│   │   └── rspamd.local.lua
│   └── override.d (files in this directory can be created to override settings from files in local.d)
└── sogo
    ├── sieve.creds
    └── sogo.conf

```

Just change the according configuration file on the host and restart the related service:
```
docker-compose restart service-mailcow
```
