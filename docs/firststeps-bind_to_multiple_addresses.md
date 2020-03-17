By default mailcow listens on all addresses, this can be problematic if you have multiple IPs on the host and you are running services already on same ports mailcow uses.

This example will show how to bind services to 1 IPv4 address and 1 IPv6 address. Though this could be expanded to as many addresses as you want.

A `docker-compose.override.yml` file will be used instead of editing the `docker-compose.yml` file directly. This is to maintain updatability, as the `docker-compose.yml` file gets update regularly and your changes will be overwritten.

For this example the host will have the following addresses
`fd:0:0:0:0:0:0:1`
`fd:0:0:0:0:0:0:2`
`192.168.1.1`
`192.168.1.2`

##Changing Bindings In mailcow.conf
Say we wanted to bind all the services to `192.168.1.2` and `fd:0:0:0:0:0:0:2`. To do this we need to bind the following to a specific IP address in the `mailcow.conf`

    HTTP_PORT=80
    HTTP_BIND=192.168.1.2

    HTTPS_PORT=443
    HTTPS_BIND=192.168.1.2

    SMTP_PORT=192.168.1.2:25
    SMTPS_PORT=192.168.1.2:465
    SUBMISSION_PORT=192.168.1.2:587
    IMAP_PORT=192.168.1.2:143
    IMAPS_PORT=192.168.1.2:993
    POP_PORT=192.168.1.2:110
    POPS_PORT=192.168.1.2:995
    SIEVE_PORT=192.168.1.2:4190
    DOVEADM_PORT=192.168.1.2:19991


##Overriding docker-compose.yml
Then we need to create `docker-compose.override.yml` with the following. This extends the configuration already defined in `docker-compose.yml`

    version: '2.1'
    services:

        dovecot-mailcow:
          ports:
            - 'fd:0:0:0:0:0:0:2:143:143'
            - 'fd:0:0:0:0:0:0:2:993:993'
            - 'fd:0:0:0:0:0:0:2:110:110'
            - 'fd:0:0:0:0:0:0:2:995:995'
            - 'fd:0:0:0:0:0:0:2:4190:4190'

        postfix-mailcow:
          ports:
            - 'fd:0:0:0:0:0:0:2:25:25'
            - 'fd:0:0:0:0:0:0:2:465:465'
            - 'fd:0:0:0:0:0:0:2:587:587'

       nginx-mailcow:
          ports:
           - 'fd:0:0:0:0:0:0:2:80:80'
           - 'fd:0:0:0:0:0:0:2:443:443'



## Restart Mailcow#

!!! warning
    mailcow will fail to start or not start completely if you mess up the address bindings

To restart mailcow run the following
```
docker-compose stop
docker-compose up -d
```