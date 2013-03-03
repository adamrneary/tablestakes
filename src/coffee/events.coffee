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
        d.activatedID = @core.columns[index].id
      else
        nextNode = @core.utils.findNextNode d, @core.nodes
        if nextNode?
          index = @core.utils.findEditableColumn nextNode,0,true
          if index?
            d.activatedID = null
            nextNode.activatedID = @core.columns[index].id
    # if shiftkey is not pressed, get previous
    else
      index = @core.utils.findEditableColumn d,currentindex-1,false
      if index?
        d.activatedID = @core.columns[index].id
      else
        prevNode = @core.utils.findPrevNode d, @core.nodes
        if prevNode?
          start = @core.columns.length-1
          index = @core.utils.findEditableColumn prevNode,start,false
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
      nextNode.activatedID = @core.columns[currentindex].id
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
      unless val is d[d.activatedID]
        @_applyChangedState(d)
        column.onEdit(d.id, column.id, val) if column.onEdit
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

  resizeDrag: (context, node, d, _, unshift) ->
    th = node.parentNode
    column_x = parseFloat(d3.select(th).attr("width"))
    column_newX = d3.event.x # x + d3.event.dx
    #console.log column_newX
    d3.select(th).attr("width", column_newX + "px")
    d3.select(th).style("width", column_newX + "px")

    # TODO: re-implement old approach
    # if context.table.minWidth < column_newX
      # d3.select(th).attr("width", column_newX + "px")
      # d3.select(th).style("width", column_newX + "px")
      # index = parseInt(d3.select(th).attr("ref"))
      # context.columns[index].width = column_newX + "px"
      # table_x = parseFloat(context.tableObject.attr("width"))
      # table_newX = table_x + (column_newX - column_x) #x + d3.event.dx
      # context.tableObject.attr "width", table_newX+"px"
      # context.tableObject.style "width", table_newX+"px"

  # change row if class editable
  editableClick: (node, d, _, unshift) ->
    unless d3.select(node).classed('active')
      @core.utils.deactivateAll @core.data[0]
      d.activatedID = d3.select(d3.select(node).node()).attr("meta-key")
      @core.update()
      d3.event.stopPropagation()
      d3.event.preventDefault()

  # toggle nested
  nestedClick: (node,d, _, unshift) ->
    if d3.event.shiftKey and not unshift
      # Shift-click to toggle fold all children, instead of itself
      self = @
      if d.values
        d.values.forEach (node) ->
          self.nestedClick(this, node, 0, true) if node.values or node._values
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
    column.onEdit(d.id, column.id, not d[column.id]) if column.onEdit
    @core.update()

  selectClick: (node, d, _, unshift, column) ->
    val = d3.event.target.value
    unless val is d[column.id]
      column.onEdit(d.id, column.id, val) if column.onEdit
    @core.update()
