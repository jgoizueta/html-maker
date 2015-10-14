assert = require "assert"

describe 'HtmlMaker', ->
  global.require_lib  = (name) -> require(__dirname + '/../lib/' + name)
  HtmlMaker = require_lib 'html-maker'

  it "renders parameterless subviews", ->
    subview = ->
      @div 'subview'
    view = ->
      @div class: 'wrapper', =>
        @render subview
    html = HtmlMaker.render view
    assert.equal html, '<div class="wrapper"><div>subview</div></div>'

    subview = ->
      @div 'subview'
    view = ->
      @div class: 'before'
      @render subview
    html = HtmlMaker.render view
    assert.equal html, '<div class="before"></div><div>subview</div>'

  it "renders subviews with parameters", ->
    subview = (param) ->
      @div "subview #{param}"
    view = ->
      @div class: 'wrapper', =>
        @render subview, 'xyz'
    html = HtmlMaker.render view
    assert.equal html, '<div class="wrapper"><div>subview xyz</div></div>'

  it "can use functions as subviews", ->
    subview = (M) ->
      M.div 'subview'
    view = (M) ->
      M.div class: 'wrapper', ->
        subview M
    html = HtmlMaker.render_external view
    assert.equal html, '<div class="wrapper"><div>subview</div></div>'

    subview = (M, param) ->
      M.div "subview #{param}"
    view = (M) ->
      M.div class: 'wrapper', ->
        subview M, 'xyz'
    html = HtmlMaker.render_external view
    assert.equal html, '<div class="wrapper"><div>subview xyz</div></div>'
