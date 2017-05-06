Before you run **mailcow: dockerized**, there are a few requirements that you should check:

- **WARNING**: When you want to run the dockerized version on your Debian 8 (Jessie) box you should [switch to the kernel 4.9 from jessie backports](https://packages.debian.org/jessie-backports/linux-image-amd64) because there is a bug (kernel panic) with the kernel 3.16 when running docker containers with *healthchecks*!
  Full more details read: [github.com/docker/docker/issues/30402](https://github.com/docker/docker/issues/30402) and [forum.mailcow.email/t/solved-mailcow-docker-causes-kernel-panic-edit/448](https://forum.mailcow.email/t/solved-mailcow-docker-causes-kernel-panic-edit/448)
- Mailcow: dockerized requires [some ports](#default-ports) to be open for incomming connections, so make sure that your firewall is not bloking these. Also make sure that no other application is interferring with mailcow's configuration.
- A correct DNS setup is crucial to every good mailserver setup, so please make sure you got at least the [basics](dns/#the-minimal-dns-configuration) covered bevore you begin!
- Make sure that your system has a correct date and time setup. This is crucial for stuff like two factor TOTP authentication.

## Minimum System Resources

Please make sure that your system has at least the following resources:

| Resource                | mailcow: dockerized |
| ----------------------- | ------------------- |
| CPU                     | 1 GHz               |
| RAM                     | 1 GiB               |
| Disk                    | 5 GiB               |
| System Type             | x86_64              |

## Firewall & Ports

Please check if any of mailcow's standard ports are open and not blocked by other applications:

```bash
netstat -tulpn | grep -E -w '25|80|110|143|443|465|587|993|995'
```

If this command returns any results please remove or stop the application running on that port. You may also adjust mailcows ports via the `mailcow.conf` configuration file.

### Default Ports

If you have a firewall already up and running please make sure that these ports are open for incomming connections:

| Service             | Protocol | Port   | Container       |
| --------------------|:--------:|:-------|:----------------|
| Postfix Submission  | TCP      | 587    | postfix-mailcow |
| Postfix SMTPS       | TCP      | 465    | postfix-mailcow |
| Postfix SMTP        | TCP      | 25     | postfix-mailcow |
| Dovecot IMAP        | TCP      | 143    | dovecot-mailcow |
| Dovecot IMAPS       | TCP      | 993    | dovecot-mailcow |
| Dovecot POP3        | TCP      | 110    | dovecot-mailcow |
| Dovecot POP3S       | TCP      | 995    | dovecot-mailcow |
| Dovecot ManageSieve | TCP      | 4190   | dovecot-mailcow |
| HTTP(S)             | TCP      | 80/443 | nginx-mailcow   |
