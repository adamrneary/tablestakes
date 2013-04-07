{scenario, next, pending} = require('./test/casper_helper')

scenario '#filterable', 'table filters', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Filterable'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "Line" in four rows', ->
    @test.assertEval -> $("table.tablestakes tr:contains('Line')").length is 4

  pending 'filters to four rows if user searches for "Line"'
  #   assert $('table.tablestakes tr').length > 6 # including header/identity
  #   browser.fill("#filter1", "Line")
  #   browser.fire 'keyup', "#filter1", ->
  #     assert $('table.tablestakes tr').length is 6 # including header/identity

  pending 'filters with case-insensitive searches'
  #   assert $('table.tablestakes tr').length > 6 # including header/identity
  #   browser.fill("#filter1", "line")
  #   browser.fire 'keyup', "#filter1", ->
  #     assert $('table.tablestakes tr').length is 6 # including header/identity