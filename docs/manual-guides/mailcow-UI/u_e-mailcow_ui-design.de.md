Das Design der mailcow UI und von SOGo lässt sich anpassen:

| Was | mailcow UI | SOGo |
| --- | --- | --- |
| Farben und Schriften | [Theme](#themes) | [Theme](#sogo-theme) |
| Einzelne Elemente | [CSS-Überschreibungen](#css-uberschreibungen) | – |
| Logo | [Logo und Texte](#logo-und-texte) | [Logo](#sogo-logo) |
| Titel, Texte und Footer | [Logo und Texte](#logo-und-texte) | – |
| Favicon | [Favicon](#favicon) | [Favicon](#favicon) |

---

## mailcow UI

### Themes

Seit mailcow 2026-10 ändern Themes das Aussehen der mailcow UI: Farben, Schriften und weitere Styles, im hellen und im dunklen Modus. mailcow liefert das Theme **servercow** mit.

#### Theme auswählen

Unter `System > Konfiguration > Einstellungen > UI-Anpassung` im Abschnitt **Theme** ein Theme auswählen und **Änderungen speichern** klicken. **Standard** ist das normale Aussehen von mailcow.

Unter der Auswahl stehen alle installierten Themes mit ihrem Ordnernamen. Ein Mond-Symbol kennzeichnet Themes mit einer Darkmode-Variante. Das Theme gilt für alle Benutzer und für die Login-Seite.

#### Eigenes Theme erstellen

Ein Theme ist ein Ordner `data/web/css/themes/<Name>/`. Der Name darf Buchstaben, Ziffern, `-` und `_` enthalten.

| Datei | Pflicht | Zweck |
| --- | --- | --- |
| `theme.css` | ja | Wird nach dem CSS von mailcow geladen |
| `dark.css` | nein | Wird im Darkmode nach dem Darkmode von mailcow geladen |
| `bootstrap.css` | nein | Ersetzt das Bootstrap-Basistheme (Lumen), z. B. durch ein [Bootswatch](https://bootswatch.com/)-Theme für Bootstrap 5.3 |
| `theme.json` | nein | Name und Beschreibung in der Liste der Themes |

```json title="theme.json"
{
  "name": "Example Corp",
  "description": "Farben der Example Corp"
}
```

Am einfachsten geht es über die CSS-Variablen von mailcow in der `theme.css`:

```css title="theme.css"
:root {
  --mc-primary: #2d6a4f;
  --mc-primary-border: #245a42;
  --mc-body-bg: #f6f8f7;
  --mc-font-family: Arial, sans-serif;
}
```

Alle Variablen und ihre Standardwerte stehen in `data/web/css/build/014-mailcow.css` (heller Modus) und `data/web/css/themes/mailcow-darkmode.css` (Darkmode). Die Variablen des Darkmodes gehören in die `dark.css`. Das Theme `servercow` in `data/web/css/themes/servercow/` ist ein vollständiges Beispiel inklusive Schriften.

!!! tip "Tipp"
    * mailcow bündelt die CSS-Dateien und erkennt Änderungen automatisch, ein Neuladen der Seite genügt.
    * Schriften und Bilder gehören in den Theme-Ordner und werden mit absoluten Pfaden eingebunden, z. B. `url('/css/themes/<Name>/fonts/font.woff2')`. Browser speichern diese Dateien lange zwischen, eine geänderte Datei braucht deshalb einen neuen Namen.
    * Eigene Theme-Ordner werden nicht von git verfolgt und bleiben bei Updates erhalten. Das Theme `servercow` wird bei Updates überschrieben. Zum Anpassen also erst in einen neuen Ordner kopieren.

#### Standard-Theme

`$UI_THEME` in `data/web/inc/vars.local.inc.php` legt das Theme fest, das für **Standard** verwendet wird. Ein in der mailcow UI ausgewähltes Theme hat Vorrang.

```php
<?php
$UI_THEME = "examplecorp";
```

Wie in früheren Versionen kann `$UI_THEME` auch eine einzelne Bootswatch-Datei `data/web/css/themes/<Name>-bootstrap.css` bezeichnen.

### CSS-Überschreibungen

Für wenige kleine Änderungen ist kein Theme nötig. Eigenes CSS kommt in die Datei `data/web/css/build/0081-custom-mailcow.css`. Die Datei wird von git nicht verfolgt und bleibt bei Updates erhalten.

### Logo und Texte

Unter `System > Konfiguration > Einstellungen > UI-Anpassung` lassen sich außerdem ändern:

* **Logo ändern**: Das Logo der Navigationsleiste und der Login-Seite, optional eine invertierte Variante für den Darkmode. Eine frei skalierbare Grafik (SVG) ist am besten.
* **UI-Label und Texte**: Der Webseiten-Titel, die Namen der mailcow UI und der Apps, der Hilfstext unter der Login-Maske, Ankündigungen und der Footer.
* **App-Links**: Zusätzliche Links im Apps-Menü.

---

## SOGo

### SOGo-Theme

Seit den mailcow-Builds vom 28. Januar 2021 lässt sich das Theme von SOGo über die Datei `data/conf/sogo/custom-theme.js` ändern. Wie das funktioniert, erklären das AngularJS Material [Intro](https://material.angularjs.org/latest/Theming/01_introduction), die [Dokumentation](https://material.angularjs.org/latest/Theming/03_configuring_a_theme) und die [Material Style Guideline](https://material.io/archive/guidelines/style/color.html#color-color-palette).

Die mitgelieferte `custom-theme.js` taugt als Vorlage, dafür die Kommentare entfernen. Nach den Änderungen an `data/conf/sogo/custom-theme.js`:

1\. In `data/conf/sogo/sogo.conf` den Eintrag `SOGoUIxDebugEnabled = YES;` setzen bzw. ergänzen.

2\. SOGo und Memcached neu starten:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart memcached-mailcow sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart memcached-mailcow sogo-mailcow
    ```

3\. SOGo im Browser öffnen.

4\. Die Entwicklerkonsole des Browsers öffnen, meist mit F12.

5\. Nur bei Firefox: `allow pasting` von Hand in die Konsole schreiben und Enter drücken.

6\. Diesen JavaScript-Schnipsel in die Konsole einfügen:
```
copy([].slice.call(document.styleSheets)
  .map(e => e.ownerNode)
  .filter(e => e.hasAttribute('md-theme-style'))
  .map(e => e.textContent)
  .join('\n')
)
```

7\. Einen Texteditor öffnen und den Inhalt der Zwischenablage einfügen (Strg+V). Das ergibt minimiertes CSS, das gespeichert wird.

8\. Die CSS-Datei auf den mailcow-Server nach `data/conf/sogo/custom-theme.css` kopieren.

9\. In `data/conf/sogo/sogo.conf` den Eintrag `SOGoUIxDebugEnabled = NO;` setzen.

10\. Die `docker-compose.override.yml` anlegen oder ergänzen:
```
services:
  sogo-mailcow:
    volumes:
      - ./data/conf/sogo/custom-theme.css:/usr/local/lib/GNUstep/SOGo/WebServerResources/css/theme-default.css:z
```

11\. Die Container neu erstellen:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

12\. Memcached neu starten:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart memcached-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart memcached-mailcow
    ```

#### Standard-Theme wiederherstellen

1. `data/conf/sogo/custom-theme.js` zurücksetzen: `git fetch ; git checkout origin/master data/conf/sogo/custom-theme.js data/conf/sogo/custom-theme.js`
2. In `data/conf/sogo/custom-theme.js` diesen Block suchen:
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
und ersetzen durch:
```
    $mdThemingProvider.theme('default');
```
3. In der `docker-compose.override.yml` den Volume-Mount bei `sogo-mailcow` entfernen:
```
- ./data/conf/sogo/custom-theme.css:/usr/local/lib/GNUstep/SOGo/WebServerResources/css/theme-default.css:z
```
4. Die Container neu erstellen:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

5. Memcached neu starten:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart memcached-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart memcached-mailcow
    ```

### SOGo-Logo

Seit den mailcow-Builds vom 21. Dezember 2018 lässt sich das SOGo-Logo über diese Dateien ändern:  
`data/conf/sogo/custom-fulllogo.png`  
`data/conf/sogo/custom-fulllogo.svg`  
`data/conf/sogo/custom-shortlogo.svg`  
Danach SOGo und Memcached neu starten:

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

Seit den mailcow-Builds vom 31. Januar 2021 lässt sich das Favicon ändern: `data/conf/sogo/custom-favicon.ico` für SOGo und `data/web/favicon.png` für die mailcow UI ersetzen.

**Hinweis**: Für SOGo funktionieren auch `.png`-Favicons, wenn sie in `custom-favicon.ico` umbenannt werden.
Beide Favicons brauchen eine der Standardgrößen: 16x16, 32x32, 64x64, 128x128 oder 256x256.
Danach SOGo und Memcached neu starten:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart memcached-mailcow sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart memcached-mailcow sogo-mailcow
    ```
