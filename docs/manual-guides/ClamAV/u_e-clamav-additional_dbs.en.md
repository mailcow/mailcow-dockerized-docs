## Additional Databases for ClamAV

Default ClamAV databases has not great detection level, but it could be enhanced with free or paid signature databases.

### List of known free databases | As of April 2022

- [SecurityInfo](https://www.securiteinfo.com/) - free ClamAV DBs for testing purposes, required registration after which you can use them from 1 IP
- [InterServer](http://rbluri.interserver.net/) - free to use ClamAV DBs, but they do not fit well for email scanning

### Enable SecuriteInfo databases

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
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/spam_marketing.ndb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfohtml.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfoascii.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfopdf.hdb
```

8. Adjust `data/conf/clamav/clamd.conf` to align with next settings:
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
9. Restart ClamAV container:
```bash
docker-compose restart clamd-mailcow
```

Please note:

- You can't use `ExcludePUA` and `IncludePUA` in `clamd.conf` simultaneously, so please comment any `IncludePUA` if you uncommented them before. 
- List of databases provided in this example fit most use-cases, but SecuriteInfo also provides other databases. Please check SecuriteInfo FAQ for additional information.
- With the current DB set (including default DBs) ClamAV will consume about 1.3Gb of RAM on your server.
- If you modified  `message_size_limit` in Postfix you need to adapt `MaxSize` settings in ClamAV as well.

### Enable InterServer databases

1. Add to `data/conf/clamav/freshclam.conf`:
```
DatabaseCustomURL http://sigs.interserver.net/interserver256.hdb
DatabaseCustomURL http://sigs.interserver.net/interservertopline.db
DatabaseCustomURL http://sigs.interserver.net/shell.ldb
DatabaseCustomURL http://sigs.interserver.net/whitelist.fp
```
2. Restart ClamAV container:
```bash
docker-compose restart clamd-mailcow
```
