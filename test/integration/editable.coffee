{scenario, next} = require('./test/casper_helper')

scenario '#editable', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Editable'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'becomes active on dblclick', ->
    @mouseEvent('dblclick', 'td.editable:first-of-type')
    @test.assertEval -> $('td.editable:first-of-type').hasClass('active')
