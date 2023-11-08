Laden Sie das Modul herunter und speichern Sie es in folgenden Pfad ab: `data/conf/rspamd/plugins.d/`.

Danach müssen Sie die Konfigurationsparameter des Modules in `data/conf/rspamd/rspamd.conf.local` hinzufügen.
Falls das Modul `my_plugin.lua` heißt, sollte die Datei wie folgt aussehen:

```
# rspamd.conf.local
my_plugin {
    some_setting = "some value";
}
```

Falls Ihr Modul keine zusätzlichen Konfigurationen benötigt, reicht es aus einen leeren Konfigurationsblock hinzuzufügen. Wie im folgenden Beispiel zu sehen:

```
# rspamd.conf.local
my_plugin { }
```

Falls Sie keinen Konfigurationsblock hinzufügen, dann wird das Modul automatisch deaktiviert und im Logfile des rspamd-mailcow Containers sehen Sie folgende Nachricht:

```
mailcowdockerized-rspamd-mailcow-1  | 2023-05-20 14:01:32 #1(main) <sh6j9z>; cfg; rspamd_config_is_module_enabled: lua module my_plugin is enabled but has not been configured
mailcowdockerized-rspamd-mailcow-1  | 2023-05-20 14:01:32 #1(main) <sh6j9z>; cfg; rspamd_config_is_module_enabled: my_plugin disabling unconfigured lua module
```

Falls Sie das Modul erfolgreich konfiguiert haben, dann sollte das Logfile des rspamd-mailcow Containers wie folgt aussehen:

```
mailcowdockerized-rspamd-mailcow-1  | 2023-05-20 14:04:50 #1(main) <8ayxpf>; cfg; rspamd_init_lua_filters: init lua module my_plugin from /etc/rspamd/plugins.d//my_plugin.lua; digest: 5cb88961e5
```