By default mailcow considers **all networks as untrusted** excluding its own IPV4_NETWORK and IPV6_NETWORK scopes. Though it is reasonable in most cases, there may be circumstances that you need to loosen this restriction.

By default mailcow uses `mynetworks_style = subnet` to determine internal subnets and leaves `mynetworks` unconfigured.

If you decide to set `mynetworks`, Postfix ignores the mynetworks_style setting. This means you **have to** add the IPV4_NETWORK and IPV6_NETWORK scopes as well as loopback subnets manually!

## Unauthenticated relaying

!!! Warning
    Incorrect setup of `mynetworks` will allow your server to be used as an open relay. If abused, this **will** affect your ability to send emails and can take some time to be resolved.

### IPv4 hosts/subnets

To add the subnet `192.168.2.0/24` to the trusted networks you may use the following configuration, depending on your IPV4_NETWORK and IPV6_NETWORK scopes:

Edit `data/conf/postfix/extra.cf`:

```
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 [fe80::]/10 172.22.1.0/24 [fd4d:6169:6c63:6f77::]/64 192.168.2.0/24
```

Run `docker-compose restart postfix-mailcow` to apply your new settings.

### IPv6 hosts/subnets

Adding IPv6 hosts is done the same as IPv4, however the subnet needs to be placed in brackets `[]` with the netmask appended.

To add the subnet 2001:db8::/32 to the trusted networks you may use the following configuration, depending on your IPV4_NETWORK and IPV6_NETWORK scopes:

Edit `data/conf/postfix/extra.cf`:

``` 
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 [fe80::]/10 172.22.1.0/24 [fd4d:6169:6c63:6f77::]/64 [2001:db8::]/32
```

Run `docker-compose restart postfix-mailcow` to apply your new settings.

!!! Info
    More information about mynetworks can be found in the [Postfix documentation](http://www.postfix.org/postconf.5.html#mynetworks).
