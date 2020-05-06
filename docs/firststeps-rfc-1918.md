Per default, mailcow considers all private RFC1918 networks (i.e. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) as trusted. Though it is reasonable in most cases, you may want to restrict this setting under certain circumstances. In particular, if you are using some kind of reverse proxy for SMTP TCP ports. If your reverse proxy host is located in a private net, mailcow will consider all traffic from it as trusted, which may result in an open relay. 

To change this behaviour override the default value of `mynetworks` parameter through the `data/conf/postfix/extra.cf` configuration file.

**Important**: Do **not** remove the networks listed as `IPV4_NETWORK` and `IPV6_NETWORK` in your mailcow.conf. You should also keep local addresses.

The default values for those variables - `172.22.1.0/24` and `fd4d:6169:6c63:6f77::/64` - would result in the following, minimal configuration:

```
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 [fe80::]/10 172.22.1.0/24 [fd4d:6169:6c63:6f77::]/64
```
