Logging in mailcow: dockerized consists of multiple stages, but is, after all, much more flexible and easier to integrate into a logging daemon than before.

In Docker the containerized application (PID 1) writes its output to stdout. For real one-application containers this works just fine.
Run `docker-compose logs --help` to learn more. 

Some containers log or stream to multiple destinations.

No container will keep persistent logs in it. Containers are transient items!

In the end, every line of logs will reach the Docker daemon - unfiltered.

The **default logging driver is "json"**.

### Filtered logs

Some logs are filtered and written to Redis keys but also streamed to a Redis channel.

The Redis channel is used to stream logs with failed authentication attempts to be read by netfilter-mailcow.

The Redis keys are persistent and will keep 10000 lines of logs for the web UI.

This mechanism makes it possible to use whatever Docker logging driver you want to, without losing 
the ability to read logs from the UI or ban suspicious clients with netfilter-mailcow.

Redis keys will only hold logs from applications and filter out system messages (think of cron etc.).

### Logging drivers

#### Via docker-compose.override.yml

Here is the good news: Since Docker has some great logging drivers, you can integrate mailcow: dockerized into your existing logging environment with ease.

Create a `docker-compose.override.yml` and add, for example, this block to use the "gelf" logging plugin for `postfix-mailcow`:

```
version: '2.1'
services:
  postfix-mailcow: # or any other
    logging:
      driver: "gelf"
      options:
        gelf-address: "udp://graylog:12201"  
```

Another example for **Syslog**:

```
version: '2.1'
services:

  postfix-mailcow: # or any other
    logging:
      driver: "syslog"
      options:
        syslog-address: "udp://127.0.0.1:514"
        syslog-facility: "local3"

  dovecot-mailcow: # or any other
    logging:
      driver: "syslog"
      options:
        syslog-address: "udp://127.0.0.1:514"
        syslog-facility: "local3"

  rspamd-mailcow: # or any other
    logging:
      driver: "syslog"
      options:
        syslog-address: "udp://127.0.0.1:514"
        syslog-facility: "local3"

# For Rsyslog only:
# To move local3 input to /var/log/mailcow.log and stop processing, create a file "/etc/rsyslog.d/docker.conf":

local3.*        /var/log/mailcow.logs
& ~

# Restart rsyslog afterwards.

```

#### via daemon.json (globally)

If you want to **change the logging driver globally**, edit Dockers daemon configuration file `/etc/docker/daemon.json` and restart the Docker service:

```
{
...
  "log-driver": "gelf",
  "log-opts": {
    "gelf-address": "udp://graylog:12201"
  }
...
}
```

For Syslog:

```
{
...
  "log-driver": "syslog",
  "log-opts": {
    "syslog-address": "udp://1.2.3.4:514"
  }
...
}
```

Restart the Docker daemon and run `docker-compose down && docker-compose up -d` to recreate the containers with the new logging driver.
