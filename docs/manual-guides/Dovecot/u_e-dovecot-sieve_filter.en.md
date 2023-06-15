Here is just an example of Sieve rule.

on your /mailbox, Tab "Filters".

You can create "Add filter" and Select domain.tld and Prefilter.

## Rule Example for matches To and redirect mail, mark as read and move mail on subfolder

```
require "fileinto";
require "mailbox";
require "variables";
require "subaddress";
require "envelope";
require "duplicate";
require "imap4flags";

if header :matches "To" "*mail@domain.tld*" {
   redirect "anothermail@anotherdomain.tld";
   setflag "\\seen"; /* Mark mail as read */
   fileInto "INBOX/SubFolder"; /* Move mail on subfolder after */
} else {
  # The rest goes into INBOX
  # default is "implicit keep", we do it explicitly here
  keep;
}
```
Keep Warning about From/To : if on source of your mail, you see firstname name <mail@domain.tld> : Your "if header" need to match all data
If you use ":is" to replace ":matches", you need to set the exact patern.

[Examples rules Sieve](https://doc.dovecot.org/configuration_manual/sieve/examples/)
[IETF : Draft with examples](https://datatracker.ietf.org/doc/html/draft-happel-sieve-filter-rule-metadata-00)
