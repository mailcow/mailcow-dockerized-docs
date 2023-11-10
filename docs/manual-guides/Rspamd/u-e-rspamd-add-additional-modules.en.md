Download the module and save it in the following path: `data/conf/rspamd/plugins.d/`.

Next, add any necessary configuration for your module to `data/conf/rspamd/rspamd.conf.local`. \
If you have a module named `my_plugin.lua`, configuration might look like the following:

```
# rspamd.conf.local
my_plugin {
    some_setting = "some value";
}
```

If your module does not require any additional configuration, simply add an empty configuration block, for example:

```
# rspamd.conf.local
my_plugin { }
```

If you do not add a configuration block, the module will be automatically disabled, and the rspamd-mailcow container log will contain a message such as:

```
mailcowdockerized-rspamd-mailcow-1  | 2023-05-20 14:01:32 #1(main) <sh6j9z>; cfg; rspamd_config_is_module_enabled: lua module my_plugin is enabled but has not been configured
mailcowdockerized-rspamd-mailcow-1  | 2023-05-20 14:01:32 #1(main) <sh6j9z>; cfg; rspamd_config_is_module_enabled: my_plugin disabling unconfigured lua module
```

If you have successfully configured your module, the rspamd-mailcow container logs should show:

```
mailcowdockerized-rspamd-mailcow-1  | 2023-05-20 14:04:50 #1(main) <8ayxpf>; cfg; rspamd_init_lua_filters: init lua module my_plugin from /etc/rspamd/plugins.d//my_plugin.lua; digest: 5cb88961e5
```