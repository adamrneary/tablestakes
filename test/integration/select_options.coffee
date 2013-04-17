{scenario, next, pending} = require('./test/casper_helper')

scenario '#select_options', 'Custom cell editor specially for custom select options', ->
  next 'renders example page', ->
    @test.assertSelectorHasText '#example_header', 'Select Options'

  next 'renders table', ->
    @test.assertExists 'table.tablestakes'
    @test.assertEval -> $('table.tablestakes tr').length > 1

  next 'table contains "select"', ->
    @test.assertExists 'table.tablestakes tbody td select'

  next 'select options', ->
    @test.assertEval (() ->
      $('tr:nth-child(2) td select option').length is 3),
      'Category options length is 3'
    @test.assertEval (() ->
      $('tr:nth-last-child(1) td select option').length is 2),
      'Account options length is 2'

  pending 'changing select value', ->
#    @test.assertEval (() ->
#      value = $('tr:nth-last-child(1) td select optgroup option:last-of-type').text()
#      $('tr:nth-last-child(1) td select').val(value)
#      $('tr:nth-last-child(1) td select').val() is 'design'
#      ), '"select" editor value switched to last option ("design")'
