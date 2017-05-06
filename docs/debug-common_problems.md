Here we list common problems and possible solutions:

## Mail loops back to myself

Please check in your mailcow UI if you made the domain a **backup MX**:

![Check your MX Backup settings](images/mailcow-backupmx.png)

## I can receive but not send mails

There are a lot of things that could prevent you from sending mail:

- Check if your IP is on any blacklists. You could use [dnsbl.info](http://www.dnsbl.info/) or any other similar service to check for your IP.
- There are some consumer ISP routers out there, that block mailports for non whitelisted domains. Please check if you can reach your server on the ports `465` or `587`:

```
# telnet 74.125.133.27 465
Trying 74.125.133.27...
Connected to 74.125.133.27.
Escape character is '^]'.
```

## My mails are identified as Spam

Please read our guide on [DNS configuration](prerequesite-dns.md).

## docker-compose throws weird erros

... like:

- `ERROR: Invalid interpolation format ...`
- `AttributeError: 'NoneType' object has no attribute 'keys'`.
- `ERROR: In file './docker-compose.yml' service 'version' doesn't have any configuration options`.

When you encounter one or similar messages while trying to run mailcow: dockerized please check if you have the **latest** version of **Docker** and **docker-compose**

## Container XY is unhealthy

This error tries to tell you that one of the (health) conditions for a certain container are not met. Therefore it can't be started. This can have several reasons, the most common one is an updated git clone but old docker image or vice versa.

A wrong configured firewall could also cause such a failure. The containers need to be able to talk to each other over the network 172.22.1.1/24.

It might also be wrongly linked file (i.e. SSL certificate) that prevents a crucial container (nginx) from starting, so always check your logs to get an Idea where your problem is coming from.


## Address already in use

If you get an error message like:

```
ERROR: for postfix-mailcow  Cannot start service postfix-mailcow: driver failed programming external     connectivity on endpoint mailcowdockerized_postfix-mailcow_1: Error starting userland proxy: listen tcp 0.0.0.0:25: bind: address already in use
```

while trying to start / install mailcow: dockerized, make sure you've followed our section on the [prerequisites](prerequesite-system/#firewall-ports).
