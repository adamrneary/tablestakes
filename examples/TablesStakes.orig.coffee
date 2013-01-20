class window.TablesStakes
  margin :
    top: 0
    right: 0
    bottom: 0
    left: 0

  width : 960
  height : 500
#  color : nv.utils.defaultColor()
  id : Math.floor(Math.random() * 10000)
  header : true
  noData : "No Data Available."
  childIndent : 20
  columns : [
    key: "key"
    label: "Name"
    type: "text"
  ]
  tableClassName : "class"
  iconOpenImg : "images/grey-plus.png"
  iconCloseImg : "images/grey-minus.png"
  dispatch : d3.dispatch("elementClick", "elementDblclick", "elementMouseover", "elementMouseout")
  columnResize : true
  
  isSortable : true
  isEditable : true
  hasDeleteColumn : true
  isFilterable : true
  
  gridData : []
  gridFilteredData : []
  tableObject : null
  minWidth : 50
  tableWidth : 0
  containerID : null
  
  isInRender : false
  filterCondition : []
  
  dispatchManualEvent: (target)->
    if target.dispatchEvent and document.createEvent                                       # all browsers except IE before version 9
      mousedownEvent = document.createEvent("MouseEvent")
      mousedownEvent.initMouseEvent("dblclick", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)
      target.dispatchEvent(mousedownEvent)
    else
      if document.createEventObject                                                       # IE before version 9
        mousedownEvent = document.createEventObject(window.event)
        mousedownEvent.button = 1                                                         # left button is down
        target.fireEvent("dblclick", mousedownEvent)
    return
  setID : (node, prefix) ->
    node['_id'] = prefix
    self = this
    if node.values
      node.values.forEach (subnode, i) ->
        self.setID subnode, prefix+"_"+i
    if node._values
      node._values.forEach (subnode, i) ->
        self.setID subnode, prefix+"_"+i
  setFilter: ( data, filter ) ->
    self = this
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
        if data[key].indexOf(filter.get(key)) == -1
           matchFound = false
      else
        matchFound = false
    if matchFound
      return data            
    return null
  render: (_) ->
    self = this
    @gridData = [values: @gridData]
    @columns.forEach ( column, i) ->
      self.gridData[0][column['key']] = column['key'] 
    @setID(self.gridData[0], "0")
    @gridFilteredData = @gridData
    @setFilter( @gridFilteredData[0], @filterCondition)
    @containerID = _
    d3.select(_).datum(self.gridFilteredData).call( (__) -> self.doRendering __ )
    return this
  calculateTableWidth: () ->
    width = 0
    @columns.forEach (column, index) ->
      width += parseInt(column.width)
    @tableWidth = width
    width
    
  doRendering: (selection) -> 
    self = this
    drag = d3.behavior.drag()
      .on("drag", (d, i) ->
        th = d3.select(this).node().parentNode
        column_x = parseFloat(d3.select(th).attr("width"))
        column_newX = d3.event.x # x + d3.event.dx
        if self.minWidth < column_newX
          d3.select(th).attr("width", column_newX + "px")
          index = parseInt(d3.select(th).attr("ref"))
          self.columns[index].width = column_newX + "px";
          table_x = parseFloat(self.tableObject.attr("width"))
          table_newX = table_x + (column_newX - column_x) #x + d3.event.dx 
          self.tableObject.attr "width", table_newX+"px"
      )
    editCell = (d, i) ->
      cell = d3.select(this)
      htmlContent = d3.select(this).text()

      columnKey = d3.select(this)[0][0].parentNode.getAttribute("ref")
      d3.select(this).text("");
      d3.select(this).append("input").attr("type","text")
        .attr("value", htmlContent)
        .on("keydown", ()->
          ###
          nextCell = null
          if d3.event.keyCode == 9                                                         # tab key down
            d3.event.preventDefault()
            d3.event.stopPropagation()
            if d3.event.shiftKey == false                                                  # if shiftkey is not pressed, get next 
              nextCell = cell.node().parentNode.nextSibling
              if nextCell == null
                nextCell = cell.node().parentNode.parentNode.nextSibling
              if nextCell != null
                nextCell = d3.select(nextCell).selectAll(".name").node()
            else                                                                           # if shiftkey is not pressed, get previous
              nextCell = cell.node().parentNode.previousSibling
              if nextCell == null
                nextCell = cell.node().parentNode.parentNode.previousSibling
              if nextCell != null
                prevRow = d3.select(nextCell).selectAll(".name")[0]
                nextCell = prevRow[prevRow.length-1]
          else if d3.event.keyCode == 38                                                   # upward key pressed 
            nextRow = cell.node().parentNode.parentNode.previousSibling
            console.log(d, i)
          else if d3.event.keyCode == 40                                                   # downward key pressed
            nextRow = cell.node().parentNode.parentNode.nextSibling
            console.log(d, i)
          if nextCell != null
            self.dispatchManualEvent nextCell
          return 
          ###
        )
        .on("keyup", ()->
          ###
          switch d3.event.keyCode
            when 13 # enter key down
              cell.text(d3.select(this).node().value)
              d[columnKey]=d3.select(this).node().value              
            when 27 # escape key down
              d3.select(this).node().value = d[columnKey]
              cell.text(d[columnKey])
          return
          ###
          )
        .on("blur", ()->
          cell.text(d3.select(this).node().value)
          d[columnKey]=d3.select(this).node().value
        ).node().focus()
      return
    selection.each (data) ->
      # Toggle children on click.
      getCurrentColumnIndex = (id) ->
        currentindex = self.columns.length
        for col, i in self.columns
          if col.key == id
            currentindex = i
            break
        currentindex
      removeNode = (d) ->
        parent = d.parent
        currentindex = parent.values.length
        for i in [0..parent.values.length - 1]
          if d._id == parent.values[i]._id
            currentindex = i
            break
        parent.values.splice currentindex, 1
        parent.children.splice currentindex, 1
        self.setID parent, parent._id
      appendNode = (d, child) ->
        if d.values
          d.values.push(child)
        else if d._values
          d._values.push(child)
        else 
          d.values = [child]
        self.setID d, d._id
        #child.parent = d
      findNodeByID = (id) ->
        idPath = id.split "_"
        root = self.gridFilteredData[0]
        root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
        root
        
      findNextNode = (d, nodes) ->
        nextNodeID = null
        for leaf, i in nodes
          if leaf._id == d._id
            if nodes.length != i + 1
              nextNodeID = nodes[i + 1]._id
            break
        return null if nextNodeID is null
        idPath = nextNodeID.split "_"
        root = self.gridFilteredData[0]
        root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
        root
      findPrevNode = (d, nodes) ->
        prevNodeID = null
        for leaf, i in nodes
          if leaf._id == d._id
            break
          prevNodeID = leaf._id
        return null if prevNodeID is null
        return null if prevNodeID is "0"
        idPath = prevNodeID.split "_"
        root = self.gridFilteredData[0]
        root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
        root
      keydown = (d, nodes) ->
        nextCell = null
        if d3.event.keyCode == 9                                                         # tab key down
          d3.event.preventDefault()
          d3.event.stopPropagation()
          currentindex = getCurrentColumnIndex d.activatedID
          if d3.event.shiftKey == false                                                  # if shiftkey is not pressed, get next
            if(currentindex < self.columns.length - 1)
              d.activatedID = self.columns[currentindex+1].key
            else
              nextNode = findNextNode d, nodes
              if nextNode != null
                nextNode.activatedID = self.columns[0].key
                d.activatedID = null
          else                                                                           # if shiftkey is not pressed, get previous
            if currentindex > 0
              d.activatedID = self.columns[currentindex-1].key
            else
              prevNode = findPrevNode d, nodes
              if prevNode != null
                prevNode.activatedID = self.columns[self.columns.length - 1].key
                d.activatedID = null
          update()
        else if d3.event.keyCode == 38                                                   # upward key pressed
          prevNode = findPrevNode d, nodes
          currentindex = getCurrentColumnIndex d.activatedID
          if prevNode != null
            prevNode.activatedID = self.columns[currentindex].key
            d.activatedID = null 
          update()
        else if d3.event.keyCode == 40                                                   # downward key pressed
          nextNode = findNextNode d, nodes
          currentindex = getCurrentColumnIndex d.activatedID
          if nextNode != null
            nextNode.activatedID = self.columns[currentindex].key
            d.activatedID = null
          update()               
        return
      keyup = (d, nodes) ->
        switch d3.event.keyCode
          when 13 # enter key down
            console.log("enterkey")
            d.activatedID = null
            update()              
          when 27 # escape key down
            console.log("escape")
            d3.select(this).node().value = d[d.activatedID]
            d.activatedID = null
            update()
        return
      dragstart = (d) ->
        targetRow = self.containerID + " tbody tr"
        self.draggingObj = d._id
        self.draggingTargetObj = null
        d3.selectAll(targetRow).on("mouseover", (d) ->
          if(self.draggingObj == d._id.substring(0, self.draggingObj.length))
            return
          d3.select(this).style("background-color", "red") 
          self.draggingTargetObj = d._id
        )
        .on("mouseout", (d) ->
          d3.select(this).style("background-color", null)
          self.draggingTargetObj = null 
        )
      dragmove = (d) ->
        
      dragend = (d) ->
        targetRow = self.containerID + " tbody tr"
        d3.selectAll(targetRow)
        .on("mouseover", null)
        .on("mouseout", null)
        .style("background-color", null)
        if self.draggingTargetObj == null
          return;
        parent = findNodeByID self.draggingTargetObj
        child = findNodeByID self.draggingObj
        removeNode child
        appendNode parent, child
        update()
      click = (d, _, unshift) ->
        d3.event.stopPropagation()
        if d3.event.shiftKey and not unshift
          #If you shift-click, it'll toggle fold all the children, instead of itself
          d3.event.shiftKey = false
          d.values and d.values.forEach((node) ->
            click node, 0, true if node.values or node._values
          )
          return true
        #download file
        #window.location.href = d.url;
        return true  unless hasChildren(d)
        if d.values
          d._values = d.values
          d.values = null
        else
          d.values = d._values
          d._values = null
        update()
      dblclick = (d, _, unshift)->
        DeactivateAll = (d) ->
          d.activatedID = null
          if d.values
            d.values.forEach (item, index) -> DeactivateAll(item)
          if d._values
            d._values.forEach (item, index) -> DeactivateAll(item)
          return
        DeactivateAll data[0]
        #.each((d) -> d.activatedID = null)
        d.activatedID = d3.select(d3.select(this).node().parentNode).attr("meta-key")
        update()
      icon = (d) ->
        (if (d._values and d._values.length) then self.iconOpenImg else (if (d.values and d.values.length) then self.iconCloseImg else ""))
      folded = (d) ->
        d._values and d._values.length
      hasChildren = (d) ->
        values = d.values or d._values
        values and values.length
      i = 0
      depth = 1
      tree = d3.layout.tree().children((d) ->
        d.values
      ).size([self.height, self.childIndent])
      update = ->
        self.isInRender = true
        selection.transition().call (_) -> self.doRendering _
      
      #grid.container = this
      data[0] = key: noData unless data[0]
      nodes = tree.nodes(data[0])
      wrap = d3.select(this).selectAll("div").data([[nodes]])
      wrapEnter = wrap.enter().append("div").attr("class", "nvd3 nv-wrap nv-indentedtree")
      tableEnter = wrapEnter.append("table")
      self.tableWidth = self.calculateTableWidth()
      table = wrap.select("table").attr("class", self.tableClassName).attr("style","table-layout:fixed;").attr("width", self.tableWidth + "px")
      self.tableObject = table
      if self.header
        thead = tableEnter.append("thead")
        theadRow1 = thead.append("tr")
        self.columns.forEach (column, i) ->
          th = theadRow1.append("th").attr("width", (if column.width then column.width else "100px")).attr("ref", i).style("text-align", (if column.type is "numeric" then "right" else "left"))
          th.append("span").text column.label
          if self.columnResize
            th.style("position","relative")
            th.append("div").attr("class", "table-resizable-handle").text('&nbsp;').call drag
        if self.hasDeleteColumn == true
          theadRow1.append("th").text("delete");
        if self.isFilterable == true
          theadRow2 = thead.append("tr")
          self.columns.forEach (column, i) ->
            keyFiled = column.key
            theadRow2.append("th").attr("meta-key", column.key).append("input").attr("type","text")
            .on("keyup", (d) ->
              self.filterCondition.set(column.key, d3.select(this).node().value)
              self.gridFilteredData = self.gridData
              self.setFilter( self.gridFilteredData[0], self.filterCondition)
              self.setID(self.gridFilteredData[0], self.gridFilteredData[0]._id)
              update()
            )
      tbody = table.selectAll("tbody").data((d) ->
        d
      )
      tbody.enter().append "tbody"
      depth = d3.max(nodes, (node) ->
        node.depth
      )
      tree.size [self.height, depth * self.childIndent]
      node = tbody.selectAll("tr").data((d) ->
        d
      , (d) ->
        d.id or (d.id is ++i)
      )
      node.exit().remove()
      node.select("img.nv-treeicon").attr("src", (d) -> icon d ).classed "folded", folded
      #node.style("display", "none")
      dragbehavior = d3.behavior.drag()
        .origin(Object)
        .on("dragstart", dragstart)
        .on("drag", dragmove)
        .on("dragend", dragend)
      nodeEnter = node.enter().append("tr").call(dragbehavior)
      d3.select(nodeEnter[0][0]).style("display", "none") if nodeEnter[0][0]
      self.columns.forEach (column, index) ->
        col_classes = ""
        col_classes += column.classes if typeof column.classes != "undefined"
        nodeName = nodeEnter.append("td").attr("meta-key",column.key)
        .attr("class", (d) ->
          row_classes = ""
          row_classes = d.classes if typeof d.classes != "undefined"
          return col_classes + " " + row_classes
        )
        if index is 0
          nodeName.style("padding-left", (d) ->
            ((if index then 0 else (d.depth - 1) * self.childIndent + ((if icon(d) then 0 else 16)))) + "px"
          , "important").style("text-align", (if column.type is "numeric" then "right" else "left"))
          .attr("ref", column.key)
          nodeName.append("img")
          .classed("nv-treeicon", true)
          .classed("nv-folded", folded)
          .attr("src", (d) -> icon d )
          .style("width", "14px")
          .style("height", "14px")
          .style("padding", "0 1px")
          .style("display", (d) ->
            (if icon(d) then "inline-block" else "none")
          ).on "click", click
        #nodeName.append("span").attr("class", d3.functor(column.classes)).text (d) ->
        #  (if column.format then column.format(d) else (d[column.key] or "-"))
        
        nodeName.each (td) ->
          if td.activatedID == column.key 
            d3.select(this).append("span").attr("class", d3.functor(column.classes))
            .append("input").attr('type', 'text').attr('value', (d) -> d[column.key] or "")
            .on("keydown", (d) -> 
              keydown d, nodes
            )
            .on("keyup", keyup )
            .on("blur", (d) -> 
              d[column.key]=d3.select(this).node().value
              if self.isInRender == false
                d.activatedID = null
                update()
            )
            .node().focus();
          else
            d3.select(this).append("span").attr("class", d3.functor(column.classes)).text (d) ->
              if column.format then column.format(d) else (d[column.key] or "-")
        
        #nodeName.append("span").attr("class", d3.functor(column.classes)).text (d) ->
        #  if column.format then column.format(d) else (d[column.key] or "-")
        
        if column.showCount
          nodeName.append("span").attr("class", "nv-childrenCount").text (d) ->
            (if ((d.values and d.values.length) or (d._values and d._values.length)) then "(" + ((d.values and d.values.length) or (d._values and d._values.length)) + ")" else "")
        
        #nodeName.select("span").on "click", column.click  if column.click
        nodeName.select("span").on "dblclick", dblclick if self.isEditable
      if self.hasDeleteColumn == true
        nodeEnter.append("td").attr("class", (d) ->
          row_classes = ""
          row_classes = d.classes if typeof d.classes != "undefined"
          row_classes
        ).append("a").attr("href","#").text("delete").on("click", (d) ->
          if confirm "Are you sure you are going to delete this?"
            removeNode d
            update() 
        )
      node.order().on("click", (d) ->
        self.dispatch.elementClick
          row: this
          data: d
          pos: [d.x, d.y]

      ).on("dblclick", (d) ->
        self.dispatch.elementDblclick
          row: this
          data: d
          pos: [d.x, d.y]
      ).on("mouseover", (d) ->
        self.dispatch.elementMouseover
          row: this
          data: d
          pos: [d.x, d.y]

      ).on("mouseout", (d) ->
        self.dispatch.elementMouseout
          row: this
          data: d
          pos: [d.x, d.y]
      )
    @isInRender = false
    return this  
  
  #============================================================
  # Expose Public Variables
  #------------------------------------------------------------
  data : (_) ->
    return @gridData unless _
    @gridData = _
    this
  margin : (_) ->
    return @margin  unless _
    @margin.top = (if typeof _.top isnt "undefined" then _.top else @margin.top)
    @margin.right = (if typeof _.right isnt "undefined" then _.right else @margin.right)
    @margin.bottom = (if typeof _.bottom isnt "undefined" then _.bottom else @margin.bottom)
    @margin.left = (if typeof _.left isnt "undefined" then _.left else @margin.left)

  columnReize : (_) ->
    return @columnResize unless _?
    @columnResize = _
    this
  editable : (_) ->
    return @isEditable unless _?
    @isEditable = _
    this
  width : (_) ->
    return width  unless _?
    @width = _
    this

  height : (_) ->
    return @height  unless _?
    @height = _
    this

  color : (_) ->
    return @color  unless _?
    @color = _
    this

  id : (_) ->
    return @id  unless _?
    @id = _
    this

  header : (_) ->
    return @header  unless _?
    @header = _
    this

  noData : (_) ->
    return @noData  unless _?
    @noData = _
    this

  columns : (_) ->
    return @columns  unless _?
    @filterCondition = d3.map([])
    @columns = _
    this

  tableClass : (_) ->
    return @tableClass  unless _?
    @tableClass = _
    this

  iconOpen : (_) ->
    return @iconOpen  unless _?
    @iconOpen = _
    this

  iconClose : (_) ->
    return @iconClose  unless _?
    @iconClose = _
    this
  Sortable : (_) ->
    if (_?)
      @isSortable = _
      return this
    else
      return @isSortable