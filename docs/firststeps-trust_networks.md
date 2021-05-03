## Default Unauthenticated Relaying
By default mailcow considers all networks as untrusted, excluding its own IPV4_NETWORK and IPV6_NETWORK scopes. Though it is reasonable in most cases, there may be circumstances that you need to loosen this restriction 
As default we use "mynetworks_style = subnet".

## Permitting unauthenticated relaying.

!!! Warning
Incorrect setup of mynetworks will allow your server to be used as an open relay to send unsolicitated bulk email. This **will** affect your ability to send emails to other mail servers, and can take some time to be reversed. If you don't know what this is for, than you do not need it.

!!! Note  Do **not** remove the networks listed as `IPV4_NETWORK` and `IPV6_NETWORK` from your mailcow.conf, or the loopback ranges 127.0.0.0/8, [::ffff:127.0.0.0]/104, and [::1]. 

To change the my behaviour override the default value of `mynetworks` parameter through the `data/conf/postfix/extra.cf` configuration file.

### Permitting IPV4 hosts
To add `192.168.2.0/24` it may look like the configuration below:

``` data/conf/postfix/extra.cf
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 [fe80::]/10 172.22.1.0/24 [fd4d:6169:6c63:6f77::]/64 192.0.2.0/24
```

### Permitting IPv6 hosts

The addition of IPv6 hosts is done the same as IPv4, however the subnet needs to be placed between [ ] with the netmask appearing after it. To add 2001:db8::/32 to be allowed to relay we would use the following configuration:

``` data/conf/postfix/extra.cf
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 [fe80::]/10 172.22.1.0/24 [fd4d:6169:6c63:6f77::]/64 [2001:DB8::]/32
```

!!! Info
Further Information on Postfix's mynetwork can be located [here](http://www.postfix.org/postconf.5.html#mynetworks "Postfix's mynetworks")
