{scenario, next} = require('./test/casper_helper')

scenario '#sortable', 'sortable rows', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Sortable'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "a" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'a'

  next 'contains "a" in first row after asc sort', ->
    @mouseEvent 'click', 'th.sortable:first-of-type'
    @test.assertEval ->
      $('tr:visible td:first').text() is "a"

  next 'contains "j" in first row after desc sort', ->
    @mouseEvent 'click', 'th.sortable:first-of-type'
    @test.assertEval ->
      $('tr:visible td:first').text() is "j"
