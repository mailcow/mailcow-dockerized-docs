Per default mailcow considers all networks as untrusted, except for its own IPV4_NETWORK and IPV6_NETWORK scope. Though it is reasonable in most cases, you may want to loosen this restriction under certain circumstances to allow connections from other networks.

To change this behaviour override the default value of `mynetworks` parameter through the `data/conf/postfix/extra.cf` configuration file.

**Important**: Do **not** remove the networks listed as `IPV4_NETWORK` and `IPV6_NETWORK` in your mailcow.conf. You should also keep local addresses. To add `1.2.3.4/32` it may look like the configuration below:

```
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 [fe80::]/10 172.22.1.0/24 [fd4d:6169:6c63:6f77::]/64 1.2.3.4/32
```

Per default we use "mynetworks_style = subnet" to only include local networks we are part of.
