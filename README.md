# HighCarb

HighCarb is a framework to create presentations, and to control them remotely.

The presentation is based on Deck.js

## Installation

I have to create a gem (or event a .deb package). Right now, the easiest way to install it
is clone the repository and add an alias.

```
  $ cd /somewhere/
  $ git clone git://github.com/ayosec/highcarb.git
  $ cd highcarb
  $ bundle install
  $ alias highcarb="ruby /somewhere/highcarb/bin/highcarb"
```

### Dependencies

* You have to install Pygmentize if you want to highlight the code snippets.
* A JavaScript interpreter is needed to compile the CoffeeScript source. Rhino or JavaScript can be used with no problems.

In Debian (and derived) everything can be installed with

```
  $ sudo apt-get install nodejs python-pygments
```

## Generate a presentation project

The `-g` flag generate a new tree with the base for the presentation

```
  $ highcarb -g /my/slides/foobar
```

## Adding content

The generated tree is something like

```
/slide
├── assets
│   ├── README
│   ├── base.scss
│   ├── remote.scss
│   ├── custom.coffee
│   ├── custom-remote.coffee
│   └── vendor
│       └── deck.js
│           ├── ...
│           └── ...
├── slides
│   └── 0001.haml
└── snippets
    └── README
```

### Slides

The content can be wrote in HAML, MarkDown or in raw HTML.

The generator will concatenate all the files when the presentation is shown.

#### Special tags

`%snippet` is used to load a file from the `snippets` directory. If Pygmentize is found, the code will be highlighted. If not, the content will be shown in a monospace font.

`%asset` load a file from the `assets` directory. If the file is an image, an `img` will be created. If it is a CSS file (or SCSS), a `link` tag will be used. And, for JavaScript (or CoffeeScript) files, a `script` tag is used.

If type asset type can not be determined by the MIME type, a CSS class can be added to the `asset` tag to force the type. The class can be `image`, `style` or `javascript`

If the asset is something else, a link will be added with an anchor.

`%external` can be used to create link to external pages. The shown text is shorted to be less noisy.

#### Notes

Everything with the `note` CSS class will be removed from the slide. This content is accessible in the `remote` view.

## Assets

Every file from the `asset` directory is accessible from the `http://domain/asset/` URL.

If the file is a CoffeeScript source, it will be compiled as JavaScript before be sent. Same for SCSS.

## Example

With this files

```
/slide
├── assets
│   ├── hacks.coffee
    └── first.png
└── snippets
    └── README
```

We could write

```haml

  %asset hacks.coffee

  .slide
    %h1 First slide
    
    %asset first.png

  .slide
    %h1 Second one

    %ul
      %li.slide this
      %li.slide and
      %li.slide that
      %li.slide
        See this:
        %external http://somewhere.tld/sometime
```

## View the presentation


```
  $ highcarb /my/slides/foobar
```

Some options are available with the `--help` flag.

With the defaults options the web server will listen on 9090, so the presentation can
be see at http://localhost:9090/

To control it from another browser go to http://localhost:9090/remote. The remote view
show the full slides, so you can see everything. Left and right keys can be used to move
the slide of the remote browser.

There is no need to restart the server if the content is changed. Everything will be regenerated
when reload the page in the browser. The HTML generated for the snippets is cached. The cached key
is the MD5 sum of the content.
