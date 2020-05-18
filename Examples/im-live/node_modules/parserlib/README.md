# CSS Parser

[![build status](https://secure.travis-ci.org/CSSLint/parser-lib.svg?branch=master)](https://travis-ci.org/CSSLint/parser-lib)

## Introduction

The ParserLib CSS parser is a CSS3 SAX-inspired parser written in JavaScript.
It handles standard CSS syntax as well as validation (checking of
property names and values) although it is not guaranteed to thoroughly
validate all possible CSS properties.

## Adding to your project

The CSS parser is built for a number of different JavaScript
environments.  The most recently released version of the parser
can be found in the `dist` directory when you check out the
repository; run `npm run build` to regenerate them from the
latest sources.

### Node.js

You can use the CSS parser in a `Node.js` script via the standard
`npm` package manager as the `parserlib` package (`npm install parserlib`):

```js
var parserlib = require("parserlib");

var parser = new parserlib.css.Parser();
```

Alternatively, you can copy a single file version of the parser from
`dist/node-parserlib.js` to your own project, and use it as follows:

```js
var parserlib = require("./node-parserlib");
```

### Rhino

To use the CSS parser in a Rhino script, copy the file
`dist/parserlib.js` to your project and then include it at the beginning:

```js
load("parserlib.js");
```

### HTML page

To use the CSS parser on an HTML page, you can either include the entire
library on your page:

```html
<script src="parserlib.js"></script>
```

Or include it as its component parts, the ParserLib core and the CSS parser:

```html
<script src="parserlib-core.js"></script>
<script src="parserlib-css.js"></script>
```

Note that parsing large JavaScript files may cause the browser to
become unresponsive.  All three of these files are located in the
`dist` directory.

## Basic usage

You can create a new instance of the parser by using the following code:

```js
var parser = new parserlib.css.Parser();
```

The constructor accepts an options object that specifies additional features
the parser should use. The available options are:

* `starHack` - set to true to treat properties with a leading asterisk as if
  the asterisk wasn't there. Default is `false`.
* `underscoreHack` - set to true to treat properties with a leading underscore
  as if the underscore wasn't there. Default is `false`.
* `ieFilters` - set to true to accept IE < 8 style `filter` properties.
  Default is `false`.
* `strict` - set to true to disable error recovery and stop on the first
  syntax error. Default is `false`.

Here's an example with some options set:

```js
var parser = new parserlib.css.Parser({ starHack: true, underscoreHack: true });
```

You can then parse a string of CSS code by passing into the `parse()` method:

```js
parser.parse(someCSSText);
```

The `parse()` method throws an error if a non-recoverable syntax error occurs,
otherwise it finishes silently.
This method does not return a value nor does it build up an abstract syntax
tree (AST) for you, it simply parses the CSS text and fires events at important
moments along the parse.

Note: The `parseStyleSheet()` method is provided for compatibility with
SAC-based APIs but does the exact same thing as `parse()`.

## Understanding syntax units

The CSS parser defines several types that inherit from `parserlib.util.SyntaxUnit`.
These types are designed to give you easy access to all relevant parts of the CSS syntax.

### Media Queries

The `parserlib.css.MediaFeature` type represents a specific media feature in a
media query, such as `(orientation: portrait)` or `(color)`. Essentially, this
type of object represents anything enclosed in parentheses in a media query.
Object of this type have the following properties:

* `name` - the name of the media feature such as "orientation"
* `value` - the value of the media feature (may be `null`)

The `parserlib.css.MediaQuery` type represents all parts of a media query.
Each instance has the following properties:

* `modifier` - either "not" or "only"
* `mediaType` - the actual media type such as "print"
* `features` - an array of `parserlib.css.MediaFeature` objects

For example, consider the following media query:

```css
only screen and (max-device-width: 768px) and (orientation: portrait)
```

A corresponding object would have the following values:

* `modifier` = "only"
* `mediaType` = "screen"
* `features` = array of (`name`="max-device-width", `value`="768px") and (`name`="orientation", `value`="portrait")

### Properties

The `parserlib.css.PropertyName` type represents a property name. Each instance has the following properties:

* `hack` - if star or underscore hacks are allowed, either `*` or `_` if present (`null` if not present or hacks are not allowed)

When star hacks are allowed, the `text` property becomes the actual property name,
so `*width` has `hack` equal to `*` and `text` equal to "width". If no hacks are allowed,
then `*width` causes a syntax error while `_width` has `hack` equal to `null` and `text` equal to `_width`.

The `parserlib.css.PropertyValue` type represents a property value. Since property values in CSS are complex,
this type of object wraps the various parts into a single interface. Each instance has the following properties:

* `parts` - array of `PropertyValuePart` objects

The `parts` array always has at least one item.

The `parserlib.css.PropertyValuePart` type represents an individual part of a
property value. Each instance has the following properties:

* `type` - the type of value part ("unknown", "dimension", "percentage", "integer", "number", "color", "uri",  "string", "identifier" or "operator")

A part is considered any atomic piece of a property value not including white space. Consider the following:

```css
font: 1em/1.5em "Times New Roman", Times, serif;
```

The `PropertyName` is "font" and the `PropertyValue` represents everything after the colon.
The parts are "1em" (dimension), "/" (operator), "1.5em" (dimension), "Times New Roman" (string),
"," (operator), "Times" (identifier), "," (operator), and "serif" (identifier).

### Selectors

The `parserlib.css.Selector` type represents a single selector. Each instance
has a `parts` property, which is an array of `parserlib.css.SelectorPart` objects,
which represent atomic parts of the selector, and `parserlib.css.Combinator`
objects, which represent combinators in the selector.
Consider the following selector:

```css
li.selected > a:hover
```

This selector has three parts: `li.selected`, `>`, and `a:hover`. The first
part is a `SelectorPart`, the second is a `Combinator`, and the third is a
`SelectorPart`. Each `SelectorPart` is made up of an optional element name
followed by an ID, class, attribute condition, pseudo class, and/or pseudo element.

Each instance of `parserlib.css.SelectorPart` has an `elementName` property, which represents
the element name as a `parserlib.css.SelectorSubPart` object or `null` if there isn't one,
and a `modifiers` property, which is an array of `parserlib.css.SelectorSubPart` objects.
Each `SelectorSubPart` object represents the smallest individual piece of a selector
and has a `type` property indicating the type of subpart, "elementName", "class", "attribute",
"pseudo", "id", "not". If the `type` is "not", then the `args` property contains an array
of `SelectorPart` arguments that were passed to `not()`.

Each instance of `parserlib.css.Combinator` has an additional `type` property that indicates
the type of combinator: "descendant", "child", "sibling", or "adjacent-sibling".

## Using events

The CSS parser fires events as it parses text. The events correspond to important parts
of the parsing algorithm and are designed to provide developers with all of the information
necessary to create lint checkers, ASTs, and other data structures.

For many events, the `event` object contains additional information. This additional
information is most frequently in the form of a `parserlib.util.SyntaxUnit` object,
which has three properties:

1. `text` - the string value
2. `line` - the line on which this token appeared
3. `col` - the column within the line at which this token appeared

The `toString()` method for these objects is overridden to be the same value as `text`,
so that you can treat the object as a string for comparison and concatenation purposes.

You should assign your event handlers before calling the `parse()` method.

### `startstylesheet` and `endstylesheet` events

The `startstylesheet` event fires just before parsing of the CSS text begins
and the `endstylesheet` event fires just after all of the CSS text has been parsed.
There is no additional information provided for these events. Example:

```js
parser.addListener("startstylesheet", function() {
    console.log("Starting to parse stylesheet");
});

parser.addListener("endstylesheet", function() {
    console.log("Finished parsing stylesheet");
});
```

### `charset` event

The `charset` event fires when the `@charset` directive is found in a stylesheet.
Since `@charset` is required to appear first in a stylesheet, any other occurances
cause a syntax error. The `charset` event provides an `event` object with a property
called `charset`, which contains the name of the character set for the stylesheet. Example:

```js
parser.addListener("charset", function(event) {
    console.log("Character set is " + event.charset);
});
```

### `namespace` event

The `namespace` event fires when the `@namespace` directive is found in a stylesheet.
The `namespace` event provides an `event` object with two properties: `prefix`,
which is the namespace prefix, and `uri`, which is the namespace URI. Example:

```js
parser.addListener("namespace", function(event) {
    console.log("Namespace with prefix=" + event.prefix + " and URI=" + event.uri);
});
```

### `import` event

The `import` event fires when the `@import` directive is found in a stylesheet.
The `import` event provides an `event` object with two properties: `uri`,
which is the URI to import, and `media`, which is an array of media queries
for which this URI applies. The `media` array contains zero or more
`parserlib.css.MediaQuery` objects. Example:

```js
parser.addListener("import", function(event) {
    console.log("Importing " + event.uri + " for media types [" + event.media + "]");
});
```

### `startfontface` and `endfontface` events

The `startfontface` event fires when `@font-face` is encountered and the `endfontface` event
fires just after the closing right brace (`}`) is encountered after `@font-face`.
There is no additional information available on the `event` object. Example:

```js
parser.addListener("startfontface", function(event) {
    console.log("Starting font face");
});

parser.addListener("endfontface", function(event) {
    console.log("Ending font face");
});
```

### `startpage` and `endpage` events

The `startpage` event fires when `@page` is encountered and the `endpage` event
fires just after the closing right brace (`}`) is encountered after `@page`.
The `event` object has two properties: `id`, which is the page ID, and `pseudo`,
which is the page pseudo class. Example:

```js
parser.addListener("startpage", function(event) {
    console.log("Starting page with ID=" + event.id + " and pseudo=" + event.pseudo);
});

parser.addListener("endpage", function(event) {
    console.log("Ending page with ID=" + event.id + " and pseudo=" + event.pseudo);
});
```

### `startpagemargin` and `endpagemargin` events

The `startpagemargin` event fires when a page margin directive (such as `@top-left`)
is encountered and the `endfontface` event fires just after the closing right brace (`}`)
is encountered after the page margin. The `event` object has a `margin` property,
which contains the actual page margin encountered. Example:

```js
parser.addListener("startpagemargin", function(event) {
    console.log("Starting page margin " + event.margin);
});

parser.addListener("endpagemargin", function(event) {
    console.log("Ending page margin " + event.margin);
});
```

### `startmedia` and `endmedia` events

The `startmedia` event fires when `@media` is encountered and the `endmedia`
event fires just after the closing right brace (`}`) is encountered after
`@media`. The `event` object has one property, `media`, which is an array of
`parserlib.css.MediaQuery` objects. Example:

```js
parser.addListener("startpagemargin", function(event) {
    console.log("Starting page margin " + event.margin);
});

parser.addListener("endpagemargin", function(event) {
    console.log("Ending page margin " + event.margin);
});
```

### `startkeyframes` and `endkeyframes` events

The `startkeyframes` event fires when `@keyframes` (or any vendor prefixed version)
is encountered and the `endkeyframes` event fires just after the closing right brace (`}`)
is encountered after `@keyframes`. The `event` object has one property, `name`,
which is the name of the animation. Example:

```js
parser.addListener("startkeyframes", function(event) {
    console.log("Starting animation definition " + event.name);
});

parser.addListener("endkeyframes", function(event) {
    console.log("Ending animation definition " + event.name);
});
```

### `startrule` and `endrule` events

The `startrule` event fires just after all selectors on a rule have been parsed
and the `endrule` event fires just after the closing right brace (`}`)
is encountered for the rule. The `event` object has one additional property, `selectors`,
which is an array of `parserlib.css.Selector` objects. Example:

```js
parser.addListener("startrule", function(event) {
    console.log("Starting rule with " + event.selectors.length + " selector(s)");

    for (var i = 0, len = event.selectors.length; i < len; i++) {
        var selector = event.selectors[i];

        console.log("  Selector #1 (" + selector.line + "," + selector.col + ")");

        for (var j = 0, count=selector.parts.length; j < count; j++) {
            console.log("    Unit #" + (j + 1));

            if (selector.parts[j] instanceof parserlib.css.SelectorPart) {
                console.log("      Element name: " + selector.parts[j].elementName);

                for (var k = 0; k < selector.parts[j].modifiers.length; k++) {
                    console.log("        Modifier: " + selector.parts[j].modifiers[k]);
                }
            } else {
                console.log("      Combinator: " + selector.parts[j]);
            }
        }
    }
});

parser.addListener("endrule", function(event) {
    console.log("Ending rule with selectors [" + event.selectors + "]");
});
```

### `property` event

The `property` event fires whenever a CSS property (`name:value`) is encountered,
which may be inside of a rule, a media block, a page block, etc. The `event` object
has four additional properties: `property`, which is the name of the property as a
`parserlib.css.PropertyName` object, `value`, which is an instance of
`parserlib.css.PropertyValue` (both types inherit from `parserlib.util.SyntaxUnit`),
`important`, which is a Boolean value indicating if the property is flagged
with `!important`, and `invalid` which is a Boolean value indicating
whether the property value failed validation. Example:

```js
parser.addListener("property", function(event) {
    console.log("Property '" + event.property + "' has a value of '" + event.value + "' and " + (event.important ? "is" : "isn't") + " important. (" + event.property.line + "," + event.property.col + ")");
});
```

### `error` event

The `error` event fires whenever a recoverable error occurs during parsing.
When in strict mode, this event does not fire. The `event` object contains three
additional properties: `message`, which is the error message, `line`, which is the line
on which the error occurred, and `col`, which is the column on that line in which
the error occurred. Example:

```js
parser.addListener("error", function(event) {
    console.log("Parse error: " + event.message + " (" + event.line + "," + event.col + ")", "error");
});
```

## Error recovery

The CSS parser's goal is to be on-par with error recovery of CSS parsers in browsers.
To that end, the following error recovery mechanisms are in place:

* **Properties** - a syntactically incorrect property definition will be
  skipped over completely. For instance, the second property below is dropped:

```css
a:hover {
    color: red;
    font:: Helvetica;   /* dropped! */
    text-decoration: underline;
}
```

* **Selectors** - if there's a syntax error in *any* selector, the entire rule
  is skipped over. For instance, the following rule is completely skipped:

```css
a:hover, foo ... bar {
    color: red;
    font: Helvetica;
    text-decoration: underline;
}
```

* **@ Rules** - there are certain @ rules that are only valid in certain
  contexts. The parser will skip over `@charset`, `@namespace`, and `@import`
  if they're found anywhere other than the beginning of the input.

* **Unknown @ Rules** - any @ rules that isn't recognized is automatically
  skipped, meaning the entire block after it is not parsed.

## Running Tests

You can run the tests via `npm test` from the repository's root. You
may need to run `npm install` first to install the necessary dependencies.
