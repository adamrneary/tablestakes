Tablestakes = window.Tablestakes || {}
window.Tablestakes = Tablestakes

Tablestakes.Table = class Table
# Public Variables
  attributes: {}
  margin :
    top: 0
    right: 0
    bottom: 0
    left: 0
  width : 960
  height : 500
  id : Math.floor(Math.random() * 10000)
  header : true
  noData : "No Data Available."
  childIndent : 20
  columns :
    key: "key"
    label: "Name"
    type: "text"
  tableClassName : "class"
  iconOpenImg : "css/img/expand.gif"
  iconCloseImg : "css/img/collapse.gif"
  dispatch : d3.dispatch("elementClick", "elementDblclick", "elementMouseover", "elementMouseout")
  columnResize : true
  isSortable : true
  isEditable : true
  gridData : []
  tableObject : null
  minWidth : 50
  tableWidth : 0
  isInRender : false

  render: (selector) ->
    @gridData = [values: @get('data')]
    @get('columns').forEach (column, i) =>
      @gridData[0][column['key']] = column['key']

    #set id to all nodes and subnodes recursive
    setID = (node, prefix) ->
      node['_id'] = prefix
      if node.values
        node.values.forEach (subnode, i) ->
          setID subnode, prefix+"_"+i
      if node._values
        node._values.forEach (subnode, i) ->
          setID subnode, prefix+"_"+i
    setID @gridData[0], "0"
    d3.select(selector).datum(@gridData).call( (selection) => @update selection )
    @

  update: (selection) -> 
    selection.each (data) =>
      new Tablestakes.Core
          data: data
          selection: selection
          table: @

    @isInRender = false
    @

  calculateTableWidth: () ->
    tableWidth = 0
    @get('columns').forEach (column, index) ->
      tableWidth += parseInt(column.width)
    @tableWidth = tableWidth

  #============================================================
  # Expose Public Variables
  #------------------------------------------------------------

  set: (key,value,options)->
    @attributes[key] = value if key? and value?
    #@[key] = value
    @

  get: (key)->
    @attributes[key]

  setMargin : (margin) ->
    return @margin  unless margin?
    @margin.top = (if typeof margin.top isnt "undefined" then margin.top else @margin.top)
    @margin.right = (if typeof margin.right isnt "undefined" then margin.right else @margin.right)
    @margin.bottom = (if typeof margin.bottom isnt "undefined" then margin.bottom else @margin.bottom)
    @margin.left = (if typeof margin.left isnt "undefined" then margin.left else @margin.left)

  Sortable : (_) ->
    if (_?)
      @isSortable = _
      @
    else
      @isSortable


