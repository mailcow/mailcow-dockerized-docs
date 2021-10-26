# Build the SOGo Connector plugin

Install GNU Make, tar, and ZIP if you don't already have them installed. On Debian/Ubuntu, this can be done using

```
apt-get install make tar zip
```

Next, go to `data/web` inside mailcow-dockerized.
Place the file [thunderbird-plugins.php](download/thunderbird-plugins.php) into that directory.
Create a new directory `thunderbird-plugins` and place the script [build-plugins.sh](download/build-thunderbird-plugins.sh) into it.
Finally, execute the script with your hostname as an argument and piping it the names of all domains that mailcow handles.
All of this can be done using the following commands:

```
cd data/web
curl -LO https://github.com/mailcow/mailcow-dockerized-docs/raw/master/docs/download/thunderbird-plugins.php
mkdir thunderbird-plugins
cd thunderbird-plugins
curl -Lo build-plugins.sh https://github.com/mailcow/mailcow-dockerized-docs/raw/master/docs/download/build-thunderbird-plugins.sh
chmod +x build-plugins.sh
echo example.com example.org | ./build-plugins.sh mailcow.example.com
```

# Install it in Thunderbird

After you have set up your mailcow IMAP account in Thunderbird, download the SOGo Connector plugin for your domain, e.g. https://mailcow.example.com/thunderbird-plugins/sogo-connector-68.0.1-example.com.xpi (see `data/web/thunderbird-plugins`), and install it into Thunderbird.
All your address books and calendars will be configured automatically.
