describe 'dragging rows to reorder', ->
  $ = null
  window = null
  browser = null
  before (done) ->
    glob.zombie.visit glob.url+"#reorder_dragging", (err, _browser) ->
      browser = _browser
      window = browser.window
      $ = window.$
      done()

  it 'renders example page', (done) ->
    header = $('#example_header').text()
    assert header is 'Reorder dragging', 'example-header '+header
    done()

  it 'renders table', (done) ->
    assert $('table.tablestakes')
    assert $('table.tablestakes tr').length > 1
    done()

  it 'contains "Simple" in one row', (done) ->
    assert $("table.tablestakes tr:contains('Simple')").length is 1
    done()

  it 'wishes we could test drag and drop!'