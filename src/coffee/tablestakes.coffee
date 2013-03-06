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

  columns: (val) ->
    return @_columns unless val?
    @_columns = []
    val = [val] unless _.isArray(val)
    _.each val, (column) =>
      if column.timeSeries
        for label in column.timeSeries
          _column = _.clone column
          _column.id = label
          if typeof column.label is 'function'
            _column.label = column.label(label)
          else
            _column.label = label
          c = new window.TableStakesLib.Column(_column)
          @_columns.push c
      else
        c = new window.TableStakesLib.Column(column)
        @_columns.push c
    @

  displayColumns: (periods,show)->
    if typeof periods is 'string'
      periods = [periods]
    return unless periods[0]
    show = true unless show?
    for column in @_columns
      for period in periods
        if column.id is period
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
          break
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
