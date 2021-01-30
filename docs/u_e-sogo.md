
SOGo is used for accessing your mails via a webbrowser, adding and sharing your contacts or calendars. For a more in-depth documentation on SOGo please visit its [own documentation](http://wiki.sogo.nu/).

## Change theme
mailcow builds after 28 January 2021 can change SOGo's theme by editing `data/conf/sogo/custom-theme.js`.
Please check AngularJS Material [Intro](https://material.angularjs.org/latest/Theming/01_introduction) and [Configuring a theme](https://material.angularjs.org/latest/Theming/03_configuring_a_theme) documentation to get more details on how this works.
After you updated said file you need to restart SOGo and Memcached containers by executing `docker-compose restart memcached-mailcow sogo-mailcow`.

## Reset to SOGo default theme
Checkout `data/conf/sogo/custom-theme.js` by executing `git fetch ; git checkout origin/master data/conf/sogo/custom-theme.js data/conf/sogo/custom-theme.js`
Find in `data/conf/sogo/custom-theme.js`:
```
// Apply new palettes to the default theme, remap some of the hues
    $mdThemingProvider.theme('default')
      .primaryPalette('green-cow', {
        'default': '400',  // background color of top toolbars
        'hue-1': '400',
        'hue-2': '600',    // background color of sidebar toolbar
        'hue-3': 'A700'
      })
      .accentPalette('green', {
        'default': '600',  // background color of fab buttons
        'hue-1': '300',    // background color of center list toolbar
        'hue-2': '300',
        'hue-3': 'A700'
      })
      .backgroundPalette('frost-grey');
```
and replace with:
```
    $mdThemingProvider.theme('default');
```

## Change favicon
mailcow builds after 30 January 2021 can change SOGo's favicon by replacing `data/conf/sogo/custom-favicon.ico`.
To note: you can use `.png` favicons, renaming them `custom-favicon.ico` will works, but please use standard `.ico` dimensions, e.g: 16x16, 32x32, 64x64, 128x128 and 256x256.
After you replaced said file you need to restart SOGo and Memcached containers by executing `docker-compose restart memcached-mailcow sogo-mailcow`.

## Change logo
mailcow builds after 21 December 2018 can change SOGo's logo by replacing `data/conf/sogo/sogo-full.svg`.
After you replaced said file you need to restart SOGo and Memcached containers by executing `docker-compose restart memcached-mailcow sogo-mailcow`.

## Connect domains
Domains are usually isolated from eachother.

You can change that by modifying `data/conf/sogo/sogo.conf`:

Search...
```
   // SOGoDomainsVisibility = (
    //  (domain1.tld, domain5.tld),
    //  (domain3.tld, domain2.tld)
    // );
```
...and replace it by - for example:

```
    SOGoDomainsVisibility = (
      (example.org, example.com, example.net)
    );
```

Restart SOGo: `docker-compose restart sogo-mailcow`

## Disable password changing

Edit `data/conf/sogo/sogo.conf` and **change** `SOGoPasswordChangeEnabled` to `NO`. Please do not add a new parameter.

Run `docker-compose restart memcached-mailcow sogo-mailcow` to activate the changes.

