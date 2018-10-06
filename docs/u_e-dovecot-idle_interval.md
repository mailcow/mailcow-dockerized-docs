# Changing the IMAP IDLE interval
## What is the IDLE interval?
Per default, dovecot sends a "I'm still here" notification to every client that has an open connection with dovecot to get mails as quickly as possible without manually polling it (IMAP PUSH). This notification is controlled by the setting [`imap_idle_notify_interval`](https://wiki.dovecot.org/Timeouts), whose default value is 2 minutes. 

The short interval results in the client getting a lot of messages for this connection, which is bad for mobile devices because every time the device receives this message, the mailing app has to wake up and look at it, only to see that it has nothing to do. This can result in unnecessary battery drain.

## Edit the value
### Change configuration
Create a new file `data/conf/dovecot/extra.conf` (or edit it if it already exists).
Insert the setting followed by the new value. For example, to set the interval to 29 minutes you could type:

```
imap_idle_notify_interval = 29 mins
```

I choose 29 minutes because this is the maximum value allowed by the [corresponding RFC](https://tools.ietf.org/html/rfc2177).

!!! warning
	This isn't a default setting in mailcow because we don't know how this setting changes the behavior of other clients. Be careful if you change this and monitor different behavior.

### Reload dovecot
Now reload dovecot:
```
docker-compose exec dovecot-mailcow dovecot reload
```

!!! info
	You can check the value of this setting with 
	```
	docker-compose exec dovecot-mailcow dovecot -a | grep "imap_idle_notify_interval"
	```
	If you didn't change it, it should be at 2m. If you did change it, you should see your new value.



