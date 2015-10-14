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

class Maker
  @render: (view) ->
    builder = new Maker()
    if view.length == 1
      view builder
    else
      builder.render view
    builder.buildHtml()

  render: (view, args...) ->
    view.call this, args...

  constructor: ->
    @document = []

  buildHtml: ->
    @document.join('')

  Tags.forEach (tagName) ->
    Maker.prototype[tagName] = (args...) -> @tag(tagName, args...)

  tag: (name, args...) ->
    options = @extractOptions(args)

    @openTag(name, options.attributes)

    if SelfClosingTags.hasOwnProperty(name)
      if options.text? or options.content?
        throw new Error("Self-closing tag #{name} cannot have text or content")
    else
      options.content?()
      @text(options.text) if options.text
      @closeTag(name)

  openTag: (name, attributes) ->
    if @document.length is 0
      attributes ?= {}

    attributePairs =
      for attributeName, value of attributes when value?
        "#{attributeName}=\"#{value}\""

    attributesString =
      if attributePairs.length
        " " + attributePairs.join(" ")
      else
        ""

    @document.push "<#{name}#{attributesString}>"

  closeTag: (name) ->
    @document.push "</#{name}>"

  text: (string) ->
    if string
      escapedString = string
        .replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
      @document.push escapedString

  raw: (string) ->
    @document.push string

  extractOptions: (args) ->
    options = {}
    for arg in args
      switch typeof(arg)
        when 'function'
          options.content = arg
        when 'string', 'number'
          options.text = arg.toString()
        else
          options.attributes = arg
    options

module.exports = Maker
