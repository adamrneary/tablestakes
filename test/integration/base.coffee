zombie = require('zombie')

describe 'base table', ->
  [$, window, browser] = []

  before (done) ->
    zombie.visit glob.url+"#base", (err, _browser) ->
      browser = _browser
      window  = browser.window
      $       = window.$
      done(err)

  it 'renders example page', ->
    header = $('#example_header').text()
    assert header is 'Base example', 'example-header '+ header

  it 'renders table', ->
    assert $('table.tablestakes')
    assert $('table.tablestakes tr').length > 1

  it 'contains "Simple" in one row', ->
    assert $("table.tablestakes tr:contains('Simple')").length is 1