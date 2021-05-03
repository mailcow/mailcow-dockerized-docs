[![Build and deploy to gh-pages](https://github.com/mailcow/mailcow-dockerized-docs/actions/workflows/gh-pages.yml/badge.svg)](https://github.com/mailcow/mailcow-dockerized-docs/actions/workflows/gh-pages.yml)

# mailcow: dockerized documentation

This project aims to provide the mailcow: dockerized documentation for the [mailcow: dockerized](https://github.com/mailcow/mailcow-dockerized) project.

https://mailcow.github.io/mailcow-dockerized-docs

To build it locally, you need the [Material theme for MkDocs](https://squidfunk.github.io/mkdocs-material/), [MkDocs](https://www.mkdocs.org/) itself and [Pygments](http://pygments.org/). To install these with [pip](https://pip.pypa.io/en/stable/) and get it up and running, fire up your terminal and enter

```
pip install mkdocs-material pygments==2.9.0 mkdocs-redirects
mkdocs serve
```