Tablestakes.Core = class Core

  constructor: (options)->
    @table = options.table
    @selection = options.selection
    @data = options.data

    @columns = @table.get('columns')
    @render()

    # Toggle children on click.
  getCurrentColumnIndex: (id) ->
    console.log 'core getCurrentColumnIndex, id:',id
    currentindex = @columns.length
    for col, i in @columns
      if col.key == id
        currentindex = i
        break
    currentindex

  findNextNode: (d) ->
    console.log 'core findNextNode'
    nextNodeID = null
    for leaf, i in @nodes
      if leaf._id == d._id
        if @nodes.length != i + 1
          nextNodeID = @nodes[i + 1]._id
        break
    return null if nextNodeID is null
    idPath = nextNodeID.split "_"
    root = @data[0]
    root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
    root

  findPrevNode: (d) ->
    console.log 'core findPrevNode'
    prevNodeID = null
    for leaf, i in @nodes
      if leaf._id == d._id
        break
      prevNodeID = leaf._id
    return null if prevNodeID is null or prevNodeID is "0"
    idPath = prevNodeID.split "_"
    root = @data[0]
    root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
    root

    # movement of the cells
  keydown: (node,d) ->
    switch d3.event.keyCode
        when 9
          @key_tab node,d
        when 38
          @key_up node,d
        when 40
          @key_down node,d
    # clavey handler enter and esc 

  key_tab: (node,d)->
    d3.event.preventDefault()
    d3.event.stopPropagation()
    currentindex = @getCurrentColumnIndex d.activatedID
    if d3.event.shiftKey == false                                                  # if shiftkey is not pressed, get next
      if(currentindex < @columns.length - 1)
        d.activatedID = @columns[currentindex+1].key
      else
        nextNode = @findNextNode d, @nodes
        if nextNode != null
          nextNode.activatedID = @columns[0].key
          d.activatedID = null
    else                                                                           # if shiftkey is not pressed, get previous
      if currentindex > 0
        d.activatedID = @columns[currentindex-1].key
      else
        prevNode = @findPrevNode d, @nodes
        if prevNode != null
          prevNode.activatedID = @columns[@columns.length - 1].key
          d.activatedID = null
    @update()

  key_down: (node,d)->
    nextNode = @findNextNode d
    currentindex = @getCurrentColumnIndex d.activatedID
    if nextNode != null
      nextNode.activatedID = @columns[currentindex].key
      d.activatedID = null
    @update()

  key_up: (node,d)->
    prevNode = @findPrevNode d, @nodes
    currentindex = @getCurrentColumnIndex d.activatedID
    if prevNode != null
      prevNode.activatedID = @columns[currentindex].key
      d.activatedID = null 
    @update()

  keyup: (node,d) ->
      switch d3.event.keyCode
        when 13                                                                        # enter key down
          d.activatedID = null
          @update()              
        when 27                                                                        # escape key down
          d3.select(node).node().value = d[d.activatedID]
          d.activatedID = null
          @update()
      return

    # decrease of the selection from the active cell
  blur: (d, column) ->
      d[column.key]=d3.select('input').node().value
      if @table.isInRender == false
        d.activatedID = null
        @update()

    # click on the icon to deploy-fold
  click: (d, _, unshift) ->
    console.log 'core click'
    d.activatedID = null
    d3.event.stopPropagation()

    if d3.event.shiftKey and not unshift
      #If you shift-click, it'll toggle fold all the children, instead of itself
      #d3.event.shiftKey = false
      d.values and d.values.forEach((node) =>
        @click node, 0, true if node.values or node._values
      )
      return true
    #return true  unless hasChildren(d)

    # toggle fold. d.values - open, d._values - close
    #else
    if d.values
      d._values = d.values
      d.values = null
    else
      d.values = d._values
      d._values = null
    @update()

  drag: ->
    d3.behavior.drag()
      .on "drag", (d, i) =>
        th = d3.select(@table).node().parentNode
        column_x = parseFloat(d3.select(th).attr("width"))
        column_newX = d3.event.x # x + d3.event.dx
        if @table.minWidth < column_newX
          d3.select(th).attr("width", column_newX + "px")
          index = parseInt(d3.select(th).attr("ref"))
          @columns[index].width = column_newX + "px";
          table_x = parseFloat(@tableObject.attr("width"))
          table_newX = table_x + (column_newX - column_x) #x + d3.event.dx 
          @tableObject.attr "width", table_newX+"px"

  deactivateAll: (d) ->
    d.activatedID = null
    if d.values
      d.values.forEach (item, index) => @deactivateAll(item)
    if d._values
      d._values.forEach (item, index) => @deactivateAll(item)
    return

  # change row if class editable
  editable: (node,d, _, unshift)->
    console.log 'core editable'
    @deactivateAll @data[0]
    d.activatedID = d3.select(d3.select(node).node().parentNode).attr("meta-key")
    @update()

  # change icons during deployment-folding
  icon: (d)->
      (if (d._values and d._values.length) then @table.iconOpenImg else (if (d.values and d.values.length) then @table.iconCloseImg else ""))

  folded: (d) ->
      d._values and d._values.length

  hasChildren: (d) ->
      values = d.values or d._values
      values and values.length

  update: ->
      @table.isInRender = true
      @selection.transition().call (selection) => @table.update selection

  render: ->
    #console.log 'core render start'
    @data[0] = key: @table.noData unless @data[0]
    @tree = d3.layout.tree().children (d) -> d.values
    @nodes = @tree.nodes(@data[0])
    wrap = d3.select('#example_view').selectAll("div").data([[@nodes]])
    wrapEnter = wrap.enter().append("div").attr("class", "nvd3 nv-wrap nv-indentedtree")
    tableEnter = wrapEnter.append("table")
    @table.calculateTableWidth()
    @tableObject = wrap.select("table").attr("class", @table.tableClassName).attr("style","table-layout:fixed;").attr("width", @table.tableWidth + "px")
    # generate thead
    if @table.header
      #console.log 'core render header'
      thead = tableEnter.append("thead")
      theadRow = thead.append("tr")
      @columns.forEach (column, i) =>
        th = theadRow.append("th").attr("width", (if column.width then column.width else "100px")).attr("ref", i).style("text-align", (if column.type is "numeric" then "right" else "left"))
        th.append("span").text column.label
        if @table.columnResize
          th.style("position","relative")
          th.append("div").attr("class", "table-resizable-handle").call @drag
          th.append("br")
    # generate tbody
    #console.log 'core render body'
    tbody = @tableObject.selectAll("tbody").data((d) ->
      d
    )
    tbody.enter().append "tbody"
    # calculate number of columns
    depth = d3.max(@nodes, (node) ->
      node.depth
    )
    @tree.size [@table.height, depth * @table.childIndent]

    #console.log 'core render nodes'
    i = 0
    node = tbody.selectAll("tr").data((d) ->
      d
    , (d) ->
      d.id or (d.id is ++i)
    )
    node.exit().remove()
    node.select("img.nv-treeicon").attr("src", (d) => @icon d ).classed "folded", @folded
    @nodeEnter = node.enter().append("tr")
    d3.select(@nodeEnter[0][0]).style("display", "none") if @nodeEnter[0][0]
    #console.log 'core render end'
    @columns.forEach (column, index) =>
      @renderColumn column,index

  renderColumn: (column,index)->
    #console.log 'renderColumn start',index
    nodeName = @nodeEnter.append("td").attr("meta-key",column.key).style("padding-left", (d) =>
      ((if index then 0 else (d.depth - 1) * @table.childIndent + ((if @icon(d) then 0 else 16)))) + "px"
    , "important").style("text-align", (if column.type is "numeric" then "right" else "left")).attr("ref", column.key)
    if index is 0
      nodeName.append("img")
      .classed("nv-treeicon", true)
      .classed("nv-folded", @folded)
      .attr("src", (d) => @icon d )
      .style("width", "14px")
      .style("height", "14px")
      .style("padding", "0 1px")
      .style("display", (d) =>
        (if @icon(d) then "inline-block" else "none")
      ).on "click", (a,b,c)=>
        @click a,b,c
    self = @
    #console.log 'renderColumn end'
    nodeName.each (td) ->
      self.renderNode this,column,td,nodeName

  renderNode: (node,column,td,nodeName)->
    #console.log 'renderNode start'
    self = @
    if td.activatedID == column.key 
      d3.select(node).append("span").attr("class", d3.functor(column.classes))
      .append("input").attr('type', 'text').attr('value', (d) -> d[column.key] or "")
      .on "keydown", (d) -> 
        self.keydown this,d
      .on "keyup", (a,b,c)->
        self.keyup this,a,b,c
      .on "blur", (d) =>
        self.blur d, column
      .node().focus()
    else
      d3.select(node).append("span").attr("class", d3.functor(column.classes)).text (d) ->
        if column.format then column.format(d) else (d[column.key] or "-")
    if column.showCount
      nodeName.append("span").attr("class", "nv-childrenCount").text (d) ->
        (if ((d.values and d.values.length) or (d._values and d._values.length)) then "(" + ((d.values and d.values.length) or (d._values and d._values.length)) + ")" else "")
    nodeName.select("span").on "click", (a,b,c)->
      self.editable this,a,b,c if self.table.isEditable
    #console.log 'renderNode end'
