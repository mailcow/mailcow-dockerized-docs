## FAQ

Please find the most frequently asked questions with their corresponding configuration in `data/conf/ejabberd/ejabberd.yml` (if any).

- **I do not want to run ejabberd, is there a `SKIP_XMPP` variable?**

No, there is not. But you don't need one either.

The xmppd behaves the same way as SOGo or Solr do when disabled. A shell will be idling and ejabberd will **not** be started.

As soon as a domain is enabled for XMPP, the container will be restarted and ejabberd bootstrapped.

ejabberd is **very** light on resources, you may want to give it a try.

- **Are messages stored on the server?**

Not by default. The default setting is to disable the message archive via mod_mam but allow users to enable the function if they want to:

```
  mod_mam:
    clear_archive_on_room_destroy: true
    default: never
    compress_xml: true
    request_activates_archiving: true
```

- **Are uploaded files stored on the server?**

Yes, uploaded files are stored in the volume `xmpp-uploads-vol-1`.

The retention policy saves them for 30 days:

```
  mod_http_upload_quota:
    max_days: 30
```

- **Are messages stored when a JID is offline?**

Yes, up to 1000 messages are stored for "normal" users and administrators:

```
shaper_rules:
  max_user_offline_messages:
    1000: admin
    1000: all
```

- **Are messages written in group chats stored?**

No, messages are not stored:

```
  mod_muc:
    default_room_options:
      mam: false
```

- **Are group chats persistent when the last participant leaves?**

No, they will vanish:

```
  mod_muc:
    default_room_options:
      persistent: false
```

- **How many client sessions can be open at the same time?**

10 sessions are allowed per session.

```
shaper_rules:
  max_user_sessions: 10
```
