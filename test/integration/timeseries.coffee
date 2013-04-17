{scenario, next, pending} = require('./test/casper_helper')

scenario '#timeseries', 'timeSeries table', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Timeseries'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'renders slider', ->
    @test.assertExists 'div#sliderTimeFrame'
    @test.assertEval (() ->
      $('div#sliderTimeFrame a.ui-slider-handle').length > 0
      ), 'slider have draggable elements'

  next 'contains "row1" in one row', ->
    @test.assertSelectorHasText 'table.tablestakes tbody tr', 'row1'

  next 'contains timeSeries specified header', ->
    @test.assertSelectorHasText 'thead tr.secondary', '2013',
      'contains "2013" in secondary header'
    @test.assertSelectorHasText 'thead tr:last-of-type', 'Jan', 'contains "Jan" in header'

  next 'table contains editable cells for 12 (or less) timeSeries columns', ->
    @test.assertEval (() -> $('tbody tr:first-of-type td').length <= 12+1),
      'number of rows less than equal 12'
    @test.assertEval (() ->
      $('tbody tr:last-of-type td:last-of-type').hasClass('editable')), 'cells have "editable" class'

  next 'becomes active on dblclick', ->
    @mouseEvent('dblclick', 'tr:last-of-type > td.editable:last-of-type')
    @test.assertEval -> $('tr:last-of-type > td.editable:last-of-type').hasClass('active')


  pending 'change timeSeries interval'
