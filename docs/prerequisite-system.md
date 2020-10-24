Before you run **mailcow: dockerized**, there are a few requirements that you should check:

!!! warning
    Do **not** try to install mailcow on a Synology/QNAP device (any NAS), OpenVZ, LXC or other container platforms. KVM, ESX, Hyper-V and other full virtualization platforms are supported.
    Do **not** use CentOS 8 with Centos 7 Docker packages. You may create an open relay.

!!! info
    - mailcow: dockerized requires [some ports](#default-ports) to be open for incoming connections, so make sure that your firewall is not blocking these.
    - Make sure that no other application is interfering with mailcow's configuration, such as another mail service
    - A correct DNS setup is crucial to every good mailserver setup, so please make sure you got at least the [basics](../prerequisite-dns#the-minimal-dns-configuration) covered before you begin!
    - Make sure that your system has a correct date and [time setup](#date-and-time). This is crucial for various components like two factor TOTP authentication.

## Minimum System Resources

**Do not** use OpenVZ or LXC as guests for mailcow.

Please make sure that your system has at least the following resources:

| Resource                | mailcow: dockerized                          |
| ----------------------- | -------------------------------------------- |
| CPU                     | 1 GHz                                        |
| RAM                     | Minimum 4 GiB + Swap                         |
| Disk                    | 20 GiB (without emails)                      |
| System Type             | x86_64                                       |

As of today (29th Dec 2019), we recommend using any distribution listed as supported by Docker CE (check https://docs.docker.com/install/). We test on CentOS 7, Debian 9/10 and Ubuntu 18.04.

**NOTE:** It is technically possible to host Mailcow on a system with only 2 GiB RAM + Swap, however this is not ideal and may cause a variety of issues. Despite this, there are many Mailcow users whom have achieved hosting Mailcow without issue, and is generally done by users who are only hosting for themselves and not multiple users. It is also unlikely to be able to properly utilize ClamAV and Solr as they rely on large amounts of RAM. Despite being possible to host on such small resources, it is still highly recommended to have the minimum resources detailed in the table above, or more to avoid any complications.

**NOTE:** ClamAV and Solr are greedy RAM munchers. If working with minimal resources, it may be desired to disable either of these services.
You can disable them in `mailcow.conf` by settings SKIP_CLAMD=y and SKIP_SOLR=y.

## Firewall & Ports

**Important:** Some hosts and internet service providers may block ports such as 25 (SMTP) from being used, this can cause many issues, and can cause Mailcow to simply not function altogether. Please keep this in mind when choosing a provider or internet service provider to host Mailcow behind, and read thoroughly what they allow. 

Please check if any of mailcow's standard ports are open and not in use by other applications:

```
ss -tlpn | grep -E -w '25|80|110|143|443|465|587|993|995|4190'
# or:
netstat -tulpn | grep -E -w '25|80|110|143|443|465|587|993|995|4190'
```

If this command returns any results please remove or stop the application running on that port. You may also adjust mailcows ports via the `mailcow.conf` configuration file.

!!! warning
    There are several problems with running mailcow on a firewalld/ufw enabled system. You should disable it (if possible) and move your ruleset to the DOCKER-USER chain, which is not cleared by a Docker service restart, instead. Please refer to any of the following blog posts for information about how to use iptables-persistent with the DOCKER-USER chain for a working firewall setup.
    As mailcow runs dockerized, INPUT rules have no effect on restricting access to mailcow. Use the FORWARD chain instead.
- https://blog.donnex.net/docker-and-iptables-filtering/
- https://unrouted.io/2017/08/15/docker-firewall/
   

**



### Default Ports

If you have a firewall in front of mailcow, please make sure that these ports are open for incoming connections:

| Service             | Protocol | Port   | Container       | Variable                         |
| --------------------|:--------:|:-------|:----------------|----------------------------------|
| Postfix SMTP        | TCP      | 25     | postfix-mailcow | `${SMTP_PORT}`                   |
| Postfix SMTPS       | TCP      | 465    | postfix-mailcow | `${SMTPS_PORT}`                  |
| Postfix Submission  | TCP      | 587    | postfix-mailcow | `${SUBMISSION_PORT}`             |
| Dovecot IMAP        | TCP      | 143    | dovecot-mailcow | `${IMAP_PORT}`                   |
| Dovecot IMAPS       | TCP      | 993    | dovecot-mailcow | `${IMAPS_PORT}`                  |
| Dovecot POP3        | TCP      | 110    | dovecot-mailcow | `${POP_PORT}`                    |
| Dovecot POP3S       | TCP      | 995    | dovecot-mailcow | `${POPS_PORT}`                   |
| Dovecot ManageSieve | TCP      | 4190   | dovecot-mailcow | `${SIEVE_PORT}`                  |
| HTTP(S)             | TCP      | 80/443 | nginx-mailcow   | `${HTTP_PORT}` / `${HTTPS_PORT}` |

To bind a service to an IP address, you can prepend the IP like this: `SMTP_PORT=1.2.3.4:25`

**Important**: You cannot use IP:PORT bindings in HTTP_PORT and HTTPS_PORT. Please use `HTTP_PORT=1234` and `HTTP_BIND=1.2.3.4` instead.

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
