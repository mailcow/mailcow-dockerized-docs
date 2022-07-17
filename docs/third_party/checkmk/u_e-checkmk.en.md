Mailcow provides the ability to check for updates using its own update script.

If you want to check for mailcow updates using checkmk, you can create an executable file in the `local` directory of the checkmk agent (typically `/usr/lib/check_mk_agent/local/`) with the name `mailcow_update` and the following content:

````
#!/bin/bash
cd /opt/mailcow-dockerized/ && ./update.sh -c >/dev/null
status=$?
if [ $status -eq 3 ]; then
  echo "0 \"mailcow_update\" mailcow_update=0;1;;0;1 No updates available."
elif [ $status -eq 0 ]; then
  echo "1 \"mailcow_update\" mailcow_update=1;1;;0;1 Updated code is available.\nThe changes can be found here: https://github.com/mailcow/mailcow-dockerized/commits/master"
else
  echo "3 \"mailcow_update\" - Unknown output from update script ..."
fi
exit
````

If the mailcow installation directory is not `/opt/`, adjust this in the 2nd line.

After that re-inventory the services for your mailcow host in checmk and a new check named `mailcow_update` should be selectable.

## Screenshots

### No updates available

If there are no updates available, `OK` is displayed.

![No update available](../../assets/images/checkmk/no_updates_available.png)

### New updates available

If updates are available, `WARN` is displayed.

![Updates available](../../assets/images/checkmk/updates_available.png)

If `CRIT` is desired instead, replace the 7th line with the following:

````
  echo "2 \"mailcow_update\" mailcow_update=1;1;;0;1 Updated code is available.\nThe changes can be found here: https://github.com/mailcow/mailcow-dockerized/commits/master"
````

### Detailed check output

![Long check output](../../assets/images/checkmk/long_check_output.png)

- This provides a link to mailcow's GitHub commits, if updates are available.
- Metrics are also displayed ( not only when updates are available):
  - 0 = No updates available
  - 1 = New updates available
