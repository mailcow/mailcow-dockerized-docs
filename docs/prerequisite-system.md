Before you run **mailcow: dockerized**, there are a few requirements that you should check:

!!! warning
    Do **not** try to install mailcow on a Synology/QNAP device (any NAS), OpenVZ, LXC or other container platforms. KVM, ESX, Hyper-V and other full virtualization platforms are supported.
    We **do not** recommend to use CentOS 8 anymore!

!!! info
    - mailcow: dockerized requires [some ports](#default-ports) to be open for incoming connections, so make sure that your firewall is not blocking these.
    - Make sure that no other application is interfering with mailcow's configuration, such as another mail service
    - A correct DNS setup is crucial to every good mailserver setup, so please make sure you got at least the [basics](../prerequisite-dns#the-minimal-dns-configuration) covered before you begin!
    - Make sure that your system has a correct date and [time setup](#date-and-time). This is crucial for various components like two factor TOTP authentication.

## Minimum System Resources

**OpenVZ, Virtuozzo and LXC are not supported**.

Please make sure that your system has at least the following resources:

| Resource                | mailcow: dockerized                              |
| ----------------------- | ------------------------------------------------ |
| CPU                     | 1 GHz                                            |
| RAM                     | **Minimum** 6 GiB + 1 GiB swap (default config)  |
| Disk                    | 20 GiB (without emails)                          |
| System Type             | x86_64                                           |

We recommend using any distribution listed as supported by Docker CE (check https://docs.docker.com/install/). We test on CentOS 7, Debian 9/10 and Ubuntu 18.04/20.04.

ClamAV and Solr can be greedy with RAM. You may disable them in `mailcow.conf` by settings `SKIP_CLAMD=y` and `SKIP_SOLR=y`.

**Info**: We are aware that a pure MTA can run on 128 MiB RAM. mailcow is a full-grown and ready-to-use groupware with many extras making life easier. mailcow comes with a webserver, webmailer, ActiveSync (MS), antivirus, antispam, indexing (Solr), document scanner (Oletools), SQL (MariaDB), Cache (Redis), MDA, MTA, various web services etc.

A single SOGo worker **can** acquire ~350 MiB RAM before it gets purged. The more ActiveSync connections you plan to use, the more RAM you will need. A default configuration spawns 20 workers.

#### Usage examples

A company with 15 phones (EAS enabled) and about 50 concurrent IMAP connections should plan 16 GiB RAM.

6 GiB RAM + 1 GiB swap are fine for most private installations while 8 GiB RAM are recommended for ~5 to 10 users.

We can help to correctly plan your setup as part of our support.

## Firewall & Ports

Please check if any of mailcow's standard ports are open and not in use by other applications:

```
ss -tlpn | grep -E -w '25|80|110|143|443|465|587|993|995|4190|5222|5269|5443'
# or:
netstat -tulpn | grep -E -w '25|80|110|143|443|465|587|993|995|4190|5222|5269|5443'
```

!!! warning
    There are several problems with running mailcow on a firewalld/ufw enabled system. You should disable it (if possible) and move your ruleset to the DOCKER-USER chain, which is not cleared by a Docker service restart, instead. See [this (blog.donnex.net)](https://blog.donnex.net/docker-and-iptables-filtering/) or [this (unrouted.io)](https://unrouted.io/2017/08/15/docker-firewall/) guide for information about how to use iptables-persistent with the DOCKER-USER chain.
    As mailcow runs dockerized, INPUT rules have no effect on restricting access to mailcow. Use the FORWARD chain instead.

If this command returns any results please remove or stop the application running on that port. You may also adjust mailcows ports via the `mailcow.conf` configuration file.

### Default Ports

If you have a firewall in front of mailcow, please make sure that these ports are open for incoming connections:

| Service             | Protocol | Port   | Container         | Variable                         |
| --------------------|:--------:|:-------|:------------------|----------------------------------|
| Postfix SMTP        | TCP      | 25     | postfix-mailcow   | `${SMTP_PORT}`                   |
| Postfix SMTPS       | TCP      | 465    | postfix-mailcow   | `${SMTPS_PORT}`                  |
| Postfix Submission  | TCP      | 587    | postfix-mailcow   | `${SUBMISSION_PORT}`             |
| Dovecot IMAP        | TCP      | 143    | dovecot-mailcow   | `${IMAP_PORT}`                   |
| Dovecot IMAPS       | TCP      | 993    | dovecot-mailcow   | `${IMAPS_PORT}`                  |
| Dovecot POP3        | TCP      | 110    | dovecot-mailcow   | `${POP_PORT}`                    |
| Dovecot POP3S       | TCP      | 995    | dovecot-mailcow   | `${POPS_PORT}`                   |
| Dovecot ManageSieve | TCP      | 4190   | dovecot-mailcow   | `${SIEVE_PORT}`                  |
| HTTP(S)             | TCP      | 80/443 | nginx-mailcow     | `${HTTP_PORT}` / `${HTTPS_PORT}` |
| XMPP (c2s)          | TCP      | 5222   | ejabberd-mailcow  | `${XMPP_C2S_PORT}`               |
| XMPP (s2s)          | TCP      | 5269   | ejabberd-mailcow  | `${XMPP_C2S_PORT}`               |
| XMPP (upload)       | TCP      | 5443   | ejabberd-mailcow  | `${XMPP_HTTPS_PORT}`             |

To bind a service to an IP address, you can prepend the IP like this: `SMTP_PORT=1.2.3.4:25`

**Important**: You cannot use IP:PORT bindings in HTTP_PORT and HTTPS_PORT. Please use `HTTP_PORT=1234` and `HTTP_BIND=1.2.3.4` instead.

### Important for Hetzner firewalls

Quoting https://github.com/chermsen via https://github.com/mailcow/mailcow-dockerized/issues/497#issuecomment-469847380 (THANK YOU!):

For all who are struggling with the Hetzner firewall:

Port 53 unimportant for the firewall configuration in this case. According to the documentation unbound uses the port range 1024-65535 for outgoing requests.
Since the Hetzner Robot Firewall is a static firewall (each incoming packet is checked isolated) - the following rules must be applied:

**For TCP**
```
SRC-IP:       ---
DST IP:       ---
SRC Port:    ---
DST Port:    1024-65535
Protocol:    tcp
TCP flags:   ack
Action:      Accept
```

**For UDP**
```
SRC-IP:       ---
DST IP:       ---
SRC Port:    ---
DST Port:    1024-65535
Protocol:    udp
Action:      Accept
```

If you want to apply a more restrictive port range you have to change the config of unbound first (after installation):

{mailcow-dockerized}/data/conf/unbound/unbound.conf:
```
outgoing-port-avoid: 0-32767
```

Now the firewall rules can be adjusted as follows:

```
[...]
DST Port:  32768-65535
[...]
```

## Date and Time

To ensure that you have the correct date and time setup on your system, please check the output of `timedatectl status`:

```
$ timedatectl status
      Local time: Sat 2017-05-06 02:12:33 CEST
  Universal time: Sat 2017-05-06 00:12:33 UTC
        RTC time: Sat 2017-05-06 00:12:32
       Time zone: Europe/Berlin (CEST, +0200)
     NTP enabled: yes
NTP synchronized: yes
 RTC in local TZ: no
      DST active: yes
 Last DST change: DST began at
                  Sun 2017-03-26 01:59:59 CET
                  Sun 2017-03-26 03:00:00 CEST
 Next DST change: DST ends (the clock jumps one hour backwards) at
                  Sun 2017-10-29 02:59:59 CEST
                  Sun 2017-10-29 02:00:00 CET
```

The lines `NTP enabled: yes` and `NTP synchronized: yes` indicate whether you have NTP enabled and if it's synchronized.

To enable NTP you need to run the command `timedatectl set-ntp true`. You also need to edit your `/etc/systemd/timesyncd.conf`:

```
# vim /etc/systemd/timesyncd.conf
[Time]
Servers=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
```

## Hetzner Cloud (and probably others)

Check `/etc/network/interfaces.d/50-cloud-init.cfg` and change the IPv6 interface from eth0:0 to eth0:

```
# Wrong:
auto eth0:0
iface eth0:0 inet6 static
# Right:
auto eth0
iface eth0 inet6 static
```

Reboot or restart the interface.
You may want to [disable cloud-init network changes.](https://wiki.hetzner.de/index.php/Cloud_IP_static/en#disable_cloud-init_network_changes)

## MTU

Especially relevant for OpenStack users: Check your MTU and set it accordingly in docker-compose.yml. See **4.1** in [our installation docs](https://mailcow.github.io/mailcow-dockerized-docs/i_u_m_install/).
