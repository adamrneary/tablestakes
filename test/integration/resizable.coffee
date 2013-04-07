{scenario, next, pending} = require('./test/casper_helper')

scenario '#resizable', 'resizable columns', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Resizable'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "Simple" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'Simple'

  pending 'wishes we could test drag and drop!'
