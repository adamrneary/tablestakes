class window.TableStakes

  # defaults
  attributes: {}
  id : Math.floor(Math.random() * 10000)
  header : true
  noData : "No Data Available."
  childIndent : 20
  _columns: [
    key: "id"
    label: "Name"
    type: "text"
  ]
  _data: []
  _el: null
  _margin :
    top: 0
    right: 0
    bottom: 0
    left: 0
  _rowClasses: null
    
  _isDeleteable: false
  _onDelete: null
  _isResizable: true

  tableClassName : "tablestakes"
  dispatch : d3.dispatch(
    "elementClick", "elementDblclick", "elementMouseover", "elementMouseout"
  )
  gridData : []
  gridFilteredData : []
  tableObject : null
  isInRender : false
  filterCondition : []

  constructor: (options) ->
    @set 'sortable', false
    @set 'filterable', false
    @set 'nested', false
    @set 'hierarchy_dragging', false
    @set 'reorder_dragging', false
    @core = new window.TableStakesLib.Core
    @filterCondition = d3.map([])
    if options?
      for key of options
        @set key, options[key]

  render: () ->
    @gridData = [values: @data()]
    @columns().forEach ( column, i) =>
      @gridData[0][column['key']] = column['key']
    @setID @gridData[0], "0"
    @gridFilteredData = @gridData
    @setFilter @gridFilteredData[0], @filterCondition
    d3.select(@el())
      .html('')
      .datum(@gridFilteredData)
      .call( (selection) => @update selection)
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
    @setFilter @gridFilteredData[0], @filterCondition
    @render()

  setFilter: ( data, filter ) ->
    self = this
    data or= []
    if typeof data._hiddenvalues == "undefined"
      data['_hiddenvalues'] = []
    if data.values
      data.values = data.values.concat(data._hiddenvalues)
      data._hiddenvalues = []
      for i in [data.values.length-1..0] by -1
        if @setFilter(data.values[i], filter) == null
          data._hiddenvalues.push(data.values.splice(i, 1)[0])
    if data._values
      data._values = data._values.concat(data._hiddenvalues)
      data._hiddenvalues = []
      for i in [data._values.length-1..0] by -1
        if @setFilter(data._values[i], filter) == null
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

  reorder_dragging: (val) ->
    if typeof val is 'boolean'
      @set 'reorder_dragging',val
    else
      @set 'reorder_dragging-filter', val

  get: (key) ->
    @attributes[key]

  set: (key, value, options) ->
    @attributes[key] = (if value? then value else true) if key?
    @

  is: (key) ->
    if @attributes[key] then true else false

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
    @_columns = val
    @

  data: (val) ->
    return @_data unless val?
    @_data = val
    @

  el: (val) ->
    return @_el unless val?
    @_el = val
    @
    
  rowClasses: (val) ->
    return @_rowClasses unless val?
    @_rowClasses = d3.functor(val)
    @

  sortable: (val) ->
    return @isSortable unless val?
    @isSortable = val
    @

  editable: (val) ->
    if typeof val is 'boolean'
      @set 'editable',val
    else
      @set 'editable-filter', val

  isDeletable: (val) ->
    return @_isDeleteable unless val?
    @_isDeleteable = val
    @

  onDelete: (val) ->
    return @_onDelete unless val?
    @_onDelete = val
    @

  isResizable: (val) ->
    return @_isResizable unless val?
    @_isResizable = val
    @

  nested: (val) ->
    if typeof val is 'boolean'
      @set 'nested',val
    else
      @set 'nested-filter', val

  boolean: (val) ->
    if typeof val is 'boolean'
      @set 'boolean',val
    else
      @set 'boolean-filter', val

  hierarchy_dragging: (val) ->
    if typeof val is 'boolean'
      @set 'hierarchy_dragging',val
    else
      @set 'hierarchy_dragging-filter', val

