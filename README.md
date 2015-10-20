# html-maker

 Minimalistic HTML builder based on
[space-pen](https://github.com/atom-archive/space-pen).
Intended to be used from CoffeeScript.

## Installation

```bash
npm install html-maker --save
```

## Examples:

Here's a CoffeeScript example. The html is generated by a function
that is evaluated in the scope of an HtmlMaker instance, so
it has access to methods for each HTML element through `this`:

```coffee
HtmlMaker = require 'html-maker'
view = ->
  @h1 'Greetings'
  @div class: 'x', =>
    @span class: 'first', 'hi'
    @span class: 'second', 'there!'
  @p 'paragraph'
  @p =>
    @text 'yet'
    @b 'another'
    @text 'paragrah'
html = HtmlMaker.render view
```

The generated HTML text will be as follows (albeit without the indentation):

```html
<h1>Greetings</h1>
<div class="x">
  <span class="first">hi</span>
  <span class="second">there!</span>
</div>
<p>paragraph</p>
<p>yet<b>another</b>paragrah</p>
```

Instead of evaluating the html-building closure in the
scope of an HtmlMaker (i.e. having the builder in `this`),
the builder can be passed as an argument to the closure
by using `render_external` instead of `render`:

```coffee
HtmlMaker = require 'html-maker'
view = (html) ->
  html.h1 'Greetings'
  html.div class: 'x', ->
    html.span class: 'first', 'hi'
    html.span class: 'second', 'there!'
  html.p 'paragraph'
  html.p ->
    html.text 'yet'
    html.b 'another'
    html.text 'paragrah'
html = HtmlMaker.render_external view
```

This form is more amenable to be used from JavaScript, but
still not as nice:

```javascript
var Maker = require('html-maker');
var view = function(html) {
  html.h1( 'Greetings' );
  html.div({ class: 'x' }, function() {
    html.span({ class: 'first' },  'hi' );
    html.span({ class: 'second' }, 'there!' );
  });
  html.p( 'paragraph' );
  html.p(function() {
    html.text( 'yet' );
    html.b( 'another' );
    html.text( 'paragrah' );
  });
};
var html = Maker.render_external(view);
```
### Partial view helpers

Helper methods that generate partial view can be used with
the `render` method:

```coffee
form_field = (name) ->
  @p =>
    @text name
    @text ' '
    @input type: 'text', name: name

form = (action, fields) ->
  @form action: action, =>
    for field in fields
      @render form_field, field
    @input type: 'submit', value: 'Submit'

form_html = HtmlMaker.render form, 'send.address.com', ['name', 'address']
```

Result (indented):

```html
<form action="send.address.com">
  <p>name <input type="text" name="name"></p>
  <p>address <input type="text" name="address"></p>
  <input type="submit" value="Submit">
</form>
```

If the alternative style using an `HtmlMaker` argument is desired
we could have written:

```coffee
form_field = (H, name) ->
  H.p ->
    H.text name
    H.text ' '
    H.input type: 'text', name: name

form = (H, action, fields) ->
  H.form action: action, ->
    for field in fields
      form_field H, field
    H.input type: 'submit', value: 'Submit'

form_html = HtmlMaker.render_external form, 'send.address.com', ['name', 'address']
```

Note the differences:

* No fat arrows needed (for HtmlMaker's shake, maybe they're needed for other reason)
* No internal `render` method needed

### Data attributes

Data attributes can be defined in a single `data` object:

```coffee
card = (name, address) ->
  @div data: { name: name, city: city }, =>
    @text name
console.log HtmlMaker.render card, 'John', 'Springfield'
```

Result:

```html
<div data-name="John" data-city="Springfield">John</div>
```

Which is equivalent to:

```coffee
card = (name, city) ->
  @div 'data-name': name, 'data-city': address, =>
    @text name
```

Note that data attribute names can use camelCase:

```coffee
card = (name) ->
  @div data: { personName: name }, =>
    @text name
console.log HtmlMaker.render card, 'John'
```

And they will be automaticalley dasherized:

```html
<div data-person-name="John">John</div>
```

### Style attributes

Like `data`, `style` attributes can be defined with an object
(and property names can be camelized as well):

```coffee
card = (name) ->
  @div name,
    data: { personName: name }
    style:
      textAlign:  'center',
      lineHeight: '100px'
      border:     '10px solid blue'
console.log HtmlMaker.render card, 'John'
```

The result (formatted for convenience):

```html
<div
  data-person-name="John"
  style="text-align: center; line-height: 100px; border: 10px solid blue">
  John
</div>
```
