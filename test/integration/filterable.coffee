{scenario, next, pending} = require('./test/casper_helper')

scenario '#filterable', 'table filters', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Filterable'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "Line" in four rows', ->
    @test.assertEval -> $("table.tablestakes tr:contains('Line')").length is 4

  next 'filters to four rows if user searches for "Line"', ->
    @test.assertEval ->
      $('div#temp input#filter1').val('Line').keyup()
      $('table tbody tr:visible').length is 4

  next 'filters with case-insensitive searches', ->
    @test.assertEval ->
      $('div#temp input#filter1').val('HISTORICAL').keyup()
      $('table tbody tr:visible').length is 6
