describe 'editable table', ->
  $ = null
  window = null
  browser = null
  before (done) ->
    glob.zombie.visit glob.url+"#editable", (err, _browser) ->
      browser = _browser
      window = browser.window
      $ = window.$
      done()

  it 'example page renders', (done) ->
    header = $('#example_header').text()
    assert header is 'Editable', 'example-header '+header
    done()

  it 'renders table', (done) ->
    assert $('table.tablestakes')
    assert $('table.tablestakes tr').length > 1
    done()

  it 'click to node', (done) ->
    selector = browser.query('td.editable:first')
    browser.fire 'click', selector, ->
      assert $('td.editable:first').hasClass('active')
      done()