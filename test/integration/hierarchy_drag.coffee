{scenario, next, pending} = require('./test/casper_helper')

scenario '#hierarchy_dragging', 'dragging hierarchy rows', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Hierarchy dragging'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "New Root" in one row', ->
    @test.assertEval -> $("table.tablestakes tr:contains('New Root')").length is 1

  next 'contains draggable element', ->
    @test.assertExists 'table.tablestakes tbody tr td.draggable'

  pending 'wishes we could test drag and drop!'
