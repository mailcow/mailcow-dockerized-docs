SNAT is used to change the source address of the packets sent by mailcow.
It can be used to change the outgoing IP address on systems with multiple IP addresses.

Open `mailcow.conf`, set either or both of the following parameters:

```
# Use this IPv4 for outgoing connections (SNAT)
SNAT_TO_SOURCE=1.2.3.4

# Use this IPv6 for outgoing connections (SNAT)
SNAT6_TO_SOURCE=dead:beef
```

Run `docker-compose up -d`.

The values are read by netfilter-mailcow. netfilter-mailcow will make sure, the post-routing rules are on position 1 in the netfilter table. It does automatically delete and re-create them if they are found on another position than 1.

Check the output of `docker-compose logs --tail=200 netfilter-mailcow` to ensure the SNAT settings have been applied.
