
SOGo is used for accessing your mails via a webbrowser, adding and sharing your contacts or calendars. For a more in-depth documentation on SOGo please visit its [own documentation](http://wiki.sogo.nu/).

## Change Theme
As of December 21 2018 we removed our custom themes due to complains about missing colors in some address book and calendar sections. Some other problems were still existing and would not be fixed in the near future (switching colors on login screen, for example).

## Change Logo
mailcow builds after 21 December 2018 can change SOGo's logo by replacing `data/conf/sogo/sogo-full.svg`.
After you replaced said file you need to restart SOGo and Memcached containers by executing `docker-compose restart memcached-mailcow sogo-mailcow`.
