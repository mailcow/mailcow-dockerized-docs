In case you encounter problems with your certificate, key or Let's Encrypt account, please try to reset the TLS assets:

```
source mailcow.conf
docker-compose down
rm -rf data/assets/ssl
mkdir data/assets/ssl
openssl req -x509 -newkey rsa:4096 -keyout data/assets/ssl-example/key.pem -out data/assets/ssl-example/cert.pem -days 365 -subj "/C=DE/ST=NRW/L=Willich/O=mailcow/OU=mailcow/CN=${MAILCOW_HOSTNAME}" -sha256 -nodes
cp -n -d data/assets/ssl-example/*.pem data/assets/ssl/
docker-compose up -d
```

This will stop mailcow, source the variables we need, create a self-signed certificate and start mailcow.

If you use Let's Encrypt you should be careful as you will create a new account and a new set of certificates. You will run into a ratelimit sooner or later.

Please also note that previous TLSA records will be invalid.
