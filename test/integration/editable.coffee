{scenario, next} = require('./test/casper_helper')

scenario '#editable', 'editable cells', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Editable'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'becomes active on dblclick', ->
    @mouseEvent('dblclick', 'tr:nth-last-child(7) > td.editable:first-of-type')
    @test.assertEval -> $('tr:nth-last-child(7) > td.editable:first-of-type').hasClass('active')

  next 'Change text of active editable element', ->
    # 1. change string
    # 2. event 'click'/'dblclick' on non-active element
    # 3. Check: editable element has no class 'active'
    # 4. Check: last editable element has tesString
    @test.assertEval (() ->
      $('td.editable.active').text('Test Text String')
      $('tr:nth-last-child(7) > td.editable:first-of-type').text() is 'Test Text String'),
      'Text of active element becomes text of selected element'

  next 'Editable element no more active', ->
    @test.assertEval (() ->
      $('td.editable.active').blur()
      $('tr:nth-last-child(7) > td.editable:first-of-type').hasClass('active') is false),
      'Editable element no more active'
    @test.assertSelectorHasText 'td.changed', 'Test Text String',
      'Editable element stores entered value'

  next 'becomes active on dblclick (other element)', ->
    @mouseEvent('dblclick', 'tr:nth-last-child(7) > td.editable:last-of-type')
    @test.assertEval -> $('tr:nth-last-child(7) > td.editable:last-of-type').hasClass('active')

  next 'Change text of active editable element', ->
    # 1. change string
    # 2. event 'click'/'dblclick' on non-active element
    # 3. Check: editable element has no class 'active'
    # 4. Check: last editable element has tesString
    @test.assertEval (() ->
      $('td.editable.active').text('Other Test Text String')
      $('tr:nth-last-child(7) > td.editable:last-of-type').text() is 'Other Test Text String'),
      'Text of active element becomes text of selected element'

  next 'Editable element no more active', ->
    @test.assertEval (() ->
      $('td.editable.active').blur()
      $('tr:nth-last-child(7) > td.editable:last-of-type').hasClass('active') is false),
      'Editable element no more active'
    @test.assertSelectorHasText 'td.changed', 'Other Test Text String',
      'Editable element stores entered value'

