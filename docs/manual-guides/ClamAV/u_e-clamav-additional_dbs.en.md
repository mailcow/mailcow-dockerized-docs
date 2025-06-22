## Additional Databases for ClamAV

Default ClamAV databases do not have great detection levels, but it can be enhanced with free or paid signature databases.

### List of known free databases | As of April 2022

- [SecurityInfo](https://www.securiteinfo.com/) - free ClamAV DBs for testing purposes, required registration after which you can use them from 1 IP
- [InterServer](http://rbluri.interserver.net/) - free to use ClamAV DBs, but they do not fit well for email scanning

### Enable SecuriteInfo databases

#### Work todo in ClamAV

1. Sign up for a free account at https://www.securiteinfo.com/clients/customers/signup
2. You will receive an email to activate your account and then a follow-up email with your login name
3. Login and navigate to your customer account: https://www.securiteinfo.com/clients/customers/account
4. Click on the Setup tab
5. You will need to get `your_id` from one of the download links, they are individual for every user
7. Add to `data/conf/clamav/freshclam.conf` with replaced `your_id` part:
```
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.ign2
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/javascript.ndb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfohtml.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfoascii.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfoandroid.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfoold.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfopdf.hdb
# Paid databases
# DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo0hour.hdb
# DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.mdb
# DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.yara
# DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.pdb
# DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.wdb
```

!!! danger "Attention"
    SecuriteInfo spam_marketing.ndb database is known to have significant false positive rules, add on your own risk!

8. For free SecuriteInfo databases, download speed is limited to 300 kB/s. In `data/conf/clamav/freshclam.conf`, increase the default `ReceiveTimeout 20` value to `ReceiveTimeout 90` (time in seconds), otherwise some of the database downloads could fail because of their size.

9. Adjust `data/conf/clamav/clamd.conf` to align with next settings:
```
DetectPUA yes
ExcludePUA PUA.Win.Packer
ExcludePUA PUA.Win.Trojan.Packed
ExcludePUA PUA.Win.Trojan.Molebox
ExcludePUA PUA.Win.Packer.Upx
ExcludePUA PUA.Doc.Packed
MaxScanSize 150M
MaxFileSize 100M
MaxRecursion 40
MaxEmbeddedPE 100M
MaxHTMLNormalize 50M
MaxScriptNormalize 50M
MaxZipTypeRcg 50M
```
10. Restart ClamAV container:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart clamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart clamd-mailcow
    ```

Please note:

- You can't use `ExcludePUA` and `IncludePUA` in `clamd.conf` simultaneously, so please comment any `IncludePUA` if you uncommented them before.
- List of databases provided in this example fit most use-cases, but SecuriteInfo also provides other databases. Please check SecuriteInfo FAQ for additional information.
- With the current DB set (including default DBs) ClamAV will consume about 1.3Gb of RAM on your server.
- If you modified  `message_size_limit` in Postfix you need to adapt `MaxSize` settings in ClamAV as well.

#### Work todo in Rspamd

!!! danger
    mailcow with Version **`>= 2023-07`** is needed for this following guide to work, as it includes the predefined scores for SecuriteInfo Signatures!

Now you have added the ClamAV signatures, but you will notice that Rspamd does not use them correctly or mercilessly labels EVERYTHING as VIRUS.

However, we can tame Rspamd with a little bit of manual work so that it doesn't get completely out of hand.

For this we proceed as follows:

1. Add the following inside the existing `clamav { ... }` block in `data/conf/rspamd/local.d/antivirus.conf`:

```
patterns {
  # Extra Signatures (Securite) Not shipped with mailcow.
  CLAM_SECI_SPAM = "^SecuriteInfo\.com\.Spam.*";
  CLAM_SECI_JPG = "^SecuriteInfo\.com\.JPG.*";
  CLAM_SECI_PDF = "^SecuriteInfo\.com\.PDF.*";
  CLAM_SECI_HTML = "^SecuriteInfo\.com\.HTML.*";
  CLAM_SECI_JS = "^SecuriteInfo\.com\.JS.*";
}
```

2. Restart Rspamd afterwards:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```

Now Rspamd will apply the weighting we specified to each signature instead of marking everything with a value of 2000 as VIRUS and thus rejecting it.


!!! info

    You can change the weights at any time:

    `data/conf/rspamd/local.d/composites.conf`.

    You can also manually set/adjust the strings of the ClamAV to be registered.

    Just use the scheme given in the `antivirus.conf` of Rspamd.

!!! warning
    Please note that the files `antivirus.conf` and `composites.conf` can be overwritten by a mailcow update.

---
### Enable InterServer databases

1. Add to `data/conf/clamav/freshclam.conf`:
```
DatabaseCustomURL http://sigs.interserver.net/interserver256.hdb
DatabaseCustomURL http://sigs.interserver.net/interservertopline.db
DatabaseCustomURL http://sigs.interserver.net/shell.ldb
DatabaseCustomURL http://sigs.interserver.net/whitelist.fp
```
2. Restart ClamAV container:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart clamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart clamd-mailcow
    ```
