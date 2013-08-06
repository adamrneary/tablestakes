window.TableStakesLib = {} unless window.TableStakesLib
class window.TableStakesLib.Events

  constructor: (options) ->
    @core = options.core

  # keydown editing cell
  keydown: (node, d, column) ->
    switch d3.event.keyCode
      when 9  then @_handleTab(node, d, column)
      when 38 then @_handleUpDown(node, d, column,false)
      when 40 then @_handleUpDown(node, d, column,true)
      when 13 then @_handleEnter(node, d, column)
      when 27 then @_handleEscape(node, d, column)

  # move active cell left or right
  _handleTab: (node, d, column) ->
    currentindex = @core.utils.getCurrentColumnIndex d.activatedID
    # if shiftkey is not pressed, get next
    if d3.event.shiftKey is false
      index = @core.utils.findEditableColumn d,currentindex+1,true
      if index?
        @core._makeInactive node
        @blur(node, d, column)
        d.activatedID = @core.columns[index].id
      else
        nextNode = @core.utils.findNextNode d, @core.nodes
        if nextNode?
          index = @core.utils.findEditableColumn nextNode,0,true
          if index?
            @core._makeInactive node
            @blur(node, d, column)
            d.activatedID = null
            nextNode.activatedID = @core.columns[index].id
    # if shiftkey is not pressed, get previous
    else
      index = @core.utils.findEditableColumn d,currentindex-1,false
      if index?
        @core._makeInactive node
        @blur(node, d, column)
        d.activatedID = @core.columns[index].id
      else
        prevNode = @core.utils.findPrevNode d, @core.nodes
        if prevNode?
          start = @core.columns.length-1
          index = @core.utils.findEditableColumn prevNode,start,false
          @core._makeInactive node
          @blur(node, d, column)
          prevNode.activatedID = @core.columns[index].id
          d.activatedID = null
    d3.event.preventDefault()
    d3.event.stopPropagation()
    @core.update()

  # move active cell to next cell above
  _handleUpDown: (node, d, column,isUp) ->
    currentindex = @core.utils.getCurrentColumnIndex d.activatedID
    nextNode = @core.utils.findEditableCell d,column,isUp
    if nextNode?
      @blur(node, d, column)
      nextNode.activatedID = @core.columns[currentindex].id
      @core._makeInactive node
      d.activatedID = null
    @core.update()

  # record change and deactivate
  _handleEnter: (node, d, column) ->
    @blur(node, d, column)

  # reset value and deactivate
  _handleEscape: (node, d, column) ->
    d3.select(node).node().value = d[d.activatedID]
    d.activatedID = null
    @core.update()

  # record change and deactivate
  blur: (node, d, column) ->
    unless @core.table.isInRender
      val = d3.select(node).text()
      if val isnt d[column.id]
        d.changed = column.id
      unless val is d[d.activatedID]
        @_applyChangedState(d)
        @_editHandler(d, column, val)
      d.activatedID = null
      @core.update()

  _applyChangedState: (d) ->
    d.changedID ?= []
    if d.changedID.indexOf(d.activatedID) is -1
      d.changedID.push d.activatedID

  dragStart: (tr, d) ->
    @initPosition = $(tr).position()
    @_makeRowDraggable(tr)
    $(tr).css
      left: @initPosition.left
      top: @initPosition.top

  _makeRowDraggable: (tr) ->
    self = @

    rowWidth = $(tr).width()
    cellWidths = _.map $(tr).find('td'), (td) -> $(td).width()
    d3.select(tr).classed('dragged', true)
    $(tr).width(rowWidth)
    _.each $(tr).find('td'), (td, i) -> $(td).width(cellWidths[i])

    onMouseOver = (d, i) ->
      c = self.core
      self.destinationIndex = i
      isDestination = c.utils.ourFunctor(c.table.isDragDestination(), d)
      self.destination = (if isDestination then d else null)
      if isDestination
        d3.select(@).classed(self._draggableDestinationClass(), true)

    onMouseOut = (d) ->
      d3.select(@).classed(self._draggableDestinationClass(), false)

    # FIXME pointer-events: none; does not work in IE -> needs a workaround
    tableEl = @core.table.el()
    d3.selectAll(tableEl + ' tbody tr:not(.dragged)')
      .on('mouseover', onMouseOver)
      .on('mouseout', onMouseOut)

    if @core.table.dragMode() is 'reorder'
      d3.selectAll(tableEl + ' thead tr')
        .on('mouseover', onMouseOver)
        .on('mouseout', onMouseOut)

  _draggableDestinationClass: ->
    dragMode = @core.table.dragMode()
    if dragMode?
      dragMode + '-draggable-destination'
    else
      ''

  dragMove: (tr, d, x, y) ->
    $(tr).css
      left: @initPosition.left + d3.event.x
      top: @initPosition.top + d3.event.y

  dragEnd: (tr, d) ->
    d3.select(tr).classed('dragged', false)
    tableEl = @core.table.el()
    d3.selectAll(tableEl + ' tbody tr, ' + tableEl + ' thead tr')
      .classed(@_draggableDestinationClass(), false)
      .on('mouseover', null)
      .on('mouseout', null)

    if @core.table.onDrag
      onDrag = @core.table.onDrag()
      switch @core.table.dragMode()
        when 'reorder' then onDrag(d, @destinationIndex)
        when 'hierarchy' then onDrag(d, @destination)

  resizeDrag: (node) ->
    th = node.parentNode.parentNode
    index = parseFloat(d3.select(th).attr('ref'))

    thead = th.parentNode.parentNode
    allTh = []
    # select all corresponding &lt;th&gt; of every head row
    _.each thead.childNodes, (tr) ->
      allTh.push tr.childNodes[index]

    if d3.select(node).classed("right")
      old_width_left = parseFloat(d3.select(th).style("width"))
      old_width_right = parseFloat(d3.select(th.nextSibling).style("width"))
      new_width_left = d3.event.x
      new_width_right = old_width_left + old_width_right - new_width_left
    else
      old_width_left = parseFloat(d3.select(th.previousSibling).style("width"))
      old_width_right = parseFloat(d3.select(th).style("width"))
      new_width_right = old_width_right - d3.event.x
      new_width_left = old_width_left + old_width_right - new_width_right

    notTooSmall = new_width_left > @core.table._minColumnWidth and
      new_width_right > @core.table._minColumnWidth

    if notTooSmall
      _.each allTh, (th) ->
        return unless th?

      if d3.select(node).classed("right")
        d3.select(th).attr("width", new_width_left + "px")
        d3.select(th).style("width", new_width_left + "px")
        d3.select(th.nextSibling).attr("width", new_width_right + "px")
        d3.select(th.nextSibling).style("width", new_width_right + "px")
      else
        d3.select(th.previousSibling).attr("width", new_width_left + "px")
        d3.select(th.previousSibling).style("width", new_width_left + "px")
        d3.select(th).attr("width", new_width_right + "px")
        d3.select(th).style("width", new_width_right + "px")

  # change row if class editable
  editableClick: (node, d, _, unshift) ->
    target = d3.event.target
    _node = d3.select(node)
    td = d3.select(node.parentNode)
    unless td.classed('active') or $(target).is('a')
      @core.utils.deactivateAll @core.data[0]
      d.activatedID = d3.select(node.parentNode).attr("meta-key")
      @core.update()
      d3.event.preventDefault()
    d3.event.stopPropagation()

  # toggle nested
  nestedClick: (node,d, _, unshift) ->
    target = d3.event.target
    unless $(target).is('a') or d3.select(target).classed('active')
      if d3.event.shiftKey and not unshift
        # Shift-click to toggle fold all children, instead of itself
        self = @
        if d.values
          d.values.forEach (_node) ->
            if _node.values or _node._values
              self.nestedClick(this, _node, 0, true)
      else
        if d.values
          d._values = d.values
          d.values = null
        else
          d.values = d._values
          d._values = null
      @core.update()
      d3.event.preventDefault()
    d3.event.stopPropagation()

  toggleBoolean: (node, d, _, unshift, column) ->
    @_editHandler(d, column, val)
    @core.update()

  selectClick: (node, d, _, unshift, column) ->
    val = d3.event.target.value
    unless val is d[column.id]
      @_editHandler(d, column, val)
    @core.update()

  buttonClick: (node, d, _, unshift, column) ->
    val = d3.event.target.value
    column.onClick(d.id, column.id, val) if column.onClick
    @core.update()

  toggleSort: (el,column)->
    column.desc = !column.desc

    #disable sort for all columns
    d3.selectAll('.sorted-desc').classed('sorted-desc',false)
    d3.selectAll('.sorted-asc').classed('sorted-asc',false)
    d3.selectAll('th').filter (d)->
      if d.id isnt column.id
        d.desc = null

    @core.table.sort column.id, column.desc

  doubleTap: (self, a, b, c, column) ->
    # Pseudo double-click implementation
    # according to http://appcropolis.com/implementing-doubletap-on-iphones-and-ipads/
    timeDelta = 500 # time in milliseconds

    # meausure time between 2 touchend events
    now = new Date().getTime()
    self.lastTouch = if _.isUndefined(self.lastTouch) then now + 1 else self.lastTouch

    delta = now - self.lastTouch

    # trigger editable event for Cell
    if 0 < delta < timeDelta
      @editableClick(self, a, b, c, column)

    self.lastTouch = now

  _editHandler: (row, column, newValue) ->
    # Call onEdit function without changing anything if timeFrame have 12 months
    if column.timeSeries.length <= 12
      return column.onEdit(row.id, column.id, newValue) if _.isFunction column.onEdit

    # Prepare array of Unix timestamps to call onEdit function.
    # parse columnId (which is have format [firstPeriod]-[lastPeriod])
    [begin, end] = column.id.split('-')
    begin = if _.isNaN(parseInt(begin)) then undefined else parseInt(begin)
    end = if _.isNaN(parseInt(end)) then undefined else parseInt(end)
    return unless begin and end

    # Calculate 'groupper' - length of groupped months
    filteredPeriod = _.filter(column.timeSeries, (periodUnix) -> begin <= periodUnix <= end)

    # Calculate newValue. If string - pass to all months the same value
    # if Int - divided by 'groupper'
    if _.isNaN parseInt(newValue)
      dividedValue = newValue
    else
      dividedValue = parseInt(newValue) / filteredPeriod.length

    _.each filteredPeriod, (periodUnix, i) ->
      column.onEdit(row.id, periodUnix, dividedValue) if _.isFunction column.onEdit
    return