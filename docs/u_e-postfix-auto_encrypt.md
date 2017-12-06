To automatically encrypt all emails incoming or outgoing, you will need to perform a couple of simple steps. Zeyple is used to achieve this, and it will automatically encrypt any emails that are destined to addresses it has the public GPG keys for. Therefore, this will only encrypt emails for addresses that you specifically want it to (based on keys you import).

The first step to get this working is to edit your `data/conf/postfix/main.cf` file, and uncomment line 94 so that it looks like:

```
content_filter=zeyple
```

After this is done, reload the postfix container, or simple restart all containers with `docker-compose down; docker-compose up -d`.

The next step is to attach to the postfix container and import any keys you want:

```
docker-compose exec postfix-mailcow /bin/bash
sudo -u zeyple gpg --homedir /var/lib/zeyple/keys --keyserver hkp://keys.gnupg.net --search user@email.com
# The above line executes the GPG command as the zeyple user (which is necessary), specifies a home directory which lives in persistent storage, then searches for a key.
curl https://domain.com/key.asc | sudo -u zeyple gpg --homedir /var/lib/zeyple/keys --import
# The above command shows you how you can pipe input to import a key as well
```

After this, all mail destined to user@email.com (which can be a user on your server, or externally) will be automatically encrypted.

If you have any trouble, ensure there are appropriate permissions on the GPG homedir:

```
docker-compose exec postfix-mailcow /bin/bash
chmod 700 /var/lib/zeyple/keys
chown zeyple: /var/lib/zeyple/keys
```

!!! warning
    When sending mail, any sent emails are kept unencrypted in the "Sent" box by default - this includes mail sent between internal users. Change your options if this is a concern.

!!! warning
    When using DKIM, and sending to an external mail service that you are encrypting to that expects your mail signed, the remote service may reject or junk your email. This is due to the DKIM signature being done by a "milter" (pre-queue), whilst Zeyple encryption is done post-queue as a content filter. The encryption will break the DKIM signature as your message contents has been changed since the message was signed (so DKIM signature won't match the content). SpamAssassin scores gain 0.1 points for being DKIM signed, -1 for being an encrypted message, and 0.001 for having an invalid DKIM signature.
