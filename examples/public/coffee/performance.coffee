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
  name: 'testDeletable'
  isDeletable: true
,
  name: 'testRender'
,
  name: 'testEditable'
  rows: 36
  columns: 12
  isDeletable: false
  isEditable: true
  configs:
    isEditable: (d,column)->
      if column.id is 'p2' or column.id is 'p5'
        if d.p2 is 1 or d.p5 is 1 or d.p2 is 4
          false
        else
          true
      else
        true
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

  testDeletable: (options)->
    @table.isDeletable(options.isDeletable).render()

  testRender: (options)->
    @table.render()

  testEditable: (options)->
    data = @generateData options.rows,options.columns, options.configs
    @table
      .isDeletable(options.isDeletable)
      .columns(data.columns)
      .data(data.data)
      .render()

$(document).ready ->
  perf = new Performance
    el: $('<div id="performance" />').appendTo('body')
    tests: tests
