{scenario, next} = require('./test/casper_helper')

scenario '#custom_classes', 'custom classes', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Custom classes'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "Simple" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'Simple'

  next 'contains "classes" in table', ->
    @test.assertEval -> $('table.tablestakes td.row-heading').length > 0
    @test.assertEval -> $('table.tablestakes td.total').length > 0
    @test.assertEval -> $('table.tablestakes td.plan').length > 0
    @test.assertEval -> $('table.tablestakes tr.total2').length > 0
