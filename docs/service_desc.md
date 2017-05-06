Here is a brief overview of what container / service does what:

| Service Name  | Service Descriptions                                                      |
| --------------- | ------------------------------------------------------------------------- |
| bind9-mailcow   | Local (DNSSEC) DNS Resolver                                               |
| mysql-mailcow   | Stores SOGo's and most of mailcow's settings                                         |
| postfix-mailcow | Receives and sends mails                                                  |
| dovecot-mailcow | User logins and sieve filter                                              |
| redis-mailcow   | Storage backend for DKIM keys, Rmilter and Rspamd                         |
| rspamd-mailcow  | Mail filtering system. Used for av handling, dkim signing, spam handling  |
| rmilter-mailcow | Integrates Rspamd into postfix                                            |
| clamd-mailcow   | Scans attachments for viruses                                             |
| sogo-mailcow    | Webmail client that handles Microsoft ActiveSync and Cal- / CardDav       |
| nginx-mailcow   | Nginx remote proxy that handles all mailcow related HTTP / HTTPS requests |
