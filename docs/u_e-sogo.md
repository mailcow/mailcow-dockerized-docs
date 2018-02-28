
SOGo is used for accessing your mails via a webbrowser, adding and sharing your contacts or calendars. For a more in-depth documentation on SOGo please visit its [own documentation](http://wiki.sogo.nu/).

## Change Theme

You can change SOGo's theme by editing `data/conf/sogo/sogo.conf`. Per default it uses a blue theme, which you can change e.g. to a green or red theme. More colored themes will be supported in the future.
After you edited said file you need to restart the SOGO container with `docker-compose restart sogo-mailcow` or via the Mailcow UI.

##### Example (`data/conf/sogo/sogo.conf`, line 17):
```
before:
SOGoUIAdditionalJSFiles = (js/theme-blue.js);

after:
SOGoUIAdditionalJSFiles = (js/theme-red.js);
```

## Change Logo
You can change SOGo's logo by replacing `data/Dockerfiles/sogo/sogo-full.svg`.
After you replaced said file you need to rebuild the container by executing `docker-compose build sogo-mailcow` and start it with `docker-compose up -d sogo-mailcow`.
