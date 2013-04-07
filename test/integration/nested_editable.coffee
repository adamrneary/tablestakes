{scenario, next, pending} = require('./test/casper_helper')

scenario '#nested_editable', 'nested rows', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Nested and editable'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "New Root" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'New Root'

  pending 'open first node and children visible'
    # td = $('td.expandable:first')
    # selector = browser.query('td.expandable')
    # assert $("table.tablestakes tr:contains('Simple')").length is 0
    # browser.fire 'click', selector, ->
    #   assert td.hasClass('collapsible')
    #   assert td.parent().next().find('.indent3').length is 1
    #   assert $("table.tablestakes tr:contains('Simple')").length is 1

  pending 'fold first node and children hide', ->
    # td = $('td.collapsible:first')
    # selector = browser.query('td.collapsible')
    # assert $("table.tablestakes tr:contains('Chart Components')").length is 1
    # browser.fire 'click', selector, ->
    #   assert td.hasClass('expandable')
    #   assert td.parent().next().find('.indent3').length is 0
    #   assert $("table.tablestakes tr:contains('Chart Components')").length is 0

  pending 'does not become active on click', ->
    # selector = browser.query('td.editable:first')
    # browser.fire 'click', selector, ->
    #   assert !$('td.editable:first').hasClass('active')

  pending 'becomes active on double click', ->
    # selector = browser.query('td.editable:first')
    # browser.fire 'dblclick', selector, ->
    #   assert $('td.editable:first').hasClass('active')

  pending 'records change to editable cell'
