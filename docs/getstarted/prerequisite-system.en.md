Before you run **mailcow: dockerized**, there are a few requirements that you should check:

!!! warning
    Do **not** try to install mailcow on a Synology/QNAP device (any NAS), OpenVZ, LXC or other container platforms. KVM, ESX, Hyper-V and other full virtualization platforms are supported.

!!! info
    - mailcow: dockerized requires [some ports](#incoming-ports) to be open for incoming connections, so make sure that your firewall is not blocking these.
    - Make sure that no other application is interfering with mailcow's configuration, such as another mail service
    - A correct DNS setup is crucial to every good mailserver setup, so please make sure you got at least the [basics](../getstarted/prerequisite-dns.en.md#the-minimal-dns-configuration) covered before you begin!
    - Make sure that your system has a correct date and [time setup](#date-and-time). This is crucial for various components like two factor TOTP authentication.

## Minimum System Resources
Please make sure that your system has at least the following resources:

| Resource     | Minimal Requirement                             |
| ------------ | ----------------------------------------------- |
| CPU          | 1 GHz                                           |
| RAM          | **Minimum** 6 GiB + 1 GiB swap (default config) |
| Disk         | 20 GiB (without emails)                         |
| Architecture | x86_64, ARM64                                   |

!!! failure "Not supported"
	**OpenVZ, Virtuozzo and LXC**

ClamAV and Solr can be greedy with RAM. You may disable them in `mailcow.conf` by settings `SKIP_CLAMD=y` and `SKIP_SOLR=y`.

!!! info 
	We are aware that a pure MTA can run on 128 MiB RAM. mailcow is a full-grown and ready-to-use groupware with many extras making life easier. mailcow comes with a webserver, webmailer, ActiveSync (MS), antivirus, antispam, indexing (Solr), document scanner (Oletools), SQL (MariaDB), Cache (Redis), MDA, MTA, various web services etc.

A single SOGo worker **can** acquire ~350 MiB RAM before it gets purged. The more ActiveSync connections you plan to use, the more RAM you will need. A default configuration spawns 20 workers.

#### RAM usage examples

A company with 15 phones (EAS enabled) and about 50 concurrent IMAP connections should plan 16 GiB RAM.

6 GiB RAM + 1 GiB swap are fine for most private installations while 8 GiB RAM are recommended for ~5 to 10 users.

We can help to correctly plan your setup as part of our support.

### Supported OS
!!! danger "Important"
    mailcow is using Docker as a base component, due to some technical differences across multiple platforms we do **not support all**, even if they can run Docker.

The following table contains all operating systems officially supported and tested by us (*as of December 2024*):

| OS                      | Compatibility                                             |
| ----------------------- | --------------------------------------------------------- |
| Alpine since 3.19       | [⚠️](https://www.alpinelinux.org/ "Limited Compatibility") |
| Debian 11, 12           | [✅](https://www.debian.org/index.html "Fully Compatible") |
| Ubuntu 22.04 (or newer) | [✅](https://ubuntu.com/ "Fully Compatible")               |
| Alma Linux 8, 9         | [✅](https://almalinux.org/ "Fully Compatible")            |
| Rocky Linux 9           | [✅](https://rockylinux.org/ "Fully Compatible")           |


!!! info "Legend"
    ✅ = Works **out of the box** using the instructions.<br>
    ⚠️ = Requires some **manual adjustments** otherwise usable.<br>
    ❌ = In general **NOT Compatible**.<br>
    ❔ = Pending.

!!! warning
    **Note: All other operating systems (not mentioned) may also work, but have not been officially tested.**

## Firewall & Ports

Please check if any of mailcow's standard ports are open and not in use by other applications:

```
ss -tlpn | grep -E -w '25|80|110|143|443|465|587|993|995|4190'
# or:
netstat -tulpn | grep -E -w '25|80|110|143|443|465|587|993|995|4190'
```

!!! danger
    There are several problems with running mailcow on a firewalld/ufw enabled system. <br>
	You should disable it (if possible) and move your ruleset to the DOCKER-USER chain, which is not cleared by a Docker service restart, instead. <br>
	See [this (blog.donnex.net)](https://blog.donnex.net/docker-and-iptables-filtering/) or [this (unrouted.io)](https://unrouted.io/2017/08/15/docker-firewall/) guide for information about how to use iptables-persistent with the DOCKER-USER chain.<br>
    As mailcow runs dockerized, INPUT rules have no effect on restricting access to mailcow. <br>
	Use the FORWARD chain instead.<br>

If this command returns any results please remove or stop the application running on that port. You may also adjust mailcows ports via the `mailcow.conf` configuration file.

### Incoming Ports

If you have a firewall in front of mailcow, please ensure that these ports are open for incoming connections:

| Service             | Protocol | Port   | Container       | Variable                         |
| ------------------- | :------: | :----- | :-------------- | -------------------------------- |
| Postfix SMTP        |   TCP    | 25     | postfix-mailcow | `${SMTP_PORT}`                   |
| Postfix SMTPS       |   TCP    | 465    | postfix-mailcow | `${SMTPS_PORT}`                  |
| Postfix Submission  |   TCP    | 587    | postfix-mailcow | `${SUBMISSION_PORT}`             |
| Dovecot IMAP        |   TCP    | 143    | dovecot-mailcow | `${IMAP_PORT}`                   |
| Dovecot IMAPS       |   TCP    | 993    | dovecot-mailcow | `${IMAPS_PORT}`                  |
| Dovecot POP3        |   TCP    | 110    | dovecot-mailcow | `${POP_PORT}`                    |
| Dovecot POP3S       |   TCP    | 995    | dovecot-mailcow | `${POPS_PORT}`                   |
| Dovecot ManageSieve |   TCP    | 4190   | dovecot-mailcow | `${SIEVE_PORT}`                  |
| HTTP(S)             |   TCP    | 80/443 | nginx-mailcow   | `${HTTP_PORT}` / `${HTTPS_PORT}` |

To bind a service to an IP address, you can prefix the IP address as follows: `SMTP_PORT=1.2.3.4:25`

**Important**: You cannot use IP:PORT bindings for `HTTP_PORT` and `HTTPS_PORT`. Please use `HTTP_PORT=1234` and `HTTP_BIND=1.2.3.4` instead.

### Outgoing Ports/Hosts

Some outgoing connections are required to use mailcow. Ensure that mailcow can communicate with the following hosts or ports:

| Service           | Protocol      | Port    | Target                                | Reason                                                                                       |
| ----------------- | ------------- | ------- | ------------------------------------- | -------------------------------------------------------------------------------------------- |
| Clamd             | TCP           | 873     | rsync.sanesecurity.net                | Download ClamAV signatures (prebundled in mailcow)                                           |
| Dovecot           | TCP           | 443     | spamassassin.heinlein-support.de      | Download Spamassassin rules processed by Rspamd, downloaded via Dovecot                      |
| mailcow Processes | TCP           | 80/443  | github.com                            | Download mailcow updates (code-based)                                                        |
| mailcow Processes | TCP           | 443     | hub.docker.com                        | Download Docker images (directly from Docker Hub)                                            |
| mailcow Processes | TCP           | 443     | asn-check.mailcow.email               | API request for BAD ASN checks (for Spamhaus Free Blocklists)                                |
| mailcow Processes | TCP           | 80      | ip4.mailcow.email & ip6.mailcow.email | Retrieve public IP address for display in UI (**optional**)                                  |
| Postfix           | TCP           | 25, 465 | Any                                   | Outgoing connection for MTA                                                                  |
| Rspamd            | TCP           | 80      | fuzzy.mailcow.email                   | Download bad subject regex maps (trained by Servercow)                                       |
| Rspamd            | TCP           | 443     | bazaar.abuse.ch                       | Download malware MD5 checksums for detection by Rspamd                                       |
| Rspamd            | TCP           | 443     | urlhaus.abuse.ch                      | Download malware download links for detection in Rspamd                                      |
| Rspamd            | UDP           | 11445   | fuzzy.mailcow.email                   | Connection to global mailcow fuzzy (trained by Servercow + community)                        |
| Rspamd            | UDP           | 11335   | fuzzy1.rspamd.com & fuzzy2.rspamd.com | Connection to global Rspamd fuzzy (trained by the Rspamd team)                               |
| Unbound           | TCP **&** UDP | 53      | Any                                   | DNS resolution for the mailcow stack (for DNSSEC validation and retrieval of spam list info) |
| Unbound           | ICMP (Ping)   |         | 1.1.1.1, 8.8.8.8, 9.9.9.9             | Basic internet connectivity check                                                            |

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
NTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
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

Especially relevant for OpenStack users: Check your MTU and set it accordingly in docker-compose.yml. See [Troubleshooting](../getstarted/install.md#users-with-a-mtu-not-equal-to-1500-eg-openstack) in our Installation guide.
