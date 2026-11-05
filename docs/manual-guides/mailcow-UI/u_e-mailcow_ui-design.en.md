You can customize the design of the mailcow UI and of SOGo:

| What | mailcow UI | SOGo |
| --- | --- | --- |
| Colors and fonts | [Theme](#themes) | [Theme](#sogo-theme) |
| Single elements | [CSS overrides](#css-overrides) | – |
| Logo | [Logo and texts](#logo-and-texts) | [Logo](#sogo-logo) |
| Title, texts and footer | [Logo and texts](#logo-and-texts) | – |
| Favicon | [Favicon](#favicon) | [Favicon](#favicon) |

---

## mailcow UI

### Themes

Since mailcow 2026-10, themes change the look of the mailcow UI: colors, fonts and other styles, in light and dark mode. mailcow ships the theme **servercow**.

#### Select a theme

Navigate to `System > Configuration > Options > Customize`, choose a theme in the section **Theme** and click **Save changes**. **Default** is the standard look of mailcow.

Below the selection, all installed themes are listed with their folder name. A moon icon marks themes with a dark mode variant. The theme applies to all users and to the login page.

#### Create your own theme

A theme is a folder `data/web/css/themes/<name>/`. The name may contain letters, digits, `-` and `_`.

| File | Required | Purpose |
| --- | --- | --- |
| `theme.css` | yes | Loaded after the CSS of mailcow |
| `dark.css` | no | Loaded in dark mode, after the dark mode of mailcow |
| `bootstrap.css` | no | Replaces the Bootstrap base theme (Lumen), e.g. with a [Bootswatch](https://bootswatch.com/) theme for Bootstrap 5.3 |
| `theme.json` | no | Name and description in the list of themes |

```json title="theme.json"
{
  "name": "Example Corp",
  "description": "Colors of Example Corp"
}
```

The easiest way to style mailcow is to change its CSS variables in `theme.css`:

```css title="theme.css"
:root {
  --mc-primary: #2d6a4f;
  --mc-primary-border: #245a42;
  --mc-body-bg: #f6f8f7;
  --mc-font-family: Arial, sans-serif;
}
```

All variables and their defaults are found in `data/web/css/build/014-mailcow.css` (light mode) and `data/web/css/themes/mailcow-darkmode.css` (dark mode). Change the variables of the dark mode in `dark.css`. The theme `servercow` in `data/web/css/themes/servercow/` is a complete example including fonts.

!!! tip
    * mailcow bundles the CSS files and detects changes automatically, reloading the page is enough.
    * Put fonts and images into the theme folder and reference them with absolute paths, e.g. `url('/css/themes/<name>/fonts/font.woff2')`. Browsers cache these files for a long time, so give a changed file a new name.
    * Your own theme folders are not tracked by git and persist over updates. Updates overwrite the theme `servercow`. To change it, copy it to a new folder first.

#### Default theme

`$UI_THEME` in `data/web/inc/vars.local.inc.php` sets the theme that is used for **Default**. A theme selected in the mailcow UI takes precedence.

```php
<?php
$UI_THEME = "examplecorp";
```

As in earlier versions, `$UI_THEME` can also name a single Bootswatch file `data/web/css/themes/<name>-bootstrap.css`.

### CSS overrides

For a few small changes, a theme is not necessary. Put your CSS into `data/web/css/build/0081-custom-mailcow.css`. The file is excluded from tracking and persists over updates.

### Logo and texts

In `System > Configuration > Options > Customize`, administrators can also change:

* **Change logo**: The logo of the navigation bar and the login page, optionally an inverted variant for dark mode. A scalable graphic (SVG) is recommended.
* **UI labels and texts**: The website title, the names of the mailcow UI and the apps, the help text below the login mask, announcements and the footer.
* **App links**: Additional links in the apps menu.

---

## SOGo

### SOGo theme

mailcow builds after 28 January 2021 can change SOGo's theme by editing `data/conf/sogo/custom-theme.js`.
Please check the AngularJS Material [intro](https://material.angularjs.org/latest/Theming/01_introduction) and [documentation](https://material.angularjs.org/latest/Theming/03_configuring_a_theme) as well as the [material style guideline](https://material.io/archive/guidelines/style/color.html#color-color-palette) to learn how this works. 

You can use the provided `custom-theme.js` as an example starting point by removing the comments.
After you modified `data/conf/sogo/custom-theme.js` and made changes to your new SOGo theme you need to 

1\. edit `data/conf/sogo/sogo.conf` and append/set `SOGoUIxDebugEnabled = YES;`

2\. restart SOGo and Memcached containers by executing the command:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart memcached-mailcow sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart memcached-mailcow sogo-mailcow
    ```

3\. open SOGo in browser

4\. open browser developer console, usually shortcut is F12

5\. only if you use Firefox: write by hands in dev console `allow pasting` and press enter

6\. paste java script snippet in dev console:
```
copy([].slice.call(document.styleSheets)
  .map(e => e.ownerNode)
  .filter(e => e.hasAttribute('md-theme-style'))
  .map(e => e.textContent)
  .join('\n')
)
```

7\. open text editor and paste data from clipboard (Ctrl+V), you should get minified CSS, save it

8\. copy CSS file to mailcow server `data/conf/sogo/custom-theme.css`

9\. edit `data/conf/sogo/sogo.conf` and set `SOGoUIxDebugEnabled = NO;`

10\. append/create `docker-compose.override.yml` with:
```
services:
  sogo-mailcow:
    volumes:
      - ./data/conf/sogo/custom-theme.css:/usr/local/lib/GNUstep/SOGo/WebServerResources/css/theme-default.css:z
```

11\. Run: 
=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

12\. Run: 
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart memcached-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart memcached-mailcow
    ```

#### Reset to the default theme

1\. checkout `data/conf/sogo/custom-theme.js` by executing `git fetch ; git checkout origin/master data/conf/sogo/custom-theme.js data/conf/sogo/custom-theme.js`

2\. find in `data/conf/sogo/custom-theme.js`:
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

3\. remove from `docker-compose.override.yml` volume mount in `sogo-mailcow`:
```
- ./data/conf/sogo/custom-theme.css:/usr/local/lib/GNUstep/SOGo/WebServerResources/css/theme-default.css:z
```

4\. Run: 
=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

5\. Run: 
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart memcached-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart memcached-mailcow
    ```

### SOGo logo

mailcow builds after 21 December 2018 can change SOGo's logo by replacing the following files:   
`data/conf/sogo/custom-fulllogo.png`  
`data/conf/sogo/custom-fulllogo.svg`  
`data/conf/sogo/custom-shortlogo.svg`  
After you replaced said file you need to restart SOGo and Memcached containers by executing:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart memcached-mailcow sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart memcached-mailcow sogo-mailcow
    ```

---

## Favicon

mailcow builds after 31 January 2021 can change SOGo's favicon by replacing `data/conf/sogo/custom-favicon.ico` for SOGo and `data/web/favicon.png` for mailcow UI.
**Note**: You can use `.png` favicons for SOGo by renaming them to `custom-favicon.ico`.
For both SOGo and mailcow UI favicons you need use one of the standard dimensions: 16x16, 32x32, 64x64, 128x128 and 256x256.
After you replaced said file you need to restart SOGo and Memcached containers by executing:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart memcached-mailcow sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart memcached-mailcow sogo-mailcow
    ```
