# http://casperjs.org/api.html#tester
casper = require('casper').create()

casper.start 'http://localhost:5000/#base', ->
  @waitForSelector('#example_code')

casper.then ->
  @echo 'renders example page'
  @test.assertSelectorHasText '#example_header', 'Base example'

casper.then ->
  @echo 'renders table'
  @test.assertExists 'table.tablestakes'
  @test.assertEval -> $('table.tablestakes tr').length > 1

casper.then ->
  @echo 'contains "Simple" in one row'
  @test.assertSelectorHasText 'table.tablestakes tr', 'Simple'

casper.run ->
  @test.renderResults(true)
