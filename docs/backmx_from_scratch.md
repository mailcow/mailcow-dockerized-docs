!!! warning
    Make sure you've read ["Prepare Your System"](https://mailcow.github.io/mailcow-dockerized-docs/prerequisite-system) before proceeding!


You need Docker and Docker Compose.

**1\.** Learn how to install [Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/).

Quick installation for most operation systems:

- Docker
```
curl -sSL https://get.docker.com/ | CHANNEL=stable sh
# After the installation process is finished, 
you may need to enable the service and make sure it is started (e.g. CentOS 7)
systemctl enable docker.service
systemctl start docker.service
```

- Docker-Compose
```
curl -L https://github.com/docker/compose/releases/download/$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

Please use the latest Docker engine available and do not use the engine that ships with your distros repository.

**2\.** Clone the master branch of the repository, make sure your umask equals 0022.
```
umask
# 0022
cd /opt
git clone https://github.com/mailcow/mailcow-dockerized
cd mailcow-dockerized
```

**3\.** Generate a configuration file. Use a FQDN (`host.domain.tld`) as hostname when asked.
```
./generate_config.sh
```

**4\.** Change configuration if you want or need to.
```
nano mailcow.conf
```
**4\.0\.1\.**
If you plan to use a reverse proxy, you can, for example, 
- bind HTTPS to 127.0.0.1 
-- port 8443
- bind HTTP to 127.0.0.1 
-- port 8080.


**4\.0\.2\.**
You may need to stop an existing pre-installed MTA which blocks port 25/tcp. 
See [this chapter](https://mailcow.github.io/mailcow-dockerized-docs/firststeps-local_mta/) to learn how to reconfigure Postfix to run besides mailcow after a successful installation.

Some updates modify mailcow.conf and add new parameters. It is hard to keep track of them in the documentation. Please check their description and, if unsure, ask at the known channels for advise.

**4\.1\.** Users with a MTU not equal to 1500 (e.g. OpenStack):

**Whenever you run into trouble and strange phenomena, please check your MTU.**

Edit `docker-compose.yml` and change the network settings according to your MTU.
Add the new driver_opts parameter like this:
```
networks:
  mailcow-network:
    ...
    driver_opts:
      com.docker.network.driver.mtu: 1450
    ...
```

**4\.2\.** Users without an IPv6 enabled network on their host system:

**Enable IPv6. Finally.**

If you do not have an IPv6 enabled network on your host and you don't care for a better internet (thehe), it is recommended to [disable IPv6](https://mailcow.github.io/mailcow-dockerized-docs/firststeps-disable_ipv6/) for the mailcow network to prevent unforeseen issues.


**5\.** Pull the images and run the composer file. The parameter `-d` will start mailcow: dockerized detached:
```
docker-compose pull
docker-compose up -d
```

You can now access **https://${MAILCOW_HOSTNAME}** with the default credentials `admin` + password `moohoo`.

The database will be initialized right after a connection to MySQL can be established. - BE PATIENT! IT MAY TAKES UPTO 60 MINUTES

Your data will persist in multiple Docker volumes, that are not deleted when you recreate or delete containers. Run `docker volume ls` to see a list of all volumes. You can safely run `docker-compose down` without removing persistent data.

**6\.** Using and Setup the Mailcow as Backup-MX


**6\.1\.** Change password of user admin, in case you dod not do that (see above for the default login)
**6\.2\.** 
```
Click on
Configuration
-- Mail Setup 
--- Domains
---- Add Domain


Enter the following information:
Domain: yourdomainhere.tld
skip anything till
Backup MX Options:
Check both boxes
Add Domain
-> Repeat until the last domain
-> Remind, it is not possible to use alias domains as Backup-MX option, each domain has to be added manually
-> On the Last Domain, use Add Domain and Restart SOGo
```

**6\.3\.** Add the Secondary host (Backup-MX(BMX)) as Relayhost to the Primary Host (Primary MX(PMX))
```
Login in to your PMX
Goto 
- Configuration
-- Configuration and Details
--- Configuration
---- Forwarding Hosts
----- Enter the BMX as hostname
------ Decide if you want to have the Spam Filter enabled or not.
```

**6\.4\.** Update your DNS Settings on DNS-Server/Hoster
In Short:
MX1=PMX -> MX1 is the Primary Mail Exchanger
MX2=BMX -> MX2 is the Backup Mail Exchanger that we set up now, we need to add a second MX Entries with MX2 as shown below

**6\.4\.1\.** DNS IN A
Add a Secondary IN A entry
```
mx1.yourdomain.tld. 180 IN A 192.168.0.1
mx2.yourdomain.tld. 180 IN A 192.168.0.2
```

**6\.4\.2\.** DNS IN MX
Add a Secondary IN MX entry
```
yourdomain.tld. 180 IN MX 20 mx2.yourdomain.tld.
yourdomain.tld. 180 IN MX 10 mx1.yourdomain.tld.

```
**6\.4\.3\.** DNS IN TXT
We also take care about the SPF record as it would deny the usage of our second server if it is not inside it.
You may need to update it and add your BMX as shown below
```
yourdomain.tld. 180 IN TXT "v=spf1 a mx a:mx1.yourdomain.tld a:mx2.yourdomain.tld ip4:192.168.0.1/32 ip4:192.168.0.2/32 ~all"
```
Howto set up this correctly, you could take a look on
https://dmarcian.com/spf-syntax-table/




**6\.5\.** Time to drink a Coffe... (You have to wait)
It may take some time, that the DNS changes, you did, to take effect (usually some minutes, but it can also take days!)
If this is done, you can check your domains with
```
dig yourdomain.tld MX
```
If its telling 2 Entries (or more, if you set up more as twice) it is fine
as Written above, it should be looking like
```
yourdomain.tld. 180 IN MX 20 mx2.yourdomain.tld.
yourdomain.tld. 180 IN MX 10 mx1.yourdomain.tld.
``

**6\.6\.** Time To Test!


**6\.6\.1.\** PMX "Shutdown"
Bring the PMX down and send a mail


**6\.6\.2\** Check Queue on the BMX
if you got now a mail fine
if not, wait some minutes and check again


**6\.6\.2\** PMX startup
Start your stack again, and be happy ;)


Original by: Unknown
Modified by github.com/djdomi


