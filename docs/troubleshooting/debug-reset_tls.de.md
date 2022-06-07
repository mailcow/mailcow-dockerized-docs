Sollten Sie Probleme mit Ihrem Zertifikat, Schlüssel oder Let's Encrypt-Konto haben, versuchen Sie bitte, die TLS-Assets zurückzusetzen:

```
source mailcow.conf
docker compose down
rm -rf data/assets/ssl
mkdir data/assets/ssl
openssl req -x509 -newkey rsa:4096 -keyout data/assets/ssl-example/key.pem -out data/assets/ssl-example/cert.pem -days 365 -subj "/C=DE/ST=NRW/L=Willich/O=mailcow/OU=mailcow/CN=${MAILCOW_HOSTNAME}" -sha256 -nodes
cp -n -d data/assets/ssl-example/*.pem data/assets/ssl/
docker compose up -d
```

Dies wird mailcow stoppen, die benötigten Variablen beschaffen, ein selbstsigniertes Zertifikat erstellen und mailcow starten.

Wenn Sie Let's Encrypt verwenden, sollten Sie vorsichtig sein, da Sie ein neues Konto und einen neuen Satz von Zertifikaten erstellen werden. Sie werden früher oder später auf ein Ratelimit stoßen.

Bitte beachten Sie auch, dass frühere TLSA-Datensätze ungültig werden.