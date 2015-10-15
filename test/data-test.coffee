assert = require "assert"

describe 'HtmlMaker', ->
  global.require_lib  = (name) -> require(__dirname + '/../lib/' + name)
  HtmlMaker = require_lib 'html-maker'

  it "can generate html data elements from object attributes", ->
    view = ->
      @div
        class: 'x'
        data:
          name: 'Name',
          value: 111
     html = HtmlMaker.render view
     assert.equal html, '<div class="x" data-name="Name" data-value="111"></div>'
