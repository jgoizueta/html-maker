assert = require "assert"

describe 'HtmlMaker', ->
  global.require_lib  = (name) -> require(__dirname + '/../lib/' + name)
  HtmlMaker = require_lib 'html-maker'

  it "can generate html style elements from object attributes", ->
    view = ->
      @div
        class: 'x'
        style:
          'text-align': 'center'
          'line-height': '100px'
          border: '1px solid red'
          width: '100px'
     html = HtmlMaker.render view
     style = "text-align: center; line-height: 100px; border: 1px solid red; width: 100px"
     assert.equal html, "<div class=\"x\" style=\"#{style}\"></div>"

  it "can handle camelized style attributes", ->
    view = ->
      @div
        class: 'x'
        style:
          textAlign: 'center'
          lineHeight: '100px'
          border: '1px solid red'
          width: '100px'
     html = HtmlMaker.render view
     style = "text-align: center; line-height: 100px; border: 1px solid red; width: 100px"
     assert.equal html, "<div class=\"x\" style=\"#{style}\"></div>"
