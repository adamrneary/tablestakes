describe 'nested rows with editable cells', ->
  $ = null
  window = null
  browser = null
  before (done) ->
    glob.zombie.visit glob.url+"#nested_editable", (err, _browser) ->
      browser = _browser
      window = browser.window
      $ = window.$
      done()

  it 'renders example page', (done) ->
    header = $('#example_header').text()
    assert header is 'Nested and editable', 'example-header '+header
    done()

  it 'renders table', (done) ->
    assert $('table.tablestakes')
    assert $('table.tablestakes tr').length > 1
    done()

  it 'contains "New Root" in one row', (done) ->
    assert $("table.tablestakes tr:contains('New Root')").length is 1
    done()

  it 'open first node and children visible', (done) ->
    td = $('td.expandable:first')
    selector = browser.query('td.expandable')
    assert $("table.tablestakes tr:contains('Simple')").length is 0
    browser.fire 'click', selector, ->
      assert td.hasClass('collapsible')
      assert td.parent().next().find('.indent3').length is 1
      assert $("table.tablestakes tr:contains('Simple')").length is 1
      done()

  it 'fold first node and children hide', (done) ->
    td = $('td.collapsible:first')
    selector = browser.query('td.collapsible')
    assert $("table.tablestakes tr:contains('Chart Components')").length is 1
    browser.fire 'click', selector, ->
      assert td.hasClass('expandable')
      assert td.parent().next().find('.indent3').length is 0
      assert $("table.tablestakes tr:contains('Chart Components')").length is 0
      done()

  it 'does not become active on click', (done) ->
    selector = browser.query('td.editable:first')
    browser.fire 'click', selector, ->
      assert !$('td.editable:first').hasClass('active')
      done()

  it 'becomes active on double click', (done) ->
    selector = browser.query('td.editable:first')
    browser.fire 'dblclick', selector, ->
      assert $('td.editable:first').hasClass('active')
      done()


  it 'records change to editable cell'
