{scenario, next, pending} = require('./test/casper_helper')

scenario '#editors', 'Custom cell editors', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Custom editors'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'contains "task 5" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tr', 'task 5'

  next '"select" editor', ->
    @test.assertExists 'table.tablestakes tbody td select', '"select" editor exists'
    @test.assertEval (() ->
      $('tr:nth-last-child(1) td select option').length is 3),
      '"select" editor contain 3 options'
    @test.assertEval (() ->
      $('tr:nth-last-child(1) td select').val() is 'qa'),
      'selected option is "qa"'
    @test.assertEval (() ->
      value = $('tr:nth-last-child(1) td select optgroup option:last-of-type').text()
      $('tr:nth-last-child(1) td select').val(value)
      $('tr:nth-last-child(1) td select').val() is 'design'
      ), '"select" editor value switched to last option ("design")'

  next '"Text" editor', ->
    @test.assertExist 'table.tablestakes tr td.editable'
    @click 'tr:nth-last-child(1) > td.editable:first-of-type'
    @test.assertEval (() ->
      $('tr:nth-last-child(1) > td.editable:first-of-type').hasClass('active') is false),
      'does not become active on click'
    @mouseEvent 'dblclick', 'tr:nth-last-child(1) > td.editable:first-of-type'
    @test.assertEval (() ->
      $('tr:nth-last-child(1) > td.editable:first-of-type').hasClass('active')),
      'become active on double click'

  next '"Boolean" editor', ->
    @test.assertExists 'table.tablestakes tr td[class^="boolean"]'
    @test.assertEval (() -> $('tr:nth-child(4) td:nth-child(4)').hasClass('boolean-true')),
      '"Boolean" editor is set to true'
    @click 'tr:nth-child(4) td:nth-child(4)'
    @test.assertEval (() -> $('tr:nth-child(4) td:nth-child(4)').hasClass('boolean-false')),
      '"Boolean" editor is set to switched to false'

  next '"Archive" editor (button)', ->
    @test.assertEval (() ->
      $('tr:nth-child(3) td:last-of-type').find('input[type="button"]').length > 0),
      '"Archive" editor (button) exists'
    @test.assertSelectorHasText 'table.tablestakes tr', 'task 2'
    @click 'tr:nth-child(3) td:last-of-type input[type="button"]'
    @test.assertSelectorDoesntHaveText 'table.tablestakes tr', 'task 2'

  pending 'displays a dropdown menu as requested'
  #   assert $("table.tablestakes select").length > 0
  #
  pending 'toggles boolean fields on click'
  #   selector = $("table.tablestakes tr:contains('task 1') td:last")
  #   assert selector.hasClass('boolean-false')
  #   browser.fire 'click', selector, =>
  #     assert selector.hasClass('boolean-true')
  #     browser.fire 'click', selector, =>
  #       assert selector.hasClass('boolean-false')
  #       browser.fire 'click', selector, =>
  #         assert selector.hasClass('boolean-true')
  #         done()
