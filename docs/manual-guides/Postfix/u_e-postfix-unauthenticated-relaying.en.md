By default, mailcow's postfix considers **all networks untrusted** except its own IPV4_NETWORK and IPV6_NETWORK ranges, which are specified in `mailcow.conf`. Although this is reasonable in most cases, there may be circumstances where you want to add a host or subnet as an **unauthenticated relayer**.

By default, mailcow uses `mynetworks_style = subnet` to specify internal subnets and leaves `mynetworks` unconfigured.

If you decide to set `mynetworks` independently in Postfix's `extra.conf`, Postfix will ignore the mynetworks_style setting. This means that you will have to add the IPv4 and IPv6 addresses used internally by mailcow (specified in `mailcow.conf` as IPV4_NETWORK and IPV6_NETWORK respectively), as well as the loopback subnets manually!

!!! abstract "Explaination"
    The setting `mynetworks` allows registered hosts or subnets to send e-mails to the Postfix MTA **WITHOUT** authentication. This is especially useful if monitoring e-mails are to be sent from Linux servers in the same network without extra authentication.

!!! danger
    A wrong setting of `mynetworks` allows your server to be used as an open relay. If this is abused, it will **impair** your ability to send email and it may take some time for this to subside.

!!! example
    As an example, let's take the subnet `192.168.2.0/24`, which we want to relay unauthenticated.

Edit `data/conf/postfix/extra.cf`:

```
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 [fe80::]/10 172.22.1.0/24 [fd4d:6169:6c63:6f77::]/64 192.168.2.0/24
```

!!! warning
    The subnets before our attached example subnet **MUST** exists before or after your entered values. Otherwise some mailcow components such as Watchdog or some Sieve Filters (such as Absence Agents) will not work and errors will occur during operation.

Run the following command to apply your new settings:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow
    ```

!!! tip "Good to know!"
    IPv6 addresses **MUST** be entered with `[]` (square brackets) as `mynetworks` parameters in this case. Otherwise they cannot be processed.

!!! Info
    More information about mynetworks can be found in the [Postfix documentation](http://www.postfix.org/postconf.5.html#mynetworks).