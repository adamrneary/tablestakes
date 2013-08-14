{scenario, next} = require('./test/casper_helper')

scenario '#editable', 'editable cells', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Editable'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'becomes active on dblclick', ->
    @mouseEvent('dblclick', 'tr:nth-child(8) > td.editable:first-of-type div')
    @test.assertEval -> $('tr:nth-child(8) > td.editable:first-of-type').hasClass('active')

  next 'Change text of active editable element', ->
    # 1. change string
    # 2. event 'click'/'dblclick' on non-active element
    # 3. Check: editable element has no class 'active'
    # 4. Check: last editable element has tesString
    @test.assertEval (() ->
      $('td.editable.active div').text('Test Text String')
      $('tr:nth-child(8) > td.editable:first-of-type').text() is 'Test Text String'),
      'Text of active element becomes text of selected element'

  next 'Editable element no more active', ->
    @test.assertEval (() ->
      $('td.editable.active div').blur()
      $('tr:nth-child(8) > td.editable:first-of-type').hasClass('active') is false),
      'Editable element no more active'
    @test.assertSelectorHasText 'td.changed', 'Test Text String',
      'Editable element stores entered value'

  next 'becomes active on dblclick (other element)', ->
    @mouseEvent('dblclick', 'tr:nth-child(8) > td.editable:last-of-type div')
    @test.assertEval -> $('tr:nth-child(8) > td.editable:last-of-type').hasClass('active')

  next 'Change text of active editable element', ->
    # 1. change string
    # 2. event 'click'/'dblclick' on non-active element
    # 3. Check: editable element has no class 'active'
    # 4. Check: last editable element has tesString
    @test.assertEval (() ->
      $('td.editable.active div').text('Other Test Text String')
      $('tr:nth-child(8) > td.editable:last-of-type').text() is 'Other Test Text String'),
      'Text of active element becomes text of selected element'

  next 'Editable element no more active', ->
    @test.assertEval (() ->
      $('td.editable.active div').blur()
      $('tr:nth-child(8) > td.editable:last-of-type').hasClass('active') is false),
      'Editable element no more active'
    @test.assertSelectorHasText 'td.changed', 'Other Test Text String',
      'Editable element stores entered value'

  next 'Verify editable with formatted cells (percentage)', ->
    @mouseEvent('dblclick', 'tr:nth-child(15) > td.editable:last-of-type div')
    @test.assertEval (() ->
      $('td.editable.active').text() is "47%"
    ), 'Text of active cell formatted properly'

    @test.assertEval (() ->
      $('td.editable.active div').text('146%')
      $('td.editable.active div').blur()
      $('tr:nth-child(15) > td.editable:last-of-type div').blur()
      ($('tr:nth-child(15) > td.editable:last-of-type').hasClass('active') is false and
      $('tr:nth-child(15) > td.editable:last-of-type div').text() is "146%")
    ), "Entered '146%' formats as '146%' for not active cell, and cell has no class 'active'"

    @mouseEvent('dblclick', 'tr:nth-child(15) > td.editable:last-of-type div')
    @test.assertEval (() ->
      $('td.editable.active div').text('1')
      $('td.editable.active div').blur()
      $('tr:nth-child(15) > td.editable:last-of-type div').blur()
      ($('tr:nth-child(15) > td.editable:last-of-type').hasClass('active') is false and
      $('tr:nth-child(15) > td.editable:last-of-type div').text() is "100%")
    ), "Entered '1' formats as '100%' for not active cell, and cell has no class 'active'"

    next 'Verify editable with formatted cells (numeral)', ->
      @mouseEvent('dblclick', 'tr:nth-child(16) > td.editable:last-of-type div')
      @test.assertEval (()->
        # TODO: be awere of test version and render version
        # Current (2013-aug-13) version formats
        $('td.editable.active div').text() is "142857"
      ), 'Text of active cell formatted properly'

      @test.assertEval (() ->
        $('td.editable.active div').text('100')
        $('td.editable.active div').blur()
        $('tr:nth-child(16) > td.editable:last-of-type div').blur()
        ($('tr:nth-child(16) > td.editable:last-of-type').hasClass('active') is false and
        $('tr:nth-child(16) > td.editable:last-of-type div').text() is "$100")
      ), "Entered '100' formats as '$100' for not active cell, and cell has no class 'active'"

      @mouseEvent('dblclick', 'tr:nth-child(16) > td.editable:last-of-type div')
      @test.assertEval (()->
        # TODO: be awere of test version and render version
        # Current (2013-aug-13) version formats
        $('td.editable.active div').text() is "$100"
      ), 'Text of active cell formatted properly'

      @test.assertEval (() ->
        $('td.editable.active div').text('$200')
        $('td.editable.active div').blur()
        $('tr:nth-child(16) > td.editable:last-of-type div').blur()
        ($('tr:nth-child(16) > td.editable:last-of-type').hasClass('active') is false and
        $('tr:nth-child(16) > td.editable:last-of-type div').text() is "$200")
      ), "Entered '$200' formats as '$200' for not active cell, and cell has no class 'active'"

      @mouseEvent('dblclick', 'tr:nth-child(16) > td.editable:last-of-type div')
      @test.assertEval (()->
        $('td.editable.active div').text('1,234.5')
        $('td.editable.active div').blur()
        $('tr:nth-child(16) > td.editable:last-of-type div').blur()
        ($('tr:nth-child(16) > td.editable:last-of-type').hasClass('active') is false and
        $('tr:nth-child(16) > td.editable:last-of-type div').text() is "$1.23k")
      ), "Entered '1,234.5' formats as '$1.23k' for not active cell, and cell has no class 'active'"

      @mouseEvent('dblclick', 'tr:nth-child(16) > td.editable:last-of-type div')
      @test.assertEval (()->
        # TODO: be awere of test version and render version
        # Current (2013-aug-13) version formats
        $('td.editable.active').text() is "1234.5"
      ), 'Text of active cell formatted properly'

      @test.assertEval (()->
        $('td.editable.active div').text('$2,345.6')
        $('td.editable.active div').blur()
        $('tr:nth-child(16) > td.editable:last-of-type div').blur()
        ($('tr:nth-child(16) > td.editable:last-of-type').hasClass('active') is false and
        $('tr:nth-child(16) > td.editable:last-of-type div').text() is "$2.35k")
      ), "Entered '$2,345.6' formats as '$2.35k' for not active cell, and cell has no class 'active'"

      @mouseEvent('dblclick', 'tr:nth-child(16) > td.editable:last-of-type div')
      @test.assertEval (()->
        # TODO: be awere of test version and render version
        # Current (2013-aug-13) version formats
        $('td.editable.active').text() is "2345.6"
      ), 'Text of active cell formatted properly'

      @test.assertEval (()->
        $('td.editable.active div').text('3k')
        $('td.editable.active div').blur()
        $('tr:nth-child(16) > td.editable:last-of-type div').blur()
        ($('tr:nth-child(16) > td.editable:last-of-type').hasClass('active') is false and
        $('tr:nth-child(16) > td.editable:last-of-type div').text() is "$3k")
      ), "Entered '3k' formats as '$3k' for not active cell, and cell has no class 'active'"

      @mouseEvent('dblclick', 'tr:nth-child(16) > td.editable:last-of-type div')
      @test.assertEval (()->
        # TODO: be awere of test version and render version
        # Current (2013-aug-13) version formats
        $('td.editable.active').text() is "3000"
      ), 'Text of active cell formatted properly'

      @test.assertEval (()->
        $('td.editable.active div').text('$4k')
        $('td.editable.active div').blur()
        $('tr:nth-child(16) > td.editable:last-of-type div').blur()
        ($('tr:nth-child(16) > td.editable:last-of-type').hasClass('active') is false and
        $('tr:nth-child(16) > td.editable:last-of-type div').text() is "$4k")
      ), "Entered '$4k' formats as '$4k' for not active cell, and cell has no class 'active'"
#      @capture('weather.png', { top: 0, left: 0, width: 1600, height: 1080}) # dev purposes