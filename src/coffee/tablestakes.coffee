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
    @utils = new window.TableStakesLib.Utils
      core: @

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
      filterZero: false # timeSeries specific flag
      sorted: null      # timeSeries specific flag

    @filterCondition = d3.map([])
    if options?
      for key of options
        @set key, options[key]

  parseFlatData: (flatData, key) ->
    data = []
    _.each _.keys(_.groupBy(flatData, (obj) -> obj[key])),
      (productId, i) ->
        data.push
          id: i
          product_id: productId
          period_id: _.chain(flatData)
            .filter((obj) -> obj[key] is productId)
            .map((obj) -> obj.period_id)
            .value()
          period: _.chain(flatData)
            .filter((obj) -> obj[key] is productId)
            .map((obj) -> obj.periodUnix)
            .value()
          dataValue: _.chain(flatData)
            .filter((obj) -> obj[key] is productId)
            .map((obj) -> obj.actual)
            .value()
    @data(data)
    @

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
          if _.isNumber(a[columnId]) and _.isNumber(b[columnId])
            a[columnId] - b[columnId]
          else
            first = a[columnId].toString().toUpperCase()
            second = b[columnId].toString().toUpperCase()
            if first > second
              1
            else
              -1
        else
          if _.isNumber(a[columnId]) and _.isNumber(b[columnId])
            b[columnId] - a[columnId]
          else
            first = a[columnId].toString().toUpperCase()
            second = b[columnId].toString().toUpperCase()
            if first < second
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
    @_headRows = null

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
              _column.label = new Date(item).toGMTString().split(' ')[2]
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
                new Date(_.first(grouppedItems)).toGMTString().split(' ')[2],
                new Date(_.last(grouppedItems)).toGMTString().split(' ')[2]
              ].join ' - '
            else
              _column.label = new Date(_.first(grouppedItems))
                .toGMTString()
                .split(' ')[2]
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
      @_headRows = null
      return @

    if _.filter(@_columns, (col) -> _.has(col, 'timeSeries')).length > 0
      # special filtering rule for secondary timeSeries header
      visiblePeriod = []
      _.each row.col, (column, i) ->
        hidden = 'hidden'
        if column.timeSeries
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

  dataAggregate: (aggregator) ->
    # Function of data aggregation:
    # 1. summ
    # 2. avarage                - future compatibility
    # 3. max/min                - future compatibility
    # 4. last/first             - future compatibility
    # 5. user defined function  - future compatibility
    self = @
    aggregator = [aggregator] unless _.isArray aggregator

    summ = (data, availableTimeFrame) ->
      _data = []

      if availableTimeFrame.length <= 12
        return data
      else if 12 < availableTimeFrame.length <= 36
        groupper = 3
      else
        groupper = 12

      _.each data, (row, i) ->
#        unless row.period? and row.period.length
#          return
        _period = []
        _period_id = []
        _dataValue = []

        start = _.indexOf row.period, _.first availableTimeFrame
        end = _.indexOf row.period, _.last availableTimeFrame

        unless start is -1 or end is -1
          _slicePeriod = if row.period.length then row.period.slice(start, end+1) else []
          _slicePeriodId = if row.period_id.length then row.period_id.slice(start, end+1) else []
          _sliceValue = if row.dataValue.length then row.dataValue.slice(start, end+1) else []
          for val, j in _slicePeriod by groupper
            _period.push [val,_.last(_slicePeriod.slice(j,j+groupper))].join '-'
            _period_id.push [_.first(_slicePeriodId.slice(j,j+groupper)),_.last(_slicePeriodId.slice(j,j+groupper))].join '-'
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
            _period_id.push [_.first(row.period_id.slice(j,j+groupper)),_.last(row.period_id.slice(j,j+groupper))].join '-'
            _dataValue.push '-'

        _row = _.clone(row)
        _row.period_id = _period_id
        _row.period = _period
        _row.dataValue = _dataValue

        _data.push _row

      _data

    timeFrame = _.find(@_columns, (obj) -> obj.timeSeries?).timeSeries
    return unless timeFrame

    isZeroFilter = _.find(@_columns, (col) => @utils.ourFunctor(col.filterZero))?.filterZero
    @filterZeros(@data()) if isZeroFilter
    isSorted = _.find(@_columns, (col) => @utils.ourFunctor(col.sorted))?.sorted
    @sorter(@data()) if isSorted

    data = @data()

    _.each aggregator, (filter) ->
      if _.isFunction(filter)
        data = filter(data, timeFrame)
      else if filter is 'sum'
        data = summ(data, timeFrame)
      else if filter is 'zero'
        data = filterZero(data, timeFrame)

      self.data data

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

  filterZeros: (data) ->
    # timeSeries specific function. return if no timeSeries 'columns'
    cols = _.filter @_columns, (col) -> col.timeSeries?
    return unless cols.length

    availableTimeFrame = _.first(cols).timeSeries
    filteredData = data

    filteredData = _.filter filteredData, (row, i) ->
      begin = _.indexOf row.period, _.first(availableTimeFrame)
      end = _.indexOf row.period, _.last(availableTimeFrame)
      if begin < 0 or end < 0 or end < begin
        return false
      _.some(row.dataValue[begin..end], (val) -> val)

    @data filteredData
    @

  sorter: (data) ->
    # timeSeries specific function. return if no timeSeries 'columns'
    cols = _.filter @_columns, (col) -> col.timeSeries?
    return unless cols.length

    availableTimeFrame = _.first(cols).timeSeries
    sortedData = data
    sorted = _.find(@_columns, (col) -> col.sorted)?.sorted

    sortedData = _.sortBy sortedData, (row) ->
      begin = _.indexOf row.period, _.first(availableTimeFrame)
      end = _.indexOf row.period, _.last(availableTimeFrame)
      if begin < 0 or end < 0 or end < begin
        return 0
      sum = _.reduce row.dataValue[begin..end], ((memo, num) -> memo+num), 0
      if sorted is 'asc'
        sum
      else if sorted is 'desc'
        sum*-1

    @data sortedData
    @