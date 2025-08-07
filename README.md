# mailcow-docs | [![pages-build-deployment](https://github.com/mailcow/mailcow-dockerized-docs/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/mailcow/mailcow-dockerized-docs/actions/workflows/pages/pages-build-deployment)
The official mailcow docs based on mkdocs-material

## Introduction:
The mailcow documentation has been redesigned from scratch based on the original (legacy-1.0 branch).

Advantages compared to the legacy version:
- Full translation support (English and German are officially supported by Servercow/tinc).
- New folder structure for better overview/ordering of sub-pages.
- Switches for Command Syntax (Docker Compose especially)


## Contributions:

### About contributions:
The documentation lives (just like the actual mailcow project) from community contributions.

Of course, we will also make our contributions to the documentation, but especially the new translation support naturally brings some scope for multiple community supported languages.

To contribute new pages/translations simply clone the repository and then work with your cloned repository.
Once you are done with your work start a pull request, if approved this will then be implemented into the actual documentation.


### Use the Compose Switch in a new/edited Page:
If you plan to contribute to our docs please make sure to always specify **both** docker compose syntaxes! This can be done by using a "switch". Example:

```
=== "docker compose (Plugin)"

    ``` bash
    docker compose exec rspamd-mailcow bash
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec rspamd-mailcow bash
    ```
```

Simply change the content of these two cases according to your desired needs.


### Translations
#### About Translations:

So you want to provide a new translation for the documentation? Great, thanks for that <3

There are a few things to keep in mind, which are essential for a smooth process:

#### Add the new Language to the Language selector:
As a start for possible translations, the language must first be added to the language selection. To add it, edit the mkdocs.yml file and add the language in the "translations" section (under the already existing languages):
```
[...]
  - i18n: # <--- Translation plugin
      default_language: en
      languages:
        en: English
        de: Deutsch
        [...] <--- Add the languages here.
[...]
```
The new language will now appear in the language selector once the mkdocs are rebuilt (see [Testing](#Testing)).

The i18n plugin for mkdocs (see [here](https://github.com/ultrabug/mkdocs-static-i18n) is used for our documentation, so the standard notations of the plugin apply (see [here](https://github.com/ultrabug/mkdocs-static-i18n#referencing-localized-content-in-your-markdown-pages)) i.e. each language of a page will be a separate `.md` file which is composed of the `filename.languagecode.md`.

**The filenames must remain the same for the other languages, only the country code in front of the .md extension is set to the desired language.**

If a page does **NOT** exist in a language, the English version of the page will be used by default, because English is set as default_language in mkdocs.yml.

Images can also be "translated"! These are distinguished (similar to the pages) by the country codes.


#### Translate the menu:
The menu is **NOT** translated by default and must be translated by hand, this is also done in the mkdocs.yml:
```
[...]
- i18n: # <--- Translation plugin
      default_language: en
      languages:
        en: English
        de: Deutsch
      nav_translations:
      #### Begin of german translation
        de: #<--- Language code here
          'Information & Support': 'Informationen & Support'
          ### Prerequisites Section
          'Prerequisites': 'Voraussetzungen'
          'Prepare your system': 'Systemvoraussetzungen'
          'DNS setup': 'DNS Einstellungen'
[...]          
```
The preceding English variant **MUST be kept**, otherwise the translation will **not work**.


### Folder structure:
```
docs <-- Root Folder
├── assets
│   └── images <-- Folder where the images are located (sorted by main chapter)
│       ├─ topic1
|       │   ├── image.en.png
|       │   ├── image.de.png
|       │   ├── image.XX.png
|       ├─ topic2
|       │   ├── image.en.png
|       │   ├── image.de.png
|       │   ├── image.XX.png
|       ├─ topicX
|           ├── image.en.png
|           ├── image.de.png
|           ├── image.XX.png
| 
├── topic1 <-- Folder where the documentation sites are located (sorted by main chapter)
│    ├── file.en.md
|    ├── file.de.md
│    ├── file.XX.md
| 
├── topic2
│    ├── subtopic1 <-- Some Chapters are divided into multiple subtopics 
|    |    ├── file.en.md
|    |    ├── file.de.md
|    |    ├── file.XX.md
│    ├── subtopicX
|         ├── file.en.md
|         ├── file.de.md
|         ├── file.XX.md
| 
├── topicX
│    ├── file.en.md
|    ├── file.de.md
│    ├── file.XX.md
```

## Testing

To build and test it locally, you need the [Material theme for MkDocs](https://squidfunk.github.io/mkdocs-material/), [MkDocs](https://www.mkdocs.org/) itself and [Pygments](http://pygments.org/). To install these with [pip](https://pip.pypa.io/en/stable/) and get it up and running, fire up your terminal and enter

```
git clone https://github.com/mailcow/mailcow-dockerized-docs.git
pip install -r requirements.txt
mkdocs serve
```


The Placeholder values get replaced by the JavaScript in the file docs/assets/javascript/client.js.

If you want to test how the documentation looks like with the placeholder values filled in, you can set the values via url parameters.

For Example: 
```
http://127.0.0.1:8000/client/client-manual/#host=mail.test.org&email=mail@example.org&name=mail&ui=mail.example.org&port=443
```

## Misc

mailcow is a registered word mark of The Infrastructure Company GmbH, Parkstr. 42, 47877 Willich, Germany.

The project is managed and maintained by The Infrastructure Company GmbH.

Originated from @andryyy (André)
