## maildir_very_dirty_syncs

Dovecot's [`maildir_very_dirty_syncs` option](https://wiki.dovecot.org/MailLocation/Maildir#Optimizations) is enabled by default. This option can significantly improve the performance of mailboxes that contain very large folders (over 100,000 emails).

What this option does is it avoids rescanning the entire `cur` directory whenever loading an email. With this option disabled, Dovecot takes it safe and scans the **entire** `cur` directory (essentially running an `ls`) to check if that particular email was touched (renamed, etc), by looking for all files whose names contain the correct ID. This is very slow if the directory is large, even on filesystems optimized for such use cases (such as ext4 with `dir_index` enabled) on fast SSD drives.

This option is safe to use as long as you do not manually touch files under `cur` (as then Dovecot may not notice the changes). Even with this option enabled, Dovecot will still notice changes if the file's mtime (last modified time) is changed, but otherwise it will not scan the directory and just assumes the index is up-to-date. This is essentially the same as what sdbox/mdbox do, and with this option you can get some of the performance increase that would come with sdbox/mdbox while still using maildir.

This option is safe to use on a standard Mailcow installation. However, if you use any third-party tools that manually modify files directly in the maildir (rather than via IMAP), you may wish to disable it. To disable this option, [create a data/conf/dovecot/extra.conf file](u_e-dovecot-extra_conf.md) and add this setting to it:

```ini
maildir_very_dirty_syncs=no
```
