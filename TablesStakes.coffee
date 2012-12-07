class TablesStakes
  margin = {top: 0, right: 0, bottom: 0, left: 0}
  width = 960
  height = 500
  color = nv.utils.defaultColor()
  id = Math.floor(Math.random() * 10000)
  header = true
  noData = "No Data Available."
  childIndent = 20
  columns = [
    key: "key"
    label: "Name"
    type: "text"
  ]
  tableClass = null
  iconOpen = "images/expand.gif"
  iconClose = "images/collapse.gif"
  dispatch = d3.dispatch("elementClick", "elementDblclick", "elementMouseover", "elementMouseout")
  
  initialize: ->
    @grid()   
  grid = (selection) ->
    selection.each (data) ->      
      # Toggle children on click.
      click = (d, _, unshift) ->
        d3.event.stopPropagation()
        if d3.event.shiftKey and not unshift
          
          #If you shift-click, it'll toggle fold all the children, instead of itself
            click node, 0, true  if node.values or node._values
          d3.event.shiftKey = false
          d.values and d.values.forEach((node) ->
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
        grid.update()
      icon = (d) ->
        (if (d._values and d._values.length) then iconOpen else (if (d.values and d.values.length) then iconClose else ""))
      folded = (d) ->
        d._values and d._values.length
      hasChildren = (d) ->
        values = d.values or d._values
        values and values.length
      i = 0
      depth = 1
      tree = d3.layout.tree().children((d) ->
        d.values
      ).size([height, childIndent])
      grid.update = ->
        selection.transition().call grid

      grid.container = this
      data[0] = key: noData  unless data[0]
      nodes = tree.nodes(data[0])
      wrap = d3.select(this).selectAll("div").data([[nodes]])
      wrapEnter = wrap.enter().append("div").attr("class", "nvd3 nv-wrap nv-indentedtree")
      tableEnter = wrapEnter.append("table")
      table = wrap.select("table").attr("width", "100%").attr("class", tableClass)
      if header
        thead = tableEnter.append("thead")
        theadRow1 = thead.append("tr")
        columns.forEach (column) ->
          theadRow1.append("th").attr("width", (if column.width then column.width else "10%")).style("text-align", (if column.type is "numeric" then "right" else "left")).append("span").text column.label

      tbody = table.selectAll("tbody").data((d) ->
        d
      )
      tbody.enter().append "tbody"
      depth = d3.max(nodes, (node) ->
        node.depth
      )
      tree.size [height, depth * childIndent]
      node = tbody.selectAll("tr").data((d) ->
        d
      , (d) ->
        d.id or (d.id is ++i)
      )
      node.exit().remove()
      node.select("img.nv-treeicon").attr("src", icon).classed "folded", folded
      nodeEnter = node.enter().append("tr")
      columns.forEach (column, index) ->
        nodeName = nodeEnter.append("td").style("padding-left", (d) ->
          ((if index then 0 else d.depth * childIndent + 12 + ((if icon(d) then 0 else 16)))) + "px"
        , "important").style("text-align", (if column.type is "numeric" then "right" else "left"))
        if index is 0
          nodeName.append("img").classed("nv-treeicon", true).classed("nv-folded", folded).attr("src", icon).style("width", "14px").style("height", "14px").style("padding", "0 1px").style("display", (d) ->
            (if icon(d) then "inline-block" else "none")
          ).on "click", click
        nodeName.append("span").attr("class", d3.functor(column.classes)).text (d) ->
          (if column.format then column.format(d) else (d[column.key] or "-"))

        if column.showCount
          nodeName.append("span").attr("class", "nv-childrenCount").text (d) ->
            (if ((d.values and d.values.length) or (d._values and d._values.length)) then "(" + ((d.values and d.values.length) or (d._values and d._values.length)) + ")" else "")

        nodeName.select("span").on "click", column.click  if column.click

      node.order().on("click", (d) ->
        dispatch.elementClick
          row: this
          data: d
          pos: [d.x, d.y]

      ).on("dblclick", (d) ->
        dispatch.elementDblclick
          row: this
          data: d
          pos: [d.x, d.y]

      ).on("mouseover", (d) ->
        dispatch.elementMouseover
          row: this
          data: d
          pos: [d.x, d.y]

      ).on "mouseout", (d) ->
        dispatch.elementMouseout
          row: this
          data: d
          pos: [d.x, d.y]
    grid

  
  #============================================================
  # Expose Public Variables
  #------------------------------------------------------------
  grid.margin = (_) ->
    return margin  unless arguments_.length
    margin.top = (if typeof _.top isnt "undefined" then _.top else margin.top)
    margin.right = (if typeof _.right isnt "undefined" then _.right else margin.right)
    margin.bottom = (if typeof _.bottom isnt "undefined" then _.bottom else margin.bottom)
    margin.left = (if typeof _.left isnt "undefined" then _.left else margin.left)
    grid

  grid.width = (_) ->
    return width  unless arguments_.length
    width = _
    grid

  grid.height = (_) ->
    return height  unless arguments_.length
    height = _
    grid

  grid.color = (_) ->
    return color  unless arguments_.length
    color = nv.utils.getColor(_)
    scatter.color color
    grid

  grid.id = (_) ->
    return id  unless arguments_.length
    id = _
    grid

  grid.header = (_) ->
    return header  unless arguments_.length
    header = _
    grid

  grid.noData = (_) ->
    return noData  unless arguments_.length
    noData = _
    grid

  grid.columns = (_) ->
    return columns  unless arguments_.length
    columns = _
    grid

  grid.tableClass = (_) ->
    return tableClass  unless arguments_.length
    tableClass = _
    grid

  grid.iconOpen = (_) ->
    return iconOpen  unless arguments_.length
    iconOpen = _
    grid

  grid.iconClose = (_) ->
    return iconClose  unless arguments_.length
    iconClose = _
    grid