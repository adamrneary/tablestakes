describe 'table filters', ->
  $ = null
  window = null
  browser = null
  before (done) ->
    glob.zombie.visit glob.url+"#filterable", (err, _browser) ->
      browser = _browser
      window = browser.window
      $ = window.$
      done()

  it 'renders example page', (done) ->
    header = $('#example_header').text()
    assert header is 'Filterable', 'example-header '+header
    done()

  it 'renders table', (done) ->
    assert $('table.tablestakes')
    assert $('table.tablestakes tr').length > 1
    done()

  it 'contains "Line" in four rows', (done) ->
    assert $("table.tablestakes tr:contains('Line')").length is 4
    done()

  it 'filters to four rows if user searches for "Line"'
  # it 'filters to four rows if user searches for "Line"', (done) ->
  #   assert $('table.tablestakes tr').length > 6 # including header/identity
  #   browser.fill("#filter1", "Line")
  #   browser.fire 'keyup', "#filter1", ->
  #     assert $('table.tablestakes tr').length is 6 # including header/identity
  #     done()
  #
  it 'filters with case-insensitive searches'
  # it 'filters with case-insensitive searches', (done) ->
  #   assert $('table.tablestakes tr').length > 6 # including header/identity
  #   browser.fill("#filter1", "line")
  #   browser.fire 'keyup', "#filter1", ->
  #     assert $('table.tablestakes tr').length is 6 # including header/identity
  #     done()