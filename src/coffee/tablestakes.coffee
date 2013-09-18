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

  # Constructor, getter, and setter methods
  # ---------------------------------------

  constructor: (options) ->
    @core = new window.TableStakesLib.Core
    @utils = new window.TableStakesLib.Utils
      core: @

    # builds getter/setter methods (initialized with defaults)
    @_synthesize
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

  # builds getter/setter methods (initialized with defaults)
  #
  # for example, if the hash includes {isSortable: false} then:
  #   1. you get @_isSortable as an internal variable
  #   2. you get @isSortable() as an external getter method
  #   3. you get @isSortable(true) as an external setter method
  #
  # See http://bost.ocks.org/mike/chart for more details.
  _synthesize: (hash) ->
    _.each hash, (value, key) =>
      
      # create and set the internal variable
      @['_' + key] = value
      
      # save the function so that it can be called below
      func = (key) =>
        
        # create the getter/setter function
        @[key] = (val) ->
          
          # get the internal value if it is not being set
          return @['_' + key] unless val?
          
          # else set the variable
          @['_' + key] = val
          
          # return @ to make the method chainable
          @
      
      # call the method a first time to set the default
      func(key)

  # DEPRECATED: Use methods built by _synthesize
  get: (key) ->
    @[key]

  # DEPRECATED: Use methods built by _synthesize
  set: (key, value, options) ->
    @[key] = (if value? then value else true) if key?
    @

  # DEPRECATED: Use methods built by _synthesize
  is: (key) ->
    if @[key] then true else false

  # Margins have a custom getter/setter because it builds the 4 sides into one
  # method just like css does
  margin: (val) ->
    
    # get _margin if it is not being set
    return @_margin unless val?
    
    # else set _margin
    for side in ['top','right','bottom','left']
      @_margin[side] = val[side] unless typeof val[side] is "undefined"
    
    # return @ to make the method chainable
    @

  # Set 'max-height' attr for table wrapper element
  height: (height) ->
    return @_height || false if _.isUndefined(height)
    @_height = height
    # return @ to make the method chainable
    @

  # Set 'max-width' attr for table wrapper element
  width: (width) ->
    return @_width || false if _.isUndefined(width)
    @_width = width
    # return @ to make the method chainable
    @

  # Set data
  data: (arr) ->
    # get the internal value if it is not being set
    return @_data || [] unless arr?

    # create and set the internal variable
    @_data = arr

    # extend data array
    _.each _.filter(@_columns, (col) -> col.type is "total"), (col) =>
      @_extendToTotalColumn(col)

    # return @ to make the method chainable
    @

  # Columns have a custom getter/setter because of their inherent complexity
  columns: (columnList) ->
    # get _columns if they are not being set
    return @_columns unless columnList
    
    # clear @_columns and @_headrows because this method does not allow you
    # to incrementally add columns. the method is a full reset
    @_columns = []
    @_headRows = null

    # create a column for each in the list
    _.each columnList, (column) =>
      
      # Time series columns have all sorts of magical complexity. 
      # TODO: The following trickery should be refactored into another method
      # because it isn't a simple part of the idea of setting columns
      if column.timeSeries
      
        # If there are 12 or fewer periods to display, we will display monthly
        # data with no grouping and aggregation
        if column.timeSeries.length <= 12
          for item in column.timeSeries

            # TODO: what is this below?
            _column = _.clone column
            _column._id = column.id
            _column.id =  item
            if column.label?
              _column.label = if typeof column.label is 'function'
              then column.label item else column.label
            else
              _column.label = new Date(item).toGMTString().split(' ')[2]
              _column.secondary = new Date(item).getFullYear().toString()
              
            # create and push the column
            c = new window.TableStakesLib.Column(_column)
            @_columns.push c
            
        # Else if there are 36 or fewer periods to display, we will display 
        # quarterly data and aggregate
        else if 12 < column.timeSeries.length <= 36
          grouper = 3
          for item, i in column.timeSeries by grouper
            grouppedItems = _.first(column.timeSeries.slice(i), grouper)
            _column = _.clone column
            _column._id = column.id
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

        # If there are more than 36 columns to display, we will display annual 
        # data and aggregate.
        #
        # TODO: We should probably explode gracefully if there are more than 
        # 144 periods to display
        else
          grouper = 12
          for item, i in column.timeSeries by grouper
            grouppedItems = _.first(column.timeSeries.slice(i), grouper)
            _column = _.clone column
            _column._id = column.id
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

      # This 'else if' is for columns that should calculate sum of all other
      # columns with id = column.related
      else if column["type"] is "total"
        c = new window.TableStakesLib.Column(column)
        @_columns.push c

        @_extendToTotalColumn(column)

      # This 'else' is for columns that are not time series. It will get lost
      # less easily if the time series stuff is refactored to a new method
      else
        c = new window.TableStakesLib.Column(column)
        c._id = c.id
        @_columns.push c

    # return @ to make the method chainable
    @
    
  # TODO: this method needs a lot of documentation
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
    
    # return @ to make the method chainable
    @

  # TODO: this method needs a lot of documentation
  parseFlatData: (flatData, idKey) ->
    data = []
    groupedById = _.groupBy(flatData, (obj) -> obj[idKey])
    _.each _.keys(groupedById), (itemId, i) ->
      item = {id: i}
      item[idKey] = itemId
      item["period_id"] = _.pluck(groupedById[itemId], "period_id")
      item["period"] = _.pluck(groupedById[itemId], "periodUnix")
      item["dataValue"] = _.pluck(groupedById[itemId], "actual")
      data.push item
    @data(data)

    # return @ to make the method chainable
    @


  # Render/update methods
  # ---------------------
    
  # TODO: this method needs a lot of documentation
  render: ->
    @gridData = [values: @data()]
    @columns().forEach (column, i) =>
      @gridData[0][column['id']] = column['id']
    @setID @gridData[0], "0"
    @gridFilteredData = @gridData
    @_setFilter @gridFilteredData[0], @filterCondition
    wrap = d3.select(@el())
      .html('')

    wrap.datum(@gridFilteredData)
      .call( (selection) => @update selection)
    #@dispatchManualEvent(d3.select('td').node())
    
    # return @ to make the method chainable
    @

  # TODO: this method needs a lot of documentation
  update: (selection) ->
    selection.each (data) =>
      @core.set
        selection: selection
        table: @
        data: data
      @core.render()

    @isInRender = false
    
    # return @ to make the method chainable
    @

  # TODO: this method needs a lot of documentation
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

  # TODO: this method needs a lot of documentation
  setID : (node, prefix) ->
    node['_id'] = prefix
    if node.values
      node.values.forEach (subnode, i) =>
        @setID subnode, prefix+"_"+i
    if node._values
      node._values.forEach (subnode, i) =>
        @setID subnode, prefix+"_"+i


  # Simple sort and filter (not time series) methods
  # ------------------------------------------------
        
  # TODO: this method needs a lot of documentation
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
    # TODO: make it recursive
    sortRecursive = (data) =>
      _data = _.map data, (row) ->
        if row['values']?
          row.values = sortRecursive(row.values)
        if row['_values']?
          row._values = sortRecursive(row._values)
        row
      _data.sort sortFunction
      _data

    if _.find(@data(), (row) -> ('values' in _.keys(row)) or ('_values' in _.keys(row)))
      @data sortRecursive(@data())
    else
      @data().sort sortFunction
    @render()

  # This method simply provides an external interface for the internal 
  # _setFilter function
  filter: (keys, value) ->
    value = value or ''
    value = value.toString().toUpperCase()
    keys = [keys] unless _.isArray(keys)
    _.each keys, (key) =>
      @filterCondition.set key, value
    @_setFilter @gridFilteredData[0], @filterCondition
    
    # TODO: Should this be @update() ? It seems in other areas we use update,
    # which seems lighter. Not sure.
    @render()

  # TODO: this method needs a lot of documentation
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

    isDragDestination = @isDraggable() and @utils.ourFunctor(@isDragDestination(), data)
    if (data.values and data.values.length) or isDragDestination
      return data
    if (data._values and data._values.length) or isDragDestination
      return data

    matchFound = true
    for key in filter.keys()
      if data[key]
        _data = data[key].toString().toUpperCase()
        if _data.indexOf(filter.get(key)) == -1
          matchFound = false
        else
          matchFound = true
      else
        matchFound = false
      break if matchFound
    if matchFound
      return data
    return null

  # Time series methods
  # -------------------

  # This method defines how data will be aggregated in the event that a column
  # is time series and more than 12 periods are to be displayed.
  #
  # For example, if you're looking at revenue figures:
  #     * Jan: 100
  #     * Feb: 200
  #     * Mar: 300
  #
  # Aggregating using the "sum" method provides:
  #     * Jan-Mar: 600
  #
  # However, if the figures were inventory figures (e.g. how many apples do I 
  # have at the end of each month?), you cannot add those figures. Because if 
  # you have:
  #     * Jan: 100 apples in stock
  #     * Feb: 200 apples in stock
  #     * Mar: 300 apples in stock
  #
  # Aggregating using last would say:
  #     * Jan-Mar: 300 apples in stock (not 600!)
  #
  # TODO: this method needs a lot of documentation
  # TODO: we could probably afford to refactor this into its own module and 
  # just use dataAggregate() as a getter/setter
  dataAggregate: (aggregator) ->
    # Function of data aggregation:
    # 1. sum
    # 2. first/last
    # 3. avarage                - future compatibility
    # 4. max/min                - future compatibility
    # 5. user defined function
    self = @
    aggregator = [aggregator] unless _.isArray aggregator

    # Aggregator functions
    sum = (data, availableTimeFrame) ->
      _data = []

      if availableTimeFrame.length <= 12
        return data
      else if 12 < availableTimeFrame.length <= 36
        grouper = 3
      else
        grouper = 12

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
          for val, j in _slicePeriod by grouper
            _period.push [val,_.last(_slicePeriod.slice(j,j+grouper))].join '-'
            _period_id.push [_.first(_slicePeriodId.slice(j,j+grouper)),_.last(_slicePeriodId.slice(j,j+grouper))].join '-'
            _dataValue.push _.reduce(
              _sliceValue.slice(j, j+grouper),
            (memo, num) ->
              if _.isNumber(num) and _.isNumber(memo)
                memo+num
              else
                '-'
            , 0
            )
        else
          for val, j in availableTimeFrame by grouper
            _period.push [val,_.last availableTimeFrame[j..j+grouper]].join '-'
            _period_id.push [_.first(row.period_id.slice(j,j+grouper)),_.last(row.period_id.slice(j,j+grouper))].join '-'
            _dataValue.push '-'

        _row = _.clone(row)
        _row.period_id = _period_id
        _row.period = _period
        _row.dataValue = _dataValue

        if _row['values']?
          _row['values'] = sum(_row['values'], availableTimeFrame)
        else if _row['_values']?
          _row['_values'] = sum(_row['_values'], availableTimeFrame)

        _data.push _row

      _data

    # TODO: this method needs a lot of documentation
    # TODO: we could probably afford to refactor this into a module with the 
    # rest of the aggregation stuff
    first_last = (flag, data, availableTimeFrame) ->
      _data = []

      if availableTimeFrame.length <= 12
        return data
      else if 12 < availableTimeFrame.length <= 36
        grouper = 3
      else
        grouper = 12

      _.each data, (row, i) ->
        _period = []
        _period_id = []
        _dataValue = []

        start = _.indexOf row.period, _.first availableTimeFrame
        end = _.indexOf row.period, _.last availableTimeFrame

        unless start is -1 or end is -1
          _slicePeriod = if row.period.length then row.period.slice(start, end+1) else []
          _slicePeriodId = if row.period_id.length then row.period_id.slice(start, end+1) else []
          _sliceValue = if row.dataValue.length then row.dataValue.slice(start, end+1) else []

          for val, j in _slicePeriod by grouper
            _period.push [val,_.last(_slicePeriod.slice(j,j+grouper))].join '-'
            _period_id.push [_.first(_slicePeriodId.slice(j,j+grouper)),_.last(_slicePeriodId.slice(j,j+grouper))].join '-'
            switch flag
              when 'first' then _dataValue.push _.first _sliceValue.slice(j,j+grouper)
              when 'last' then _dataValue.push _.last _sliceValue.slice(j,j+grouper)
              else _dataValue.push '-'
        else
          for val, j in availableTimeFrame by grouper
            _period.push [val,_.last availableTimeFrame[j..j+grouper]].join '-'
            _period_id.push [_.first(row.period_id.slice(j,j+grouper)),_.last(row.period_id.slice(j,j+grouper))].join '-'
            _dataValue.push '-'

        _row = _.clone(row)
        _row.period_id = _period_id
        _row.period = _period
        _row.dataValue = _dataValue

        if _row['values']?
          _row['values'] = first_last(_row['values'], availableTimeFrame)
        else if _row['_values']?
          _row['_values'] = first_last(_row['_values'], availableTimeFrame)

        _data.push _row

      _data

    # End of Aggreagtor functions

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
        data = sum(data, timeFrame)
      else if filter is 'zero'
        data = filterZero(data, timeFrame)
      else if filter in ['first', 'last']
        data = first_last(filter, data, timeFrame)

      self.data data

    # return @ to make the method chainable
    @


  # TODO: this method needs a lot of documentation
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
    
    # return @ to make the method chainable
    @

  # TODO: this method needs a lot of documentation
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

    # return @ to make the method chainable
    @

  # Add one more item (cell / column) to every row as sum of all related columns
  _extendToTotalColumn: (column) ->
    return @ unless column?
    return @ unless @_columns

    data = @data()
    return @ unless data.length

    column.related = [column.related] unless _.isArray column.related
    relatedColumns = []
    for pointer in column.related
      relatedColumn = _.find @_columns, (col) -> col._id is pointer
      continue unless relatedColumn?
      relatedColumns.push relatedColumn
    return @ unless relatedColumns.length

    # we should care about only 1 example for each total column
    data = _.map data, (row) ->
      # exclude "total column" from row
      row = _.omit row, column.id

    for relatedColumn in relatedColumns
      if relatedColumn["timeSeries"]?

        timeRange = relatedColumn.timeSeries
        if timeRange.length in [0, 1]
          @_columns = (_.filter @_columns, (col) -> col.id isnt column.id) if relatedColumns.length is 1
          continue

        _.each data, (row) ->
          if timeRange.length > 12
            row[column.id] = (row[column.id] || 0) + _.reduce row.dataValue, ((memo, value) ->
              memo + value
            ), 0
          else
            row[column.id] = (row[column.id] || 0) + _.reduce timeRange, ((memo, timeStamp) ->
              index = row.period.indexOf(timeStamp)

              unless index is -1
                value = row.dataValue[index]
              else
                value = 0
              memo + value
            ), 0

      else if relatedColumns.length > 1
        row[column.id] = (row[column.id] || 0) + row[relatedColumn.id]
      else
        @_columns = _.filter @_columns, (col) -> col.id isnt column.id

    @_data = data
    # return @ to make the method chainable
    @
