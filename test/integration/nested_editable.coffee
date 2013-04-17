{scenario, next, pending} = require('./test/casper_helper')

scenario '#nested_editable', 'nested rows', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Nested and editable'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "New Root" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'New Root'

  next 'open first node and children visible', ->
    @test.assertSelectorDoesntHaveText 'table.tablestakes tr', 'Simple'
    @click 'td.expandable'

    @test.assertExists 'td.collapsible:first-of-type'
    @test.assertEval -> $('.indent3').length > 1
    @test.assertSelectorHasText 'table.tablestakes tr', 'Simple'

  next 'fold first node and children hide', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'expand/collapse'
    @click 'td.collapsible'

    @test.assertEval -> $('.indent3').length is 0
    @test.assertSelectorDoesntHaveText 'table.tablestakes tr', 'expand/collapse'

  next 'does not become active on click', ->
    @click 'tr:nth-last-child(1) > td.editable:first-of-type'
    @test.assertEval -> $('tr:nth-last-child(1) > td.editable:first-of-type').hasClass('active') is false

  next 'becomes active on double click', ->
    @mouseEvent 'dblclick', 'tr:nth-last-child(1) > td.editable:first-of-type'
    @test.assertEval -> $('tr:nth-last-child(1) > td.editable:first-of-type').hasClass('active')

  next 'records change to editable cell', ->
    @test.assertEval (() ->
      $('td.editable.active').text('Test Text String')
      $('tr:nth-last-child(1) > td.editable:first-of-type').text() is 'Test Text String'),
      'Text of active element becomes text of selected element'
    @test.assertEval (() ->
      $('td.editable.active').blur()
      $('tr:nth-last-child(1) > td.editable:first-of-type').hasClass('active') is false),
      'Editable element no more active'
    @test.assertSelectorHasText 'tr:nth-last-child(1) > td.editable:first-of-type', 'Test Text String',
      'Editable element stores entered value'
