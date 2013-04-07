{scenario, next} = require('./test/casper_helper')

scenario '#custom_classes', 'custom classes', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Custom classes'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "Simple" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'Simple'
