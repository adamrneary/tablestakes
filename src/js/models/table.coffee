Tablestakes.Table = class Table
  margin :
    top: 0
    right: 0
    bottom: 0
    left: 0

  width : 960
  height : 500
  color : nv.utils.defaultColor()
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
  gridData : []
  tableObject : null
  minWidth : 50
  
  render: (_) ->
    self = this
    nv.addGraph ->
      d3.select(_).datum(self.gridData).call( (_) -> self.doRendering _ )
    this
    
  doRendering: (selection) -> 
    self = this
    drag = d3.behavior.drag()
      .on("drag", (d, i) ->
        th = d3.select(this).node().parentNode
        column_x = parseInt d3.select(th).attr "width"
        column_newX = d3.event.x # x + d3.event.dx
        console.log d3.event
        if self.minWidth < column_newX
          column_newX += "px"
          d3.select(th).attr "width", column_newX
          table_x = parseInt self.tableObject.attr "width"
          table_newX = table_x + (column_x - column_newX) #x + d3.event.dx 
          self.tableObject.attr "width", table_newX+"px"
      )
    selection.each (data) ->
      # Toggle children on click.
      click = (d, _, unshift) ->
        console.log "you've clicked the collapse and expand image."
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
        selection.transition().call (_) -> self.doRendering _

      #grid.container = this
      data[0] = key: noData unless data[0]
      nodes = tree.nodes(data[0])
      wrap = d3.select(this).selectAll("div").data([[nodes]])
      wrapEnter = wrap.enter().append("div").attr("class", "nvd3 nv-wrap nv-indentedtree")
      tableEnter = wrapEnter.append("table")
      table = wrap.select("table").attr("width", "500px").attr("class", self.tableClassName).attr("style","table-layout:fixed;")
      self.tableObject = table
      if self.header
        thead = tableEnter.append("thead")
        theadRow1 = thead.append("tr")
        self.columns.forEach (column) ->
          th = theadRow1.append("th").attr("width", (if column.width then column.width else "10%")).style("text-align", (if column.type is "numeric" then "right" else "left"))
          th.append("span").text column.label
          if self.columnResize
            th.style("position","relative")
            th.append("div").attr("class", "table-resizable-handle").text('-').call drag
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
      nodeEnter = node.enter().append("tr")
      self.columns.forEach (column, index) ->
        nodeName = nodeEnter.append("td").style("padding-left", (d) ->
          ((if index then 0 else d.depth * self.childIndent + 12 + ((if icon(d) then 0 else 16)))) + "px"
        , "important").style("text-align", (if column.type is "numeric" then "right" else "left"))
        if index is 0
          nodeName.append("img").classed("nv-treeicon", true).classed("nv-folded", folded).attr("src", (d) -> icon d ).style("width", "14px").style("height", "14px").style("padding", "0 1px").style("display", (d) ->
            (if icon(d) then "inline-block" else "none")
          ).on "click", click
        nodeName.append("span").attr("class", d3.functor(column.classes)).text (d) ->
          (if column.format then column.format(d) else (d[column.key] or "-"))

        if column.showCount
          nodeName.append("span").attr("class", "nv-childrenCount").text (d) ->
            (if ((d.values and d.values.length) or (d._values and d._values.length)) then "(" + ((d.values and d.values.length) or (d._values and d._values.length)) + ")" else "")

        nodeName.select("span").on "click", column.click  if column.click

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
    this  
  
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

  header : (_) ->
    return @columnResize unless _
    @columnResize = _
    this

  width : (_) ->
    return width  unless _
    @width = _
    this

  height : (_) ->
    return @height  unless _
    @height = _
    this

  color : (_) ->
    return @color  unless _
    @color = nv.utils.getColor(_)
    scatter.color color
    this

  id : (_) ->
    return @id  unless _
    @id = _
    this

  header : (_) ->
    return @header  unless _
    @header = _
    this

  noData : (_) ->
    return @noData  unless _
    @noData = _
    this

  columns : (_) ->
    return @columns  unless _
    @columns = _
    this

  tableClass : (_) ->
    return @tableClass  unless _
    @tableClass = _
    this

  iconOpen : (_) ->
    return @iconOpen  unless _
    @iconOpen = _
    this

  iconClose : (_) ->
    return @iconClose  unless _
    @iconClose = _
    this