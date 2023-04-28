# HighCarb

HighCarb is a framework to create presentations.

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
│   └── custom.js
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

#### Custom Haml Filters

You can register your own filters for use on the slide sources. Each filter is associated with a program that will be executed for each appearance of filter.

The content of the filter is sent to the standard input of the program. Its output will be added to the generated HTML. Filters are always executed in the root directory of the presentation.

Filters are registered in the `config.yaml` file in the root of the presentation directory, as items of the `haml_filters` key.

For example, we can add a filter `notes` to execute `render-notes.sh`:

```yaml
haml_filters:
  notes: ./render-notes.sh
```

Then, in the presentation directory we create `render-notes.sh`, with execute permission and the following content:

```sh
#!/bin/sh

# Depends on https://github.com/commonmark/cmark

printf '<div class="notes">'
cmark
printf '</div>'
```

Finally, in the Haml sources the filter can be used with `:notes`:

```haml
.slide
  %h1 Title

  :notes
    Content that will be sent to `render-notes.sh`
```

##### Stream Protocol

If the program takes a long time to start, you can use the `stream:` protocol to
send and receive the data.

First, in the `config.yaml` entry, declare the filter with the `stream:` prefix:

```yaml
haml_filters:
  foo: stream:./render-foo
```

Then, when `render-foo` is executed, it will run as a background process. For
each instance of the `:foo` filter in Haml, the program will receive a message
with the following format:

    <size, in bytes, of the content, decimal digits> "\n"
    <content>

For example, if the source contains this code:

```haml
:foo
    test
```

The program will receive a message like this:

```ruby
"5\ntest\n"
```

The response has to follow the same format: a line with the size (in bytes) of
the HTML, and the HTML code.

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
