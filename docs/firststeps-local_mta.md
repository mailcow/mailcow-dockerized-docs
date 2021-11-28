The easiest option would be to disable the listener on port 25/tcp.

**Postfix** users disable the listener by commenting the following line (starting with `smtp` or `25`) in `/etc/postfix/master.cf`:
```
#smtp      inet  n       -       -       -       -       smtpd
```

Furthermore, to relay over a dockerized mailcow, you may want to add `172.22.1.1` as relayhost and remove the Docker interface from "inet_interfaces":

```
postconf -e 'relayhost = 172.22.1.1'
postconf -e "mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
postconf -e "inet_interfaces = loopback-only"
postconf -e "relay_transport = relay"
postconf -e "default_transport = smtp"
```

**Now it is important** to not have the same FQDN in `myhostname` as you use for your dockerized mailcow. Check your local (non-Docker) Postfix' main.cf for `myhostname` and set it to something different, for example `local.my.fqdn.tld`.

"172.22.1.1" is the mailcow created network gateway in Docker.
Relaying over this interface is necessary (instead of - for example - relaying directly over ${MAILCOW_HOSTNAME}) to relay over a known internal network.

Edit the Aliases File to point the (root)User to an exsisting Emailadress. 

```
sudo nano /etc/aliases
```
Go to the End of this File and add an Emailadress for the Root User
```
root:myemail@domain.tld
```
Save the Settings. 
```
sudo newaliases
```

Then we need to set the authentication credentials required 
to convince your mail server that you are you!

```
sudo nano /etc/postfix/relay_password
```
add this line and save the file
```
smtp.example.org smtp@example.org:SomeObscurePassw0rd
```

Apply the changes
```
sudo postmap /etc/postfix/relay_password
```

Now finally open /etc/postfix/main.cf and add the following to the end of the file. 

```
# added to configure accessing the relay host via authenticating SMTP
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/relay_password
smtp_sasl_security_options =
smtp_tls_security_level = encrypt
```

Restart Postfix after applying your changes.
