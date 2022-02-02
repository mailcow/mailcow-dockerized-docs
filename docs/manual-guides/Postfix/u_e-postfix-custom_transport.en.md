For transport maps other than those to be configured in mailcow UI, please use `data/conf/postfix/custom_transport.pcre` to prevent existing maps or settings from being overwritten by updates.

In most cases using this file is **not** necessary. Please make sure mailcow UI is not able to route your desired traffic properly before using that file.

The file needs valid PCRE content and can break Postfix, if configured incorrectly.