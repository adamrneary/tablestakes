describe 'deletable rows', ->
  $ = null
  window = null
  browser = null
  before (done) ->
    glob.zombie.visit glob.url+"#deleteable", (err, _browser) ->
      browser = _browser
      window = browser.window
      $ = window.$
      done()

  it 'renders example page', (done) ->
    header = $('#example_header').text()
    assert header is 'Deleteable', 'example-header '+header
    done()

  it 'renders table', (done) ->
    assert $('table.tablestakes')
    assert $('table.tablestakes tr').length > 1
    done()

  it 'contains "Simple" in one row', (done) ->
    assert $("table.tablestakes tr:contains('Simple')").length is 1
    done()

  it 'removes "Simple Line" on user delete', (done) ->
    selector = browser.query("table.tablestakes tr:contains('Simple') td:last")
    browser.fire 'click', selector, ->
      assert $("table.tablestakes tr:contains('Simple')").length is 0
      done()