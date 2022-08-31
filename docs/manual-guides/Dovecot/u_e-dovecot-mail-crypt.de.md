!!! warning "Achtung"
	Die Mails werden komprimiert (lz4) und verschlüsselt gespeichert. Das Schlüsselpaar ist in crypt-vol-1 zu finden.

Wenn Sie vorhandene maildir-Dateien entschlüsseln/verschlüsseln wollen, können Sie das folgende Skript auf eigene Gefahr verwenden:

Rufen Sie Dovecot auf, indem Sie `docker compose exec dovecot-mailcow /bin/bash` im mailcow-dockerisierten Verzeichnis ausführen.

```
# Entschlüsseln Sie /var/vmail
find /var/vmail/ -type f -regextype egrep -regex '.*S=.*W=.*' | while read -r file; do
if [[ $(head -c7 "$file") == "CRYPTED" ]]; then
doveadm fs get compress lz4:0:crypt:private_key_path=/mail_crypt/ecprivkey.pem:public_key_path=/mail_crypt/ecpubkey.pem:posix:prefix=/ \
  "$file" > "/tmp/$(basename "$file")"
  if [[ -s "/tmp/$(basename "$file")" ]]; then
    chmod 600 "/tmp/$(basename "$file")"
    chown 5000:5000 "/tmp/$(basename "$file")"
    mv "/tmp/$(basename "$file")" "$file"
  else
    rm "/tmp/$(basename "$file")"
  fi
fi
done


# Verschlüsseln von /var/vmail
find /var/vmail/ -type f -regextype egrep -regex '.*S=.*W=.*' | while read -r file; do
if [[ $(head -c7 "$file") != "CRYPTED" ]]; then
doveadm fs put crypt private_key_path=/mail_crypt/ecprivkey.pem:public_key_path=/mail_crypt/ecpubkey.pem:posix:prefix=/ \
  "$file" "$file"
  chmod 600 "$file"
  chown 5000:5000 "$file"
fi
done
```
