# HighCarb

HighCarb is a framework to create presentations.

The presentation is based on Deck.js

## Installation

```
$ gem install highcarb
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
│   ├── custom.js
├── slides
│   └── 0001.haml
└── snippets
    └── README
```

### Slides

The content can be wrote in HAML, MarkDown or in raw HTML.

The generator will concatenate all the files when the presentation is shown.

#### Special tags

`%snippet` is used to load a file from the `snippets` directory.

`%asset` load a file from the `assets` directory. If the file is an image, an `img` will be created. If it is a CSS file (or SCSS), a `link` tag will be used. And, for JavaScript files, a `script` tag is used.

If type asset type can not be determined by the MIME type, a CSS class can be added to the `asset` tag to force the type. The class can be `image`, `style` or `javascript`

If the asset is something else, a link will be added with an anchor.

`%external` can be used to create link to external pages. The shown text is shorted to be less noisy.

## Assets

Every file from the `asset` directory is accessible from the `http://domain/asset/` URL.

## Example

With this files

```
/slide
├── assets
│   ├── hacks.js
    └── first.png
└── snippets
    └── README
```

We could write

```haml

  %asset hacks.js

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

There is no need to restart the server if the content is changed. Everything will be regenerated
when reload the page in the browser. The HTML generated for the snippets is cached. The cached key
is the MD5 sum of the content.
