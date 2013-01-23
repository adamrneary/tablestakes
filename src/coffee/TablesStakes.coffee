class window.TablesStakes

# Public Variables
    attributes: {}
        #sortable : false
        #editable : false
        #deletable : false
        #filterable : false
        #dragable: false

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

    #isSortable : false
    #isEditable : false
    #hasDeleteColumn : false
    #isFilterable : false

    gridData : []
    gridFilteredData : []
    tableObject : null
    minWidth : 50
    tableWidth : 0
    containerID : null

    isInRender : false
    filterCondition : []

    constructor: (options)->
        @set 'sortable', false
        @set 'editable', false
        @set 'deletable', false
        @set 'filterable', false
        @set 'dragable', false
        if options?
            for key of options
                @set key, options[key]

    render: (selector) ->

        console.log 'Table render'
        @gridData = [values: @get('data')]
        @columns.forEach ( column, i) =>
          @gridData[0][column['key']] = column['key'] 
        @setID @gridData[0], "0"
        @gridFilteredData = @gridData
        @setFilter @gridFilteredData[0], @filterCondition
        @containerID = selector if selector?
        d3.select(@containerID).datum(@gridFilteredData).call( (selection) => @update selection )
        console.log 'table render end'
        @
        #@gridData = [values: @get('data')]
        #@get('columns').forEach (column, i) =>
          #@gridData[0][column['key']] = column['key']

        ##set id to all nodes and subnodes recursive
        #setID = (node, prefix) ->
          #node['_id'] = prefix
          #if node.values
            #node.values.forEach (subnode, i) ->
              #setID subnode, prefix+"_"+i
          #if node._values
            #node._values.forEach (subnode, i) ->
              #setID subnode, prefix+"_"+i
        #setID @gridData[0], "0"
        #d3.select(selector).datum(@gridData).call( (selection) => @update selection )
        #@

    update: (selection) -> 
        console.log 'table update, selection:',selection
        selection.each (data)=> 
            new TablesStakesCore
                selection: selection
                table: @
                data: data
        @isInRender = false
        @

    calculateTableWidth: () ->
        tableWidth = 0
        @get('columns').forEach (column, index) ->
          tableWidth += parseInt(column.width)
        @tableWidth = tableWidth

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
        if node.values
          node.values.forEach (subnode, i) =>
            @setID subnode, prefix+"_"+i
        if node._values
          node._values.forEach (subnode, i) =>
            @setID subnode, prefix+"_"+i

    setFilter: ( data, filter ) ->
        #console.log 'table setFilter start'
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
        #console.log 'table setFilter end'
        if matchFound
          return data            
        return null



  #============================================================
  # Expose Public Variables
  #------------------------------------------------------------

    set: (key,value,options)->
        @attributes[key] = value if key? and value?
        #@[key] = value
        switch key
            when 'columns'
                @filterCondition = d3.map([])
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


