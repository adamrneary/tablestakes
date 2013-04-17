class window.TableStakes

  # internal table settings/variables
  id : Math.floor(Math.random() * 10000)
  header : true
  noData : "No Data Available."
  childIndent : 20
  tableClassName : "tablestakes"
  gridData : []
  gridFilteredData : []
  tableObject : null
  isInRender : false
  filterCondition : []
  dispatch : d3.dispatch(
    "elementClick", "elementDblclick", "elementMouseover", "elementMouseout"
  )

  # defaults
  _minColumnWidth: 50
  _columns: []
  _margin :
    top: 0
    right: 0
    bottom: 0
    left: 0

  constructor: (options) ->
    @core = new window.TableStakesLib.Core

    # builds getter/setter methods (initialized with defaults)
    @_synthesize
      data: []
      el: null
      isDeletable: false
      onDelete: null
      isResizable: true
      isSortable: false
      dragMode: null
      isDraggable: false
      onDrag: null
      isDragDestination: true
      rowClasses: null

    @filterCondition = d3.map([])
    if options?
      for key of options
        @set key, options[key]

  render: ->
    @gridData = [values: @data()]
    @columns().forEach (column, i) =>
      @gridData[0][column['id']] = column['id']
    @setID @gridData[0], "0"
    @gridFilteredData = @gridData
    @_setFilter @gridFilteredData[0], @filterCondition
    d3.select(@el())
      .html('')
      .datum(@gridFilteredData)
      .call( (selection) => @update selection)
    #@dispatchManualEvent(d3.select('td').node())
    @

  update: (selection) ->
    selection.each (data) =>
      @core.set
        selection: selection
        table: @
        data: data
      @core.render()

    @isInRender = false
    @

  dispatchManualEvent: (target) ->
    # all browsers except IE before version 9
    if target.dispatchEvent and document.createEvent
      mousedownEvent = document.createEvent("MouseEvent")
      mousedownEvent.initMouseEvent(
        "dblclick", true, true, window, 0, 0, 0, 0, 0,
        false, false, false, false, 0, null
      )
      target.dispatchEvent(mousedownEvent)
    else
      # IE before version 9
      if document.createEventObject
        mousedownEvent = document.createEventObject(window.event)
        # left button is down
        mousedownEvent.button = 1
        target.fireEvent("dblclick", mousedownEvent)
    return

  setID : (node, prefix) ->
    node['_id'] = prefix
    if node.values
      node.values.forEach (subnode, i) =>
        @setID subnode, prefix+"_"+i
    if node._values
      node._values.forEach (subnode, i) =>
        @setID subnode, prefix+"_"+i

  sort: (columnId, isDesc)->
    return unless columnId? or isDesc?
    sortFunction = (a,b)->
      if a[columnId]? and b[columnId]?
        if isDesc
          if a[columnId].toUpperCase() > b[columnId].toUpperCase()
            1
          else
            -1
        else
          if a[columnId].toUpperCase() < b[columnId].toUpperCase()
            1
          else
            -1
      else
        0
    @data().sort sortFunction
    @render()

  filter: (key, value) ->
    value = value or ''
    value = value.toString().toUpperCase()
    @filterCondition.set key, value
    @_setFilter @gridFilteredData[0], @filterCondition
    @render()

  _setFilter: ( data, filter ) ->
    self = this
    data or= []
    if typeof data._hiddenvalues == "undefined"
      data['_hiddenvalues'] = []
    if data.values
      data.values = data.values.concat(data._hiddenvalues)
      data._hiddenvalues = []
      for i in [data.values.length-1..0] by -1
        if @_setFilter(data.values[i], filter) == null
          data._hiddenvalues.push(data.values.splice(i, 1)[0])
    if data._values
      data._values = data._values.concat(data._hiddenvalues)
      data._hiddenvalues = []
      for i in [data._values.length-1..0] by -1
        if @_setFilter(data._values[i], filter) == null
          data._hiddenvalues.push(data._values.splice(i, 1)[0])

    if data.values and data.values.length > 0
      return data
    if data._values and data._values.length > 0
      return data

    matchFound = true
    for key in filter.keys()
      if data[key]
        #arr = d3.map data[key], (d) ->
          #d.toUpperCase()
        _data = data[key].toUpperCase()
        if _data.indexOf(filter.get(key)) == -1
          matchFound = false
      else
        matchFound = false
    if matchFound
      return data
    return null

  get: (key) ->
    @[key]

  set: (key, value, options) ->
    @[key] = (if value? then value else true) if key?
    @

  is: (key) ->
    if @[key] then true else false

  # ## Expose Public Variables

  # The following are getter/setter methods
  # See http://bost.ocks.org/mike/chart for more details.

  margin: (val) ->
    return @_margin unless val?
    for side in ['top','right','bottom','left']
      @_margin[side] = val[side] unless typeof val[side] is "undefined"
    @

  columns: (columnList) ->
    return @_columns unless columnList
    @_columns = []

    _.each columnList, (column) =>
      if column.timeSeries
        if column.timeSeries.length <= 12
          for item in column.timeSeries
            _column = _.clone column
            if column.label?
              _column.id = item
              _column.label = if typeof column.label is 'function'
              then column.label item else column.label
            else
              _column.id =  item
              _column.label = new Date(item).toDateString().split(' ')[1]
              _column.secondary = new Date(item).getFullYear().toString()
            c = new window.TableStakesLib.Column(_column)
            @_columns.push c
        else if 12 < column.timeSeries.length <= 36
          groupper = 3
          for item, i in column.timeSeries by groupper
            grouppedItems = _.first(column.timeSeries.slice(i), groupper)
            _column = _.clone column
            _column.id = [_.first(grouppedItems),_.last(grouppedItems)].join '-'
            if grouppedItems.length > 1
              _column.label = [
                new Date(_.first(grouppedItems)).toDateString().split(' ')[1],
                new Date(_.last(grouppedItems)).toDateString().split(' ')[1]
              ].join ' - '
            else
              _column.label = new Date(_.first(grouppedItems))
                .toDateString()
                .split(' ')[1]
            _column.secondary = new Date(_.last(grouppedItems))
              .getFullYear()
              .toString()
            _column.secondary = new Date(_.first(grouppedItems))
              .getFullYear()
              .toString() if i is 0
            c = new window.TableStakesLib.Column(_column)
            @_columns.push c
        else
          groupper = 12
          for item, i in column.timeSeries by groupper
            grouppedItems = _.first(column.timeSeries.slice(i), groupper)
            _column = _.clone column
            _column.id = [_.first(grouppedItems),_.last(grouppedItems)].join '-'
            if new Date(_.first(grouppedItems)).getMonth() is 0
              _column.label = "
              #{ new Date(_.first(grouppedItems)).getFullYear() }"
            else if grouppedItems.length > 1
              _column.label = "
              #{ new Date(_.first(grouppedItems)).getMonth()+1 }/
              #{ new Date(_.first(grouppedItems)).getFullYear() } -
              #{ new Date(_.last(grouppedItems)).getMonth()+1 }/
              #{ new Date(_.last(grouppedItems)).getFullYear() }"
            else
              _column.label = "
              #{ new Date(_.first(grouppedItems)).getMonth()+1 }/
              #{ new Date(_.first(grouppedItems)).getFullYear() }"

            c = new window.TableStakesLib.Column(_column)
            @_columns.push c

      else
        c = new window.TableStakesLib.Column(column)
        @_columns.push c
    @

  headRows: (filter) ->
    return @_headRows unless filter?
    # Variable:
    # _headRows - local array of head rows
    # _columns - local array of columns
    # @_columns - global array of columns
    # @_headRows - global array of head rows

    @_headRows = []

    # if filter could be applied
    if _.filter(@_columns, (col) -> _.has(col, filter)).length > 0
      # create new array of columns
      _columns = []
      _.each @_columns, (col) ->
        c = _.clone col
        if _.has(col, filter)
          c.label = col[filter]
        else
          c.label = ""
        _columns.push c

      row = new window.TableStakesLib.HeadRow(
        col: _columns
        headClasses: filter
      )
    else
      row = new window.TableStakesLib.HeadRow(
        col: []
      )

    if _.filter(@_columns, (col) -> _.has(col, 'timeSeries')).length > 0
      # special filtering rule for secondary timeSeries header
      visiblePeriod = []
      _.each row.col, (column, i) ->
        hidden = 'hidden'
        if column.timeSeries?
          if !column.classes? or column.classes.indexOf(hidden) is -1
            if _.isNumber column.id
              visiblePeriod.push column.id
            else if _.isString column.id
              begin = parseInt column.id.split('-')[0]
              end = parseInt column.id.split('-')[1]
              _.each column.timeSeries, (date) ->
                visiblePeriod.push date if begin <= date <= end

      _.each row.col, (column, i) ->
        filtered = _.filter visiblePeriod, (date) ->
          (new Date date).getFullYear().toString() is column.label
        first = _.first(filtered)
        first = _.first(visiblePeriod) unless !!first
        if _.isString(column.id)
          begin = parseInt column.id.split('-')[0]
          end = parseInt column.id.split('-')[1]
          unless begin <= first <= end
            column.label = ""
        else unless column.id is first
          column.label = ""
    # end if _.filter(@_columns, (col) -> _.has(col, 'timeSeries')).length > 0

    @_headRows.push row
    @_headRows.push new window.TableStakesLib.HeadRow(
      col: @_columns)
    @

  displayColumns: (periods,show)->
    hideColumns = (columns, periods, show) ->
      _.each columns, (column, i) ->
        if !!column.timeSeries && column.id not in periods
          hidden = 'hidden'
          column.classes = '' unless column.classes
          i1 = column.classes.indexOf(hidden)
          i2 = 'hidden'.length
          unless show
            if i1 is -1
              column.classes += ' '+hidden
          else
            if i1 isnt -1
              column.classes = column.classes.replace hidden, ''
      @

    if typeof periods is 'string'
      periods = [periods]

    if periods.length is 0
      periods = _.chain(@_columns)
        .filter( (col)-> !!col.timeSeries)
        .pluck('timeSeries')
        .first()
        .first(12)
        .value()

    show = true unless show?
    hideColumns(@_columns, periods, show)
    @

  dataAggregate: (filter) ->
    # Function of data aggregation:
    # 1. summ
    # 2. avarage                - future compatibility
    # 3. max/min                - future compatibility
    # 4. last/first             - future compatibility
    # 5. user defined function  - future compatibility
    summ = (data, availableTimeFrame) ->
      _data = []

      if availableTimeFrame.length <= 12
        return data
      else
      if 12 < availableTimeFrame.length <= 36
        groupper = 3
      else
        groupper = 12

      _.each data, (row, i) ->
        _period = []
        _dataValue = []

        start = _.indexOf row.period, _.first availableTimeFrame
        end = _.lastIndexOf row.period, _.last availableTimeFrame

        unless start is -1 or end is -1
          _slicePeriod = row.period.slice(start, end+1)
          _sliceValue = row.dataValue.slice(start, end+1)
          for val, j in _slicePeriod by groupper
            _period.push [val,_.last(_slicePeriod.slice(j,j+groupper))].join '-'
            _dataValue.push _.reduce(
              _sliceValue.slice(j, j+groupper),
            (memo, num) ->
              if _.isNumber(num) and _.isNumber(memo)
                memo+num
              else
                '-'
            , 0
            )
        else
          for val, j in availableTimeFrame by groupper
            _period.push [val,_.last availableTimeFrame[j..j+groupper]].join '-'
            _dataValue.push '-'

        _data.push
          id: i
          firstColumn: row.firstColumn
          period: _period
          dataValue: _dataValue

      _data

    @_initialData = @_data unless @_initialData
    data = @_initialData
    timeFrame = _.find(@_columns, (obj) -> obj.timeSeries?).timeSeries

    if _.isFunction(filter)
      return @
    else if filter is 'sum'
      @_data = summ(data, timeFrame)
    @

  # builds getter/setter methods (initialized with defaults)
  _synthesize: (hash) ->
    _.each hash, (value, key) =>
      @['_' + key] = value
      func = (key) =>
        @[key] = (val) ->
          return @['_' + key] unless val?
          @['_' + key] = val
          @
      func(key)
