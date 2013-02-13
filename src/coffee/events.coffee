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
    rowWidth = $(tr).width()
    cellWidths = _.map $(tr).find('td'), (td) -> $(td).width()
    d3.select(tr).classed('dragged', true)
    $(tr).width(rowWidth)
    _.each $(tr).find('td'), (td, i) -> $(td).width(cellWidths[i])

  OLD_dragStart: (node, d) ->
    self = @
    @draggingObj = d.id
    @draggingTargetObj = null
    @init_coord = $(node).position()
    @init_pos = d.parent.children
    @pos = $(node).position()
    @pos.left += d3.event.sourceEvent.layerX

    $(node).css
      left: @pos.left
      top: @pos.top
    d3.select(node).classed('dragged', true)
    d3.selectAll(@core.table.el() + " tbody tr:not(.dragged)")
      .on "mouseover", (d) ->
        d3.select(@).classed("draggable-destination", true)
        self.draggingTargetObj = d.id
        d3.event.stopPropagation()
        d3.event.preventDefault()
      .on "mouseout", (d) ->
        d3.select(this).classed("draggable-destination", false)
        self.draggingTargetObj = null
        d3.event.stopPropagation()
        d3.event.preventDefault()

  dragMove: (tr, d, x, y) ->
    $(tr).css
      left: @initPosition.left + d3.event.x
      top: @initPosition.top + d3.event.y

  OLD_dragMove: (tr, d) ->
    # TODO: i commented this out because it's breaking the mouseover/out above
    # $(node).css
    #   left: @pos.left + parseInt(d3.event.x)
    #   top: @pos.top + parseInt(d3.event.y)
    # @core.update()

  dragEnd: (tr, d) ->
    d3.select(tr).classed('dragged', false)
    d3.selectAll(@core.table.el() + " tbody tr")
      .classed("draggable-destination", false)
      .on("mouseover", null)
      .on("mouseout", null)

  OLD_dragEnd: (node, d) ->
    d3.select(node).classed('dragged', false)
    d3.selectAll(@core.table.el() + " tbody tr")
      .classed("draggable-destination", false)
      .on("mouseover", null)
      .on("mouseout", null)

    return if @draggingTargetObj is null
    # TODO: i think the commented line below prevents remapping to your own parent?
    # return if @draggingObj.substr(0,3) is @draggingTargetObj.substr(0,3)

    @core.table.onDrag()(@draggingObj, @draggingTargetObj) if @core.table.onDrag

  reordragstart: (node, d) ->
    self = @
    @draggingObj = d.id
    d3.select(node).classed('draggable-destination', true)

    # TODO: the below is silly. is there an easier way to handle this?
    #       as I drag the object node up and down, it should change index position
    #       within the list. I added the draggable-destination class so that the
    #       user could see it easily as it moves up and down.


    # targetRow = @core.table.el() + " tbody tr .draggable"
    # @draggingTargetObj = null
    # d3.selectAll(targetRow).on("mouseover", (d) ->
    #   return if(self.draggingObj is d._id.substring(0, self.draggingObj.length))
    #   d3.select(@parentNode).classed("draggable-destination1", true)
    #   self.draggingTargetObj = d._id
    # ).on("mouseout", (d) ->
    #   d3.select(@parentNode).classed("draggable-destination1", false)
    #   self.draggingTargetObj = null
    # )

  reordragend: (node,d) ->
    d3.select(node).classed('draggable-destination', false)
    index = 1

    # TODO: the below is a bit silly. if we make the changes above, on drop we
    #       should just need to grab the index of the object node and pass it
    #       back. done and done.


    # targetRow = @core.table.el() + " tbody tr .draggable"
    # d3.selectAll(targetRow)
    #   .on("mouseover", null)
    #   .on("mouseout", null)
    # return if @draggingTargetObj is null
    # brother = @core.utils.findNodeByID @draggingTargetObj
    # child = @core.utils.findNodeByID @draggingObj
    # @core.utils.removeNode child
    # @core.utils.pastNode brother, child
    # @core.update()

    @core.table.onDrag()(@draggingObj, index) if @core.table.onDrag

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
