# Minimalistic HTML builder based on space-pen
#
# Example:
#
#     Maker = require 'html-maker'
#     view = ->
#       @h1 'Greetings'
#       @div class: 'x', =>
#         @span class: 'first', 'hi'
#         @span class: 'second', 'there!'
#       @p 'paragraph'
#       @p =>
#         @text 'yet'
#         @b 'another'
#         @text 'paragrah'
#      html = Maker.render view
#
# Generates this text: (albeit without the indentation)
#
#     <h1>Greetings</h1>
#     <div class="x">
#       <span class="first">hi</span>
#       <span class="second">there!</span>
#     </div>
#     <p>paragraph</p>
#     <p>yet<b>another</b>paragrah</p>
#
# Instead of evaluating the html-building closure in the
# scope of a Maker (i.e. making this the Maker object)
# the builder can be passed as an argument to the closure:
#
#     Maker = require 'html-maker'
#     view = (html) ->
#       html.h1 'Greetings'
#       html.div class: 'x', ->
#         html.span class: 'first', 'hi'
#         html.span class: 'second', 'there!'
#       html.p 'paragraph'
#       html.p ->
#         html.text 'yet'
#         html.b 'another'
#         html.text 'paragrah'
#      html = Maker.render view
#
SelfClosingTags = {}
'area base br col command embed hr img input keygen link meta param
 source track wbr'.split(/\s+/).forEach (tag) -> SelfClosingTags[tag] = true

Tags =
  'a abbr address article aside audio b bdi bdo blockquote body button canvas
   caption cite code colgroup datalist dd del details dfn dialog div dl dt em
   fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header html i
   iframe ins kbd label legend li main map mark menu meter nav noscript object
   ol optgroup option output p pre progress q rp rt ruby s samp script section
   select small span strong style sub summary sup table tbody td textarea tfoot
   th thead time title tr u ul var video area base br col command embed hr img
   input keygen link meta param source track wbr'.split /\s+/

dasherize = (string) ->
  return '' unless string

  string = string[0].toLowerCase() + string[1..]
  string.replace /([A-Z])|(_)/g, (m, letter) ->
    if letter
      "-" + letter.toLowerCase()
    else
      "-"

class Maker
  # Execute the `view` function to render html passing the provided
  # arguments, if any. The HTML builder object is injected as `this`
  # to the function, so we'll consider this an *implicit* or *internal*
  # render.
  @render: (view, args...) ->
    builder = new this()
    builder.render view, args...
    builder.build()

  # Execute the `view` function to render html passing the provided
  # arguments, preceded by the HTML builder as a regular argument.
  # We'll call this an *explicit* or *external* render since
  # the function's `this` is not altered.
  @render_external: (view, args...) ->
    builder = new this()
    view builder, args...
    builder.build()

  render: (view, args...) ->
    view.call this, args...

  constructor: ->
    @document = []

  build: ->
    @document.join('')

  Tags.forEach (tagName) ->
    Maker.prototype[tagName] = (args...) -> @tag(tagName, args...)

  tag: (name, args...) ->
    options = @extractOptions(args)

    @openTag(name, options.attributes)

    if SelfClosingTags.hasOwnProperty(name)
      if options.text? or options.content?
        throw new Error("Self-closing tag #{name} cannot have text or content")
      @endTag(name)
    else
      options.content?()
      @text(options.text) if options.text
      @closeTag(name)

  openTag: (name, attributes) ->
    if @document.length is 0
      attributes ?= {}

    attributePairs =
      for attributeName, value of attributes when value?
        if  attributeName == 'data' && typeof(value) == 'object'
          (for dataName, dataValue of value when dataValue?
             "#{attributeName}-#{dasherize dataName}=\"#{dataValue}\""
          ).join(" ")
        else if  attributeName == 'style' && typeof(value) == 'object'
          style = (for dataName, dataValue of value when dataValue?
             "#{dasherize dataName}: #{dataValue}"
          ).join("; ")
          "style=\"#{style}\""
        else
          "#{attributeName}=\"#{value}\""

    attributesString =
      if attributePairs.length
        " " + attributePairs.join(" ")
      else
        ""

    @document.push "<#{name}#{attributesString}>"

  closeTag: (name) ->
    @document.push "</#{name}>"

  endTag: (name) ->
    ;

  rawText: (string) ->
    @document.push string

  text: (string) ->
    if string
      escapedString = string
        .replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
      @rawText escapedString

  raw: (string) ->
    @rawText string

  extractOptions: (args) ->
    options = {attributes:{}}
    if typeof(args[0]) is 'string'
      for item in args.shift().split(/(?=[#\.])/)
        switch item[0]
          when '#'
            options.attributes.id = item.slice(1)
          when '.'
            options.attributes.class = (options.attributes.class || '') + " #{item.slice(1)}"
    for arg in args
      switch typeof(arg)
        when 'function'
          options.content = arg
        when 'string', 'number'
          options.text = arg.toString()
        else
          options.attributes[k] = v for k,v of arg
    options
  
if typeof module?.exports is 'undefined'
  @HtmlMaker = Maker
else
  module.exports = Maker
