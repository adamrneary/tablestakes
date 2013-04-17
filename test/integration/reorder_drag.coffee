{scenario, next, pending} = require('./test/casper_helper')

scenario '#reorder_dragging', 'dragging rows to reorder', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Reorder dragging'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "Simple" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'Simple'

  next 'contains draggable element', ->
    @test.assertExists 'table.tablestakes tbody tr td.draggable'

  pending 'wishes we could test drag and drop!'
