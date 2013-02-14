describe 'nested rows', ->
  $ = null
  window = null
  browser = null
  before (done)->
    glob.zombie.visit glob.url+"#nested", (e, _browser) ->
      browser = _browser
      window = browser.window
      $ = window.$
      done()

  it 'renders example page', (done) ->
    header = $('#example_header').text()
    assert header is 'Nested', 'example-header '+header
    done()

  it 'renders table', (done) ->
    assert $('table.tablestakes')
    assert $('table.tablestakes tr').length > 1
    done()

  it 'contains "New Root" in one row', (done) ->
    assert $("table.tablestakes tr:contains('New Root')").length is 1
    done()

  it 'opens first node and children are visible', (done) ->
    td = $('td.expandable:first')
    selector = browser.query('td.expandable')
    assert $("table.tablestakes tr:contains('Simple')").length is 0
    browser.fire 'click', selector, ->
      assert td.hasClass('collapsible')
      assert td.parent().next().find('.indent3').length is 1
      assert $("table.tablestakes tr:contains('Simple')").length is 1
      done()

  it 'folds first node and children hide', (done) ->
    td = $('td.collapsible:first')
    selector = browser.query('td.collapsible')
    assert $("table.tablestakes tr:contains('Chart Components')").length is 1
    browser.fire 'click', selector, ->
      assert td.hasClass('expandable')
      assert td.parent().next().find('.indent3').length is 0
      assert $("table.tablestakes tr:contains('Chart Components')").length is 0
      done()
