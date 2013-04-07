{scenario, next, pending} = require('./test/casper_helper')

scenario '#editors', 'Custom cell editors', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Custom editors'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "task 5" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'task 5'

  pending 'displays a dropdown menu as requested'
  #   assert $("table.tablestakes select").length > 0
  #
  pending 'toggles boolean fields on click'
  #   selector = $("table.tablestakes tr:contains('task 1') td:last")
  #   assert selector.hasClass('boolean-false')
  #   browser.fire 'click', selector, =>
  #     assert selector.hasClass('boolean-true')
  #     browser.fire 'click', selector, =>
  #       assert selector.hasClass('boolean-false')
  #       browser.fire 'click', selector, =>
  #         assert selector.hasClass('boolean-true')
  #         done()
