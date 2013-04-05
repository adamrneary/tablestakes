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
,
  name: 'testRender'
,
  name: 'timeSeriesInitial_12'
  rows: 12
  columns: 2
  timeSeries: 72
  timeFrame: 12
,
  name: 'timeSeriesInitial_36'
  rows: 12
  columns: 2
  timeSeries: 72
  timeFrame: 36
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

  result_template: _.template \
    '''
        <div class="row">
          <% for (var p in test) { %>
              <% if (typeof test[p] === 'object') { %>
                  <% for (var pp in test[p]) { %>
                    <b><%= pp %></b>: <%= test[p][pp] %>
                    <br />
                  <% } %>
              <% } else { %>
                  <b><%= p %></b>: <%= test[p] %>
                  <br />
              <% } %>
          <% } %>
          <pre> <%= code %> </pre>
          <b>time: </b><%= time %>ms
          <hr />
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
        @showResult end-start, counter
        counter++
        if @tests[counter]
          @runTest(counter)
        else
          #$(@el).find('#example').hide()
      , 0
    , 0

  showResult: (time, counter)->
    $(@el).find('#results').append @result_template
      time: time
      test: @tests[counter]
      code: @[@tests[counter].name].toString()

  generateData: (rows,columns,configs)->
    data =
      columns: []
      data: []
    for c in [1..columns]
      columnName = 'p'+c
      column =
        id: columnName
        label: columnName
      if configs
        for config of configs
          column[config] = configs[config]
      data.columns.push column
    for p in [1..rows]
      obj = {}
      for column in data.columns
        obj[column.id] = p
      data.data.push obj
    return data

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

  testRender: (options)->
    @table.render()

  timeSeriesDataGenerate: (rows, timeFrame, timeSeries) ->
    columns = [
      id: "firstColumn"
      label: "Name"
      classes: "row-heading"
    ,
      id: 'period'
      dataValue: 'dataValue'
      timeSeries: _.map(_.range(timeFrame), (m) ->
        new Date(2010, 0+m).getTime())
    ]

    period = _.map(_.range(timeSeries), (m) ->
      new Date(2010, 0+m).getTime())
    data = []

    _.each _.range(rows), (rowLabel, i) ->
      data.push
        id: i
        firstColumn: 'row '+(i+1)
        period: period
        dataValue: _.map(_.range(timeSeries), (m, j) -> i+j)

    returnValue =
      columns: columns
      data: data

  timeSeriesInitial_12: (options)->
    data = @timeSeriesDataGenerate(
      options.rows, options.timeFrame, options.timeSeries)

    @table.columns(data.columns)
      .headRows('secondary')
      .data(data.data)
      .dataAggregate('sum')
      .render()

  timeSeriesInitial_36: (options)->
    data = @timeSeriesDataGenerate(
      options.rows, options.timeFrame, options.timeSeries)

    @table.columns(data.columns)
      .headRows('secondary')
      .data(data.data)
      .dataAggregate('sum')
      .render()

$(document).ready ->
  perf = new Performance
    el: $('<div id="performance" />').appendTo('body')
    tests: tests
