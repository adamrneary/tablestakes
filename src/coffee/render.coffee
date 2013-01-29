window.TablesStakesLib = {} unless window.TablesStakesLib
class window.TablesStakesLib.render

    constructor: (options)->
        console.log 'core constructor, options:',options
        @table = options.table
        @selection = options.selection
        @data = options.data
        @columns = @table.get('columns')
        @utils = new window.TablesStakesLib.utils
            core: @
        @events = new window.TablesStakesLib.events
            core: @
        @render()

    update: ->
        @table.isInRender = true
        @selection.transition().call (selection) => @table.update selection

    resizable: (th)->
        self = @
        drag = d3.behavior.drag().on "drag", (d, i) ->
            th = d3.select(this).node().parentNode
            column_x = parseFloat(d3.select(th).attr("width"))
            column_newX = d3.event.x # x + d3.event.dx
            if self.table.minWidth < column_newX
                d3.select(th).attr("width", column_newX + "px")
                d3.select(th).style("width", column_newX + "px")
                index = parseInt(d3.select(th).attr("ref"))
                self.columns[index].width = column_newX + "px"
                table_x = parseFloat(self.tableObject.attr("width"))
                table_newX = table_x + (column_newX - column_x) #x + d3.event.dx 
                self.tableObject.attr "width", table_newX+"px"
        th.style("position","relative")
        th.attr("class", "resizeable")
        th.append("span").attr('class','resize-tool').text('|').call drag
        #FIXME
        if i is @columns.length-1
            th = tr.append("th").style('width','10px')

    filterable: ->
        theadRow2 = @thead.append("tr")
        @columns.forEach (column, i) =>
            keyFiled = column.key
            self = @
            theadRow2.append("th").attr("meta-key", column.key).append("input").attr("type","text")
            .on "keyup", (d) ->
                console.log d3.select(this).node().value
                self.table.filterCondition.set(column.key, d3.select(this).node().value)
                console.log self.table.filterCondition
                #self.table.gridFilteredData = self.table.gridData
                #console.log self.table.gridFilteredData
                self.table.setFilter( self.table.gridFilteredData[0], self.table.filterCondition)

                #self.table.setID(self.table.gridFilteredData[0], self.table.gridFilteredData[0]._id)
                #self.update()

    deletable: (head)->
        if head
            @theadRow.append("th").text("delete")
        else
            @nodeEnter.append("td").attr('class', 'deletable').on("click", (d) =>
                if confirm "Are you sure you are going to delete this?"
                    @utils.removeNode d
                    @update() 
            )

    draggableIcon: ->
        @nodeEnter.prevend("td").attr('class', 'draggable')

    draggable: ->
        self = @
        dragbehavior = d3.behavior.drag()
            .origin(Object)
            .on "dragstart", (a,b,c)->
                console.log 'dragstart2'
                self.events.dragstart this,a,b,c
            .on "drag", (a,b,c)->
                console.log 'dragstart2'
                self.events.dragmove this,a,b,c
            .on "dragend", (a,b,c)->
                console.log 'dragstart2'
                self.events.dragend this,a,b,c
        @nodeEnter.call dragbehavior

    editable: (nodeName)->
        self = @
        nodeName.select("span").on "click", (a,b,c)->
            self.events.editable this,a,b,c 

    nested: (nodeName)->
        self = @
        nodeName.attr('class', (d) => @utils.icon (d))
        nodeName.on "click", (a,b,c)->
           self.events.click this,a,b,c

    render: ->
        self = @
        #console.log 'core render start'
        @data[0] = key: @table.noData unless @data[0]
        @tree = d3.layout.tree().children (d) -> d.values
        @nodes = @tree.nodes(@data[0])
        #console.log 'core render 1'

        wrap = d3.select(@table.get('el')).selectAll("div").data([[@nodes]])
        wrapEnter = wrap.enter().append("div").attr("class", "nvd3 nv-wrap nv-indentedtree")
        @tableEnter = wrapEnter.append("table")
        #console.log 'core render 2'

        @table.calculateTableWidth()
        @tableObject = wrap.select("table").attr("class", @table.tableClassName).attr("style","table-layout:fixed;").attr("width", @table.tableWidth + "px")
        #console.log 'core render 3'
        @renderHead() if @table.header
        #console.log 'core render 4'
        @renderBody()

    renderHead: ->
        #console.log 'renderHead start'
        @thead = @tableEnter.append("thead")
        @theadRow = @thead.append("tr")
        #console.log 'renderHead 1'

        @columns.forEach (column, i) =>
            th = @theadRow.append("th")
            th.attr("width", (if column.width then column.width else "100px")).attr("ref", i).style("text-align", (if column.type is "numeric" then "right" else "left"))
            th.style("width", (if column.width then column.width else "100px")).attr("ref", i).style("text-align", (if column.type is "numeric" then "right" else "left"))
            th.append("span").text column.label
            if @table is 'resizable'
                @resizable th 

        #console.log 'renderHead 2'
        @deletable true if @table.is 'deletable'
        @filterable() if @table.is 'filterable'
        @draggableIcon if 
        @
            
    renderBody: ->
        # generate tbody
        self = @
        #console.log 'core render body'
        tbody = @tableObject.selectAll("tbody").data((d) ->
            d
        )
        tbody.enter().append "tbody"
        # calculate number of columns
        depth = d3.max(@nodes, (node) ->
            node.depth
        )
        #console.log @table.height, depth, @table.childIndent
        @tree.size [@table.height, depth * @table.childIndent]

        #console.log 'core render nodes'
        i = 0
        node = tbody.selectAll("tr").data((d) ->
            d
        , (d) ->
            d.id or (d.id is ++i)
        )
        node.exit().remove()
        node.select(".expandable").classed "folded", @utils.folded
        @nodeEnter = node.enter().append("tr").attr('class', (d)->d.class)

        @draggable() if @table.is 'hierarchy_dragging'

        d3.select(@nodeEnter[0][0]).style("display", "none") if @nodeEnter[0][0]
        #console.log 'core render end'
        @columns.forEach (column, index) =>
            @renderColumn column,index,node

        @deletable() if @table.is 'deletable'
        #console.log 'here'
            
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
        #console.log 'renderColumn start',index,column
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
            nodeName.attr("ref", column.key)
            @nested nodeName if @table.is 'nested'

        @renderNodes column,nodeName

        if column.showCount
            nodeName.append("span").attr("class", "nv-childrenCount").text (d) ->
                (if ((d.values and d.values.length) or (d._values and d._values.length)) then "(" + ((d.values and d.values.length) or (d._values and d._values.length)) + ")" else "")
            
    renderNodes: (column,nodeName)->
        #console.log 'renderNode start'
        self = @
        nodeName.each (td)->
            if td.activatedID == column.key 
                d3.select(this).append("span").attr("class", d3.functor(column.classes))
                .append("input").attr('type', 'text').attr('value', (d) -> d[column.key] or "")
                .on "keydown", (d) -> 
                    self.events.keydown this,d
                .on "keyup", (a,b,c)->
                    self.events.keyup this,a,b,c
                .on "blur", (d) ->
                    self.events.blur this,d, column
                .node().focus()
            else
                d3.select(this).append("span").attr("class", d3.functor(column.classes)).text (d) ->
                    if column.format then column.format(d) else (d[column.key] or "-")

            self.editable nodeName if self.table.is('editable') and column.isEditable
            #console.log 'renderNode end'
