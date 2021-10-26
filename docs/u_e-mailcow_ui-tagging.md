Mailbox users can tag their mail address like in `me+facebook@example.org`. They can control the tag handling in the users **mailcow UI** panel.
![mailcow mail tagging settings](images/mailcow-tagging.png)

*Tagging is also known as 'sub-addressing' (RFC 5233) or 'plus addressing'*


### Available Actions

1\. Move this message to a sub folder "facebook" (will be created lower case if not existing)

2\. Prepend the tag to the subject: "[facebook] Subject"

Please note: Uppercase tags are converted to lowercase except for the first letter. If you want to keep the tag as it is, please apply the following diff and restart mailcow:
```
diff --git a/data/conf/dovecot/global_sieve_after b/data/conf/dovecot/global_sieve_after
index e047136e..933c4137 100644
--- a/data/conf/dovecot/global_sieve_after
+++ b/data/conf/dovecot/global_sieve_after
@@ -15,7 +15,7 @@ if allof (
   envelope :detail :matches "to" "*",
   header :contains "X-Moo-Tag" "YES"
   ) {
-  set :lower :upperfirst "tag" "${1}";
+  set "tag" "${1}";
   if mailboxexists "INBOX/${1}" {
     fileinto "INBOX/${1}";
   } else {
```
