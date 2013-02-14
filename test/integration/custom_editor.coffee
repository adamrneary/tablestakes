describe 'Custom cell editors', ->
  $ = null
  window = null
  browser = null
  before (done) ->
    glob.zombie.visit glob.url+"#editors", (err, _browser) ->
      browser = _browser
      window = browser.window
      $ = window.$
      done()

  it 'renders example page', (done) ->
    header = $('#example_header').text()
    assert header is 'Custom editors', 'example-header '+header
    done()

  it 'renders table', (done) ->
    assert $('table.tablestakes')
    assert $('table.tablestakes tr').length > 1
    done()

  it 'contains "task 5" in one row', (done) ->
    assert $("table.tablestakes tr:contains('task 5')").length is 1
    done()

  it 'displays a dropdown menu as requested'
  # it 'displays a dropdown menu as requested', (done) ->
  #   assert $("table.tablestakes select").length > 0
  #
  it 'toggles boolean fields on click'
  # it 'toggles boolean fields on click', (done) ->
  #   selector = $("table.tablestakes tr:contains('task 1') td:last")
  #   assert selector.hasClass('boolean-false')
  #   browser.fire 'click', selector, =>
  #     assert selector.hasClass('boolean-true')
  #     browser.fire 'click', selector, =>
  #       assert selector.hasClass('boolean-false')
  #       browser.fire 'click', selector, =>
  #         assert selector.hasClass('boolean-true')
  #         done()
