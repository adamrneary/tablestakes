window.TableStakesLib = {} unless window.TableStakesLib
class window.TableStakesLib.Events

  constructor: (options) ->
    @core = options.core

  # keydown editing cell
  keydown: (node, d, column) ->
    switch d3.event.keyCode
      when 9  #tab
        currentindex = @core.utils.getCurrentColumnIndex d.activatedID
        # if shiftkey is not pressed, get next
        if d3.event.shiftKey is false
          if(currentindex < @core.columns.length - 1)
            d.activatedID = @core.columns[currentindex+1].key
          else
            nextNode = @core.utils.findNextNode d, @core.nodes
            if nextNode isnt null
              nextNode.activatedID = @core.columns[0].key
              d.activatedID = null
        # if shiftkey is not pressed, get previous
        else
          if currentindex > 0
            d.activatedID = @core.columns[currentindex-1].key
          else
            prevNode = @core.utils.findPrevNode d, @core.nodes
            if prevNode isnt null
              prevNode.activatedID = @core.columns[@core.columns.length - 1].key
              d.activatedID = null
        d3.event.preventDefault()
        d3.event.stopPropagation()
        @core.update()

      when 38 #up
        prevNode = @core.utils.findPrevNode d, @nodes
        currentindex = @core.utils.getCurrentColumnIndex d.activatedID
        if prevNode != null
          prevNode.activatedID = @core.columns[currentindex].key
          d.activatedID = null
        @core.update()

      when 40 #down
        nextNode = @core.utils.findNextNode d
        currentindex = @core.utils.getCurrentColumnIndex d.activatedID
        if nextNode isnt null
          nextNode.activatedID = @core.columns[currentindex].key
          d.activatedID = null
        @core.update()

      when 13 #enter
        val = d3.select(node).text()
        column.onEdit(d.id, column.key, val) if column.onEdit
        d.changedID ?= []
        if d.changedID.indexOf(d.activatedID) is -1
          d.changedID.push d.activatedID
        d.activatedID = null
        @core.update()

      when 27 #escape
        d3.select(node).node().value = d[d.activatedID]
        d.activatedID = null
        @core.update()

  # removal of the selection from the active cell
  blur: (node, d, column) ->
    unless @core.table.isInRender
      val = d3.select(node).text()
      column.onEdit(d.id, column.key, val) if column.onEdit
      d.activatedID = null
      @core.update()

  dragstart: (node, d) ->
    self = @
    d3.select(node).classed 'dragged', true
    targetRow = @core.table.el() + " tbody tr:not(.dragged)"
    @draggingObj = d._id
    @draggingTargetObj = null
    @init_coord = $(node).position()
    @init_pos = d.parent.children
    @pos = $(node).position()
    @pos.left += d3.event.sourceEvent.layerX
    $(node).css
      left: @pos.left
      top: @pos.top
    d3.selectAll(targetRow).on("mouseover", (d) ->
      d3.select(this).classed "draggable-destination", true
      self.draggingTargetObj = d._id
      d3.event.stopPropagation()
      d3.event.preventDefault()
    ).on("mouseout", (d) ->
      d3.select(this).classed "draggable-destination", false
      self.draggingTargetObj = null
      d3.event.stopPropagation()
      d3.event.preventDefault()
    )
  dragmove: (node,d) ->
    x = parseInt(d3.event.x)
    y = parseInt(d3.event.y)
    $(node).css
      left: @pos.left + x
      top: @pos.top + y
    @core.update()

  dragend: (node, d) ->
    d.parent.children = @init_pos
    $(node).css
      left: @init_coord.left
      top: @init_coord.top
    d3.select(node).classed 'dragged', false
    targetRow = @core.table.el() + " tbody tr"
    d3.selectAll(targetRow)
    .on("mouseover", null)
    .on("mouseout", null)
    .style("background-color", null)
    return if @draggingTargetObj == null
    return if @draggingObj.substr(0,3) == @draggingTargetObj.substr(0,3)
    parent = @core.utils.findNodeByID @draggingTargetObj
    child = @core.utils.findNodeByID @draggingObj
    @core.utils.removeNode child
    @core.utils.appendNode parent, child
    @core.update()

  reordragstart: (node, d) ->
    self = @
    targetRow = @core.table.el() + " tbody tr .draggable"
    @draggingObj = d._id
    @draggingTargetObj = null
    d3.selectAll(targetRow).on("mouseover", (d) ->
      return if(self.draggingObj == d._id.substring(0, self.draggingObj.length))
      d3.select(this.parentNode).classed "draggable-destination1", true
      self.draggingTargetObj = d._id
    ).on("mouseout", (d) ->
      d3.select(this.parentNode).classed "draggable-destination1", false
      self.draggingTargetObj = null
    )

  reordragend: (node,d) ->
    targetRow = @core.table.el() + " tbody tr .draggable"
    d3.selectAll(targetRow)
    .on("mouseover", null)
    .on("mouseout", null)
    .style("background-color", null)
    return if @draggingTargetObj == null
    brother = @core.utils.findNodeByID @draggingTargetObj
    child = @core.utils.findNodeByID @draggingObj
    @core.utils.removeNode child
    @core.utils.pastNode brother, child
    @core.update()

  resizeDrag: (context,node,d, _, unshift) ->
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
  editable: (node, d, _, unshift) ->
    unless d3.select(node).classed('active')
      @core.utils.deactivateAll @core.data[0]
      d.activatedID = d3.select(d3.select(node).node()).attr("meta-key")
      @core.update()
      d3.event.stopPropagation()
      d3.event.preventDefault()

  # toggle nested
  nestedClick: (node,d, _, unshift) ->
    if d3.event.shiftKey and not unshift
      #If you shift-click, it'll toggle fold all the children, instead of itself
      #d3.event.shiftKey = false
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
