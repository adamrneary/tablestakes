{scenario, next} = require('./test/casper_helper')

scenario '#deleteable', 'deletable rows', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Deleteable'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "Simple" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'Simple'

  next 'removes "Simple Line" on user delete', ->
    @click 'table.tablestakes tr:nth-child(3) td.deletable div'
    @test.assertSelectorDoesntHaveText 'table.tablestakes tr', 'Simple'
