
SOGo is used for accessing your mails via a webbrowser, adding and sharing your contacts or calendars. For a more in-depth documentation on SOGo please visit its [own documentation](http://wiki.sogo.nu/).

## Apply custom SOGo theme
mailcow builds after 28 January 2021 can change SOGo's theme by editing `data/conf/sogo/custom-theme.js`.
Please check the AngularJS Material [intro](https://material.angularjs.org/latest/Theming/01_introduction) and [documentation](https://material.angularjs.org/latest/Theming/03_configuring_a_theme) as well as the [material style guideline](https://material.io/archive/guidelines/style/color.html#color-color-palette) to learn how this works. 

You can use the provided `custom-theme.js` as an example starting point by removing the comments.
After you modified `data/conf/sogo/custom-theme.js` and made changes to your new SOGo theme you need to 

1. edit `data/conf/sogo/sogo.conf` and append/set `SOGoUIxDebugEnabled = YES;`
2. restart SOGo and Memcached containers by executing `docker-compose restart memcached-mailcow sogo-mailcow`.
3. open SOGo in browser
4. open browser developer console, usually shortcut is F12
5. only if you use Firefox: write by hands in dev console `allow pasting` and press enter
6. paste java script snipet in dev console:
```
copy([].slice.call(document.styleSheets)
  .map(e => e.ownerNode)
  .filter(e => e.hasAttribute('md-theme-style'))
  .map(e => e.textContent)
  .join('\n')
)
```
7. open text editor and paste data from clipboard (Ctrl+V), you should get minified CSS, save it
8. copy CSS file to mailcow server `data/conf/sogo/custom-theme.css`
9. edit `data/conf/sogo/sogo.conf` and set `SOGoUIxDebugEnabled = NO;`
10. append/create `docker-compose.override.yml` with:
```
version: '2.1'

services:
  sogo-mailcow:
    volumes:
      - ./data/conf/sogo/custom-theme.css:/usr/lib/GNUstep/SOGo/WebServerResources/css/theme-default.css:z
```
11. run `docker-compose up -d`
12. run `docker-compose restart memcached-mailcow`

## Reset to SOGo default theme
1. checkout `data/conf/sogo/custom-theme.js` by executing `git fetch ; git checkout origin/master data/conf/sogo/custom-theme.js data/conf/sogo/custom-theme.js`
2. find in `data/conf/sogo/custom-theme.js`:
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
        'default': '600',  // background color of fab buttons and login screen
        'hue-1': '300',    // background color of center list toolbar
        'hue-2': '300',    // highlight color for selected mail and current day calendar
        'hue-3': 'A700'
      })
      .backgroundPalette('frost-grey');
```
and replace it with:
```
    $mdThemingProvider.theme('default');
```
3. remove from `docker-compose.override.yml` volume mount in `sogo-mailcow`:
```
- ./data/conf/sogo/custom-theme.css:/usr/lib/GNUstep/SOGo/WebServerResources/css/theme-default.css:z
```
4. run `docker-compose up -d`
5. run `docker-compose restart memcached-mailcow`

## Change favicon
mailcow builds after 31 January 2021 can change SOGo's favicon by replacing `data/conf/sogo/custom-favicon.ico` for SOGo and `data/web/favicon.png` for mailcow UI.
**Note**: You can use `.png` favicons for SOGo by renaming them to `custom-favicon.ico`.
For both SOGo and mailcow UI favicons you need use one of the standard dimensions: 16x16, 32x32, 64x64, 128x128 and 256x256.
After you replaced said file you need to restart SOGo and Memcached containers by executing `docker-compose restart memcached-mailcow sogo-mailcow`.

## Change logo
mailcow builds after 21 December 2018 can change SOGo's logo by replacing or creating (if missing) `data/conf/sogo/sogo-full.svg`.
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

## Reset TOTP / Disable TOTP

Run `docker-compose exec -u sogo sogo-mailcow sogo-tool user-preferences set defaults user@domain.tld SOGoTOTPEnabled '{"SOGoTOTPEnabled":0}'` from within the mailcow directory.
