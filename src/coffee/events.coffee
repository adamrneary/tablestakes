window.TableStakesLib = {} unless window.TableStakesLib
class window.TableStakesLib.Events

  constructor: (options) ->
    @core = options.core

  # keydown editing cell
  keydown: (node, d, column) ->
    switch d3.event.keyCode
      when 9  then @_handleTab(node, d, column)
      when 38 then @_handleUp(node, d, column)
      when 40 then @_handleDown(node, d, column)
      when 13 then @_handleEnter(node, d, column)
      when 27 then @_handleEscape(node, d, column)

  # move active cell left or right
  _handleTab: (node, d, column) ->
    currentindex = @core.utils.getCurrentColumnIndex d.activatedID
    # if shiftkey is not pressed, get next
    if d3.event.shiftKey is false
      if(currentindex < @core.columns.length - 1)
        d.activatedID = @core.columns[currentindex+1].id
      else
        nextNode = @core.utils.findNextNode d, @core.nodes
        if nextNode isnt null
          nextNode.activatedID = @core.columns[0].id
          d.activatedID = null
    # if shiftkey is not pressed, get previous
    else
      if currentindex > 0
        d.activatedID = @core.columns[currentindex-1].id
      else
        prevNode = @core.utils.findPrevNode d, @core.nodes
        if prevNode isnt null
          prevNode.activatedID = @core.columns[@core.columns.length - 1].id
          d.activatedID = null
    d3.event.preventDefault()
    d3.event.stopPropagation()
    @core.update()

  # move active cell to next cell above
  _handleUp: (node, d, column) ->
    prevNode = @core.utils.findPrevNode d, @nodes
    currentindex = @core.utils.getCurrentColumnIndex d.activatedID
    if prevNode != null
      prevNode.activatedID = @core.columns[currentindex].id
      d.activatedID = null
    @core.update()

  # move active cell to next cell below
  _handleDown: (node, d, column) ->
    nextNode = @core.utils.findNextNode d
    currentindex = @core.utils.getCurrentColumnIndex d.activatedID
    if nextNode isnt null
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
    @_makeRowDraggable(tr)
    @initPosition = $(tr).position()

  _makeRowDraggable: (tr) ->
    self = @

    rowWidth = $(tr).width()
    cellWidths = _.map $(tr).find('td'), (td) -> $(td).width()
    d3.select(tr).classed('dragged', true)
    $(tr).width(rowWidth)
    _.each $(tr).find('td'), (td, i) -> $(td).width(cellWidths[i])

    onMouseOver = (d, i) ->
      self.destinationIndex = i
      if self.core.utils.ourFunctor(self.core.table.isDragDestination(), d)
        self.destinationID = d.id
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
        when 'reorder' then onDrag(d.id, @destinationIndex)
        when 'hierarchy' then onDrag(d.id, @destinationID)

  resizeDrag: (context, node, d, _, unshift) ->
    th = node.parentNode
    column_x = parseFloat(d3.select(th).attr("width"))
    column_newX = d3.event.x # x + d3.event.dx
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
