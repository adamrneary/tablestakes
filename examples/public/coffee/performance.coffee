#NOTE name of test should be same, as name of function
#additional fields will be passed to function as options object
tests = [
  name: 'testInit'
  rows: 36
  columns: 12
,
  name: 'testUpdate'
  rows: 72
  columns: 24
]

class Performance
  template: _.template \
    '''
      <div class="container">
        <hr />
        <div id="results">
          
        </div>
        <div id="example"></div>
      </div>
    '''
  constructor: (options)->
    @el = options.el
    @tests = options.tests
    @render()
    @runTest()

  render: ->
    @el.html @template()

  runTest: (counter)->
    counter = 0 unless counter?
    setTimeout =>
      start = Date.now()
      # run test
      @[@tests[counter].name] @tests[counter]
      setTimeout =>
        end = Date.now()
        @showResult end-start, @tests[counter]
        counter++
        if @tests[counter]
          @runTest(counter) 
        else
          $(@el).find('#example').hide()
      , 0
    , 0

  generateData: (rows,columns)->
    data =
      columns: []
      data: []
    for c in [1..columns]
      column = 'p'+c
      data.columns.push
        id: column
        label: column
    for p in [1..rows]
      obj = {}
      for column in data.columns
        obj[column.id] = p
      data.data.push obj
    return data

  showResult: (time, test)->
    html = '<div>'
    for p of test
      html+= "<b>#{p}</b>: #{test[p]}"
      html += '<br />'
    html += "<strong>time</strong>: #{time}ms"
    html += "<hr />"
    html += "</div>"
    $(@el).find('#results').append(html)

  testInit: (options)->
    data = @generateData options.rows,options.columns
    @table = new window.TableStakes()
      .el("#example")
      .columns(data.columns)
      .data(data.data)
      .render()

  testUpdate: (options)->
    data = @generateData options.rows, options.columns
    @table.columns(data.columns).data(data.data).render()

$(document).ready ->
  perf = new Performance
    el: $('<div id="performance" />').appendTo('body')
    tests: tests
