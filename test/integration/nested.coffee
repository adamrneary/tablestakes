{scenario, next} = require('./test/casper_helper')

scenario '#nested', 'nested rows', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Nested'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "New Root" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'New Root'

  next 'opens first node and children are visible', ->
    @test.assertSelectorDoesntHaveText 'table.tablestakes tr', 'Simple'
    @click 'td.expandable'

    @test.assertExists 'td.collapsible:first-of-type'
    @test.assertEval -> $('.indent3').length > 1
    @test.assertSelectorHasText 'table.tablestakes tr', 'Simple'

  next 'folds first node and children hide', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'Chart Components'
    @click 'td.collapsible'

    @test.assertEval -> $('.indent3').length is 0
    @test.assertSelectorDoesntHaveText 'table.tablestakes tr', 'Chart Components'
