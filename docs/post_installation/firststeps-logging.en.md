Logging in mailcow: dockerized consists of multiple stages, but is, after all, much more flexible and easier to integrate into a logging daemon than before.

In Docker the containerized application (PID 1) writes its output to stdout. For real one-application containers this works just fine.
Run the command below to learn more:

=== "docker compose (Plugin)"

    ``` bash
    docker compose logs --help
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose logs --help
    ```

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
services:
  postfix-mailcow: # or any other
    logging:
      driver: "gelf"
      options:
        gelf-address: "udp://graylog:12201"
```

Another example for **Syslog**:

```
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
```

##### For Rsyslog only:
 
Make sure the following lines aren't commented out in `/etc/rsyslog.conf`:

```
# provides UDP syslog reception
module(load="imudp")
input(type="imudp" port="514")
```

To move `local3` input to `/var/log/mailcow.log` and stop processing, create a file `/etc/rsyslog.d/docker.conf`:

```
local3.*        /var/log/mailcow.log
& stop
```

Restart rsyslog afterwards.

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

Restart the Docker daemon and run the commands below to recreate the containers with the new logging driver:

=== "docker compose (Plugin)"

    ``` bash
    docker compose down
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose down
    docker-compose up -d
    ```

### Log rotation

As those logs can get quite big, it is a good idea to use logrotate to compress and delete them after a certain time period.

Create `/etc/logrotate.d/mailcow` with the following content:

```
/var/log/mailcow.log {
        rotate 7
        daily
        compress
        delaycompress
        missingok
        notifempty
        create 660 root root
        copytruncate
#        postrotate
#                systemctl restart rsyslog
#                docker compose -f /opt/mailcow-dockerized/docker-compose.yml restart postfix-mailcow
#        endscript
}
```

With this configuration, logrotate will run daily and keep a maximum of 7 archives. As the log file is permanently occupied by the Docker daemon, `copytruncate` ensures that the current content of `mailcow.log` is being copied to the new rotated file and the file is being truncated afterwards. This is necessary as otherwise the logs will continue to be written to the old (already rotated) file.

As an alternative to `copytruncate`, the `postrotate` snippet which is commented out by default, can be used. To do this, comment the `copytruncate` and uncomment the lines below. After rotating the log files, the rsyslog daemon ([source](https://www.cloudinsidr.com/content/set-up-logrotate-for-postfix/)) and the Docker container with postfix-mailcow are being restarted. The last two steps are necessary as otherwise the logs will continue to be written to the old (already rotated) file. If a logging driver other than syslog is used for logging, the command (`systemctl restart rsyslog`) must be modified accordingly or the line must be removed from the example above.

To rotate the logfile weekly or monthly replace `daily` with `weekly` or `monthly` respectively.

To keep more archives, set the desired number of `rotate`.

Afterwards, logrotate can be restarted.
