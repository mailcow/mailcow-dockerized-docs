Enable Rsyslog to receive logs on 524/tcp:

```
# This setting depends on your Rsyslog version and configuration format.
# For most Debian derivates it will work like this...
$ModLoad imtcp
$TCPServerAddress 127.0.0.1
$InputTCPServerRun 524

# ...while for Ubuntu 16.04 it looks like this:
module(load="imtcp")
input(type="imtcp" address="127.0.0.1" port="524")

# No matter your Rsyslog version, you should set this option to off
# if you plan to use Fail2ban
$RepeatedMsgReduction off
```

Restart rsyslog after enabling the TCP listener.

Now setup Docker daemon to start with the syslog driver.
This enables the syslog driver for all containers!

Debian users can change the startup configuration in `/etc/default/docker` while CentOS users find it in `/etc/sysconfig/docker`:
```
...
DOCKER_OPTS="--log-driver=syslog --log-opt syslog-address=tcp://127.0.0.1:524"
...
```

**Caution:** For some reason Ubuntu 16.04 and some, but not all, systemd based distros do not read the defaults file parameters.

Just run `systemctl edit docker.service` and add the following content to fix it.

**Note:** If "systemctl edit" is not available, just copy the content to `/etc/systemd/system/docker.service.d/override.conf`.

The first empty ExecStart parameter is not a mistake.

```
[Service]
EnvironmentFile=/etc/default/docker
ExecStart=
ExecStart=/usr/bin/docker daemon -H fd:// $DOCKER_OPTS
```

Restart the Docker daemon and run `docker-compose down && docker-compose up -d` to recreate the containers.

### Fail2ban

**This is a subsection of "Log to Syslog", which is required for Fail2ban to work.**

Open `/etc/fail2ban/filter.d/common.conf` and search for the prefix_line parameter, change it to ".*":

```
__prefix_line = .*
```

Create `/etc/fail2ban/jail.d/dovecot.conf`...
```
[dovecot]
enabled = true
filter  = dovecot
logpath = /var/log/syslog
chain = FORWARD
```

and `jail.d/postfix-sasl.conf`:
```
[postfix-sasl]
enabled = true
filter  = postfix-sasl
logpath = /var/log/syslog
chain = FORWARD
```

Restart Fail2ban.