class TablesStakesCore

    constructor: (options)->
        console.log 'core constructor, options:',options
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
              if nextNode isnt null
                nextNode.activatedID = @columns[0].key
                d.activatedID = null
        else                                                                           # if shiftkey is not pressed, get previous
            if currentindex > 0
                d.activatedID = @columns[currentindex-1].key
            else
                prevNode = @findPrevNode d, @nodes
                if prevNode isnt null
                    prevNode.activatedID = @columns[@columns.length - 1].key
                    d.activatedID = null
        @update()

    key_down: (node,d)->
        nextNode = @findNextNode d
        currentindex = @getCurrentColumnIndex d.activatedID
        if nextNode isnt null
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
    blur: (node,d, column) ->
        cell = d3.select(node)
        columnKey = d3.select(node)[0][0].parentNode.getAttribute("ref")
        hz = d3.select(node)[0][0]
        cell.text(d3.select(node).node().value)
        d[columnKey]=d3.select(node).node().value
        d[column.key]=d3.select('td input').node().value
        if @table.isInRender == false
            d.activatedID = null
            @update()

    # click on the icon to deploy-fold
    click: (node,d, _, unshift) ->
        console.log 'core click'
        d.activatedID = null
        d3.event.stopPropagation()

        if d3.event.shiftKey and not unshift
            #If you shift-click, it'll toggle fold all the children, instead of itself
            #d3.event.shiftKey = false
            self = @
            d.values and d.values.forEach((node) ->
                self.click this,node, 0, true if node.values or node._values
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

    dragstart: (node,d) ->
        console.log 'dragstart'
        self = @
        if @table.get('dragable') is true
            targetRow = @table.containerID + " tbody tr"
            @draggingObj = d._id
            @draggingTargetObj = null
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
    dragmove: (d) ->
        if @table.get('dragable') is true
            console.log 'dragmove'
        
    dragend: (node,d) ->
        if @table.get('dragable') is true
            console.log 'dragend'
            targetRow = @table.containerID + " tbody tr"
            d3.selectAll(targetRow)
            .on("mouseover", null)
            .on("mouseout", null)
            .style("background-color", null)
            if @draggingTargetObj == null
                return;
            parent = @findNodeByID @draggingTargetObj
            child = @findNodeByID @draggingObj
            @removeNode child
            @appendNode parent, child
            @update()

    removeNode: (d) ->
        parent = d.parent
        currentindex = parent.values.length
        for i in [0..parent.values.length - 1]
            if d._id == parent.values[i]._id
                currentindex = i
                break
        parent.values.splice currentindex, 1
        parent.children.splice currentindex, 1
        @table.setID parent, parent._id

    appendNode: (d, child) ->
        if d.values
            d.values.push(child)
        else if d._values
            d._values.push(child)
        else 
            d.values = [child]
        @table.setID d, d._id
        #child.parent = d

    findNodeByID: (id) ->
        idPath = id.split "_"
        root = @table.gridFilteredData[0]
        root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
        root

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
        self = @
        console.log 'core render start'
        @data[0] = key: @table.noData unless @data[0]
        @tree = d3.layout.tree().children (d) -> d.values
        @nodes = @tree.nodes(@data[0])

        wrap = d3.select(@table.containerID).selectAll("div").data([[@nodes]])
        wrapEnter = wrap.enter().append("div").attr("class", "nvd3 nv-wrap nv-indentedtree")
        tableEnter = wrapEnter.append("table")

        @table.calculateTableWidth()
        @tableObject = wrap.select("table").attr("class", @table.tableClassName).attr("style","table-layout:fixed;").attr("width", @table.tableWidth + "px")
        # generate thead

        drag = d3.behavior.drag().on "drag", (d, i) ->
            th = d3.select(this).node().parentNode
            column_x = parseFloat(d3.select(th).attr("width"))
            column_newX = d3.event.x # x + d3.event.dx
            if self.table.minWidth < column_newX
                d3.select(th).attr("width", column_newX + "px")
                index = parseInt(d3.select(th).attr("ref"))
                self.columns[index].width = column_newX + "px";
                table_x = parseFloat(self.tableObject.attr("width"))
                table_newX = table_x + (column_newX - column_x) #x + d3.event.dx 
                self.tableObject.attr "width", table_newX+"px"

        if @table.header
            thead = tableEnter.append("thead")
            theadRow1 = thead.append("tr")
            @columns.forEach (column, i) =>
                th = theadRow1.append("th").attr("width", (if column.width then column.width else "100px")).attr("ref", i).style("text-align", (if column.type is "numeric" then "right" else "left"))
                th.append("span").text column.label
                if @table.get('sortable') is true
                  if @table.get('deletable') is true
                    th.style("position","relative")
                    th.append("div").attr("class", "table-resizable-handle").text('&nbsp;').call drag
                  else 
                    if i isnt @columns.length-1
                      th.style("position","relative")
                      th.append("div").attr("class", "table-resizable-handle").text('&nbsp;').call drag

            if @table.get('deletable') is true
                theadRow1.append("th").text("delete");
            if @table.get('filterable') is true
                theadRow2 = thead.append("tr")
                @columns.forEach (column, i) =>
                    keyFiled = column.key
                    self = @
                    theadRow2.append("th").attr("meta-key", column.key).append("input").attr("type","text")
                    .on("keyup", (d) ->
                        self.table.filterCondition.set(column.key, d3.select(this).node().value)
                        self.table.gridFilteredData = self.table.gridData
                        self.table.setFilter( self.table.gridFilteredData[0], self.table.filterCondition)
                        self.table.setID(self.table.gridFilteredData[0], self.table.gridFilteredData[0]._id)
                        self.update()
                    )
        # generate tbody
        console.log 'core render body'
        tbody = @tableObject.selectAll("tbody").data((d) ->
            d
        )
        tbody.enter().append "tbody"
        # calculate number of columns
        depth = d3.max(@nodes, (node) ->
            node.depth
        )
        console.log @table.height, depth, @table.childIndent
        @tree.size [@table.height, depth * @table.childIndent]

        console.log 'core render nodes'
        i = 0
        node = tbody.selectAll("tr").data((d) ->
            d
        , (d) ->
            d.id or (d.id is ++i)
        )
        node.exit().remove()
        node.select("img.nv-treeicon").attr("src", (d) => @icon d ).classed "folded", @folded
        self = @
        dragbehavior = d3.behavior.drag()
            .origin(Object)
            .on "dragstart", (a,b,c)->
                console.log 'dragstart2'
                self.dragstart this,a,b,c
            .on "drag", (a,b,c)->
                console.log 'dragstart2'
                self.dragmove this,a,b,c
            .on "dragend", (a,b,c)->
                console.log 'dragstart2'
                self.dragend this,a,b,c
        @nodeEnter = node.enter().append("tr").call dragbehavior
        d3.select(@nodeEnter[0][0]).style("display", "none") if @nodeEnter[0][0]
        console.log 'core render end'
        @columns.forEach (column, index) =>
            @renderColumn column,index,node

        if @table.get('deletable') is true
            @nodeEnter.append("td").attr("class", (d) ->
                row_classes = ""
                row_classes = d.classes if typeof d.classes != "undefined"
                row_classes
            ).append("a").attr("href","#").text("delete").on("click", (d) =>
                if confirm "Are you sure you are going to delete this?"
                    @removeNode d
                    @update() 
            )

        node.order().on("click", (d) ->
            self.table.dispatch.elementClick
                row: this
                data: d
                pos: [d.x, d.y]

        ).on("dblclick", (d) ->
            self.table.dispatch.elementDblclick
                row: this
                data: d
                pos: [d.x, d.y]
        ).on("mouseover", (d) ->
            self.table.dispatch.elementMouseover
                row: this
                data: d
                pos: [d.x, d.y]
        ).on("mouseout", (d) ->
            self.table.dispatch.elementMouseout
                row: this
                data: d
                pos: [d.x, d.y]
        )


    renderColumn: (column,index,node)->
        console.log 'renderColumn start',index,column
        self = @
        col_classes = ""
        col_classes += column.classes if typeof column.classes != "undefined"

        nodeName = @nodeEnter.append("td").attr("meta-key",column.key)
        .attr("class", (d)=>
            row_classes = ""
            row_classes = d.classes if typeof d.classes != "undefined"
            return col_classes + " " + row_classes
        )
        if index is 0
            nodeName.style("padding-left", (d)=>
                ((if index then 0 else (d.depth - 1) * @table.childIndent + ((if @icon(d) then 0 else 16)))) + "px"
            , "important").style("text-align", (if column.type is "numeric" then "right" else "left"))
            .attr("ref", column.key)

            nodeName.append("img")
            .classed("nv-treeicon", true)
            .classed("nv-folded", @folded)
            .attr("src", (d) => @icon d )
            .style("width", "14px")
            .style("height", "14px")
            .style("padding", "0 1px")
            .style("display", (d) =>
                (if @icon(d) then "inline-block" else "none")
            ).on "click", (a,b,c)->
                self.click this,a,b,c
        #nodeName.append("span").attr("class", d3.functor(column.classes)).text (d) ->
        #  (if column.format then column.format(d) else (d[column.key] or "-"))

        console.log 'core renderColumn renderNode'
        nodeName.each (td) ->
            self.renderNode this,column,td,nodeName

        if column.showCount
            nodeName.append("span").attr("class", "nv-childrenCount").text (d) ->
                (if ((d.values and d.values.length) or (d._values and d._values.length)) then "(" + ((d.values and d.values.length) or (d._values and d._values.length)) + ")" else "")
            
    renderNode: (node,column,td,nodeName)->
        console.log 'renderNode start'
        self = @
        editable = @table.get('editable')
        if td.activatedID == column.key 
            d3.select(node).append("span").attr("class", d3.functor(column.classes))
            .append("input").attr('type', 'text').attr('value', (d) -> d[column.key] or "")
            .on "keydown", (d) -> 
                self.keydown this,d
            .on "keyup", (a,b,c)->
                self.keyup this,a,b,c
            .on "blur", (d) ->
                self.blur this,d, column
            .node().focus()
            console.log 'columns=', @columns
        else
            d3.select(node).append("span").attr("class", d3.functor(column.classes)).text (d) ->
                if column.format then column.format(d) else (d[column.key] or "-")

        nodeName.select("span").on "click", (a,b,c)->
            if editable and column.isEditable
              self.editable this,a,b,c 
        #console.log 'renderNode end'
