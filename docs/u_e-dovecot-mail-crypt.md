Mails are stored encrypted, the key pair can be found in crypt-vol-1.

If you want to decode/encode existing maildir files, you can use the following script at your own risk:

Enter Dovecot by running `docker-compose exec dovecot-mailcow /bin/bash` in the mailcow-dockerized location.

```
# Decrypt /var/vmail
find /var/vmail/ -type f -regextype egrep -regex '.*S=.*W=.*' | while read -r file; do
if [[ $(head -c7 "$file") == "CRYPTED" ]]; then
doveadm fs get crypt private_key_path=/mail_crypt/ecprivkey.pem:public_key_path=/mail_crypt/ecpubkey.pem:posix:prefix=/ \
  "$file" > "/tmp/$(basename "$file")"
  chmod 600 "/tmp/$(basename "$file")"
  chown 5000:5000 "/tmp/$(basename "$file")"
  mv "/tmp/$(basename "$file")" "$file"
fi
done

# Encrypt /var/vmail
find /var/vmail/ -type f -regextype egrep -regex '.*S=.*W=.*' | while read -r file; do
if [[ $(head -c7 "$file") != "CRYPTED" ]]; then
doveadm fs put crypt private_key_path=/mail_crypt/ecprivkey.pem:public_key_path=/mail_crypt/ecpubkey.pem:posix:prefix=/ \
  "$file" "$file"
  chmod 600 "$file"
  chown 5000:5000 "$file"
fi
done
```
