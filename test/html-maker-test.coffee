assert = require "assert"

describe 'HtmlMaker', ->
  global.require_lib  = (name) -> require(__dirname + '/../lib/' + name)
  HtmlMaker = require_lib 'html-maker'
  ref_html = '<h1>Greetings</h1>\
    <div class="x">\
    <span class="first">hi</span>\
    <span class="second">there!</span>\
    </div>\
    <p>paragraph</p>\
    <p>yet<b>another</b>paragrah</p>'

  it "should generate html with an argumentless function", ->
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
     assert.equal html, ref_html

  it "should generate html passing the builder as an argument", ->
    view = (_) ->
      _.h1 'Greetings'
      _.div class: 'x', ->
        _.span class: 'first', 'hi'
        _.span class: 'second', 'there!'
      _.p 'paragraph'
      _.p ->
        _.text 'yet'
        _.b 'another'
        _.text 'paragrah'
     html = HtmlMaker.render_external view
     assert.equal html, ref_html

  it "should escape text", ->
    view = ->
      @div =>
        @text 'This contains characters such as < & >'
    html = HtmlMaker.render view
    assert.equal html, '<div>This contains characters such as &lt; &amp; &gt;</div>'

  it "should not escape raw text", ->
    view = ->
      @div =>
        @raw 'This contains characters such as < & >'
    html = HtmlMaker.render view
    assert.equal html, '<div>This contains characters such as < & ></div>'

  it "should accept block pass as a text element", ->
    view = ->
      @div =>
        @text 'This is the text'
    html = HtmlMaker.render view
    assert.equal html, '<div>This is the text</div>'

  it "should accept block pass as an argument", ->
    view = ->
      @div 'This is the text'
    html = HtmlMaker.render view
    assert.equal html, '<div>This is the text</div>'

  it "should handle multiple attributes", ->
    view = ->
      @div 'This is the text', class: 'cls1', id: 'id1'
    html = HtmlMaker.render view
    assert.equal html, '<div class="cls1" id="id1">This is the text</div>'

  it "should accept builder functions with arguments", ->
    view = (title, paragraph) ->
      @h1 title
      @div class: 'x', =>
        @span class: 'first', 'hi'
        @span class: 'second', 'there!'
      @p paragraph
      @p =>
        @text 'yet'
        @b 'another'
        @text 'paragrah'
     html = HtmlMaker.render view, 'Greetings', 'paragraph'
     assert.equal html, ref_html

  it "should accept...", ->
    view = (_, title, paragraph) ->
      _.h1 title
      _.div class: 'x', ->
        _.span class: 'first', 'hi'
        _.span class: 'second', 'there!'
      _.p paragraph
      _.p ->
        _.text 'yet'
        _.b 'another'
        _.text 'paragrah'
     html = HtmlMaker.render_external view, 'Greetings', 'paragraph'
     assert.equal html, ref_html
