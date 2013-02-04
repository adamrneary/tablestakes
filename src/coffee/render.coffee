window.TablesStakesLib = {} unless window.TablesStakesLib
class window.TablesStakesLib.core

    constructor: (options)->
        console.log 'core constructor'
        #console.log 'options:',options
        @utils = new window.TablesStakesLib.utils
            core: @
        @events = new window.TablesStakesLib.events
            core: @

    set: (options)->
        @table = options.table
        @selection = options.selection
        @data = options.data
        @columns = @table.get('columns')

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
                self.tableObject.style "width", table_newX+"px"
        th.classed 'resizeable',true
        th.append("div").classed('resizeable-handle right', true).call drag

    #filterable: ->
        #self = @
        #theadRow2 = @thead.append("tr")
        #theadRow2.append('th').attr('width','10px') if @table.is 'hierarchy_dragging'
        #@columns.forEach (column, i) =>
            #keyFiled = column.key
            #self = @
            #theadRow2.append("th").attr("meta-key", column.key).append("input").attr("type","text")
            #.on "keyup", (d) ->
                #self.table.filterCondition.set(column.key, d3.select(this).node().value)
                #self.table.setFilter self.table.gridFilteredData[0], self.table.filterCondition
                #self.table.render()
            #console.log '@columns', @columns.length
        #if @table.is 'deletable' 
            #theadRow2.append("th").attr('width','15px')
    deletable: (head)->
        if head
            @theadRow.append("th").attr('width','15px')
        else
            @nodeEnter.append("td").attr('class', 'deletable').on("click", (d) =>
                if confirm "Are you sure you are going to delete this?"
                    @utils.removeNode d
                    @update() 
            )


    draggable: ->
        self = @
        dragbehavior = d3.behavior.drag()
            .origin(Object)
            .on "dragstart", (a,b,c)->
                self.events.dragstart this,a,b,c
            .on "drag", (a,b,c)->
                self.events.dragmove this,a,b,c
            .on "dragend", (a,b,c)->
                self.events.dragend this,a,b,c
        @nodeEnter.call dragbehavior

    reorder_draggable: ->
        self = @
        @nodeEnter.insert("td").classed('draggable', true)
        dragbehavior = d3.behavior.drag()
            .origin(Object)
            .on "dragstart", (a,b,c)->
                self.events.reordragstart this,a,b,c
            .on "drag", (a,b,c)->
                self.events.dragmove this,a,b,c
            .on "dragend", (a,b,c)->
                self.events.reordragend this,a,b,c
        @nodeEnter.call dragbehavior


    editable: (td)->
        self = 
        td.classed 'editable',true
        td.select("span").on "click", (a,b,c)->
            self.events.editable this,a,b,c 
    nested: (nodeName)->
        self = @
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
        wrapEnter = wrap.enter().append("div")
        @tableEnter = wrapEnter.append("table")
        @tableObject = wrap.select("table").classed(@table.tableClassName,true).attr("style","table-layout:fixed;")
        @renderHead() if @table.header
        @renderBody()
        

    renderHead: ->
        #console.log 'renderHead start'
        @thead = @tableEnter.append("thead")
        @theadRow = @thead.append("tr")
        @theadRow.append('th').attr('width','10px') if @table.is 'reorder_dragging'
        #console.log 'renderHead 1'

        @columns.forEach (column, i) =>
            th = @theadRow.append("th")
            th.attr("ref", i)
            if column.width
                th.style("width", column.width)
            if column.classes is 'boolean'
                th.style("width", '60px')
            th.append("span").text column.label
            @resizable th if @table.is 'resizable'

        @deletable true if @table.is 'deletable'
        #@filterable() if @table.is 'filterable'
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
        #console.log node
        #try
        node.exit().remove()
        node.select(".expandable").classed "folded", @utils.folded
        @nodeEnter = node.enter().append("tr").classed('class', (d)->d._classes)
        @draggable() if @table.is 'hierarchy_dragging'
        @reorder_draggable() if @table.is 'reorder_dragging'

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
        #console.log 'document', document
        col_classes = ""
        col_classes += column.classes if typeof column.classes != "undefined"

        column_td = @nodeEnter.append("td").attr("meta-key",column.key)
        .attr("class", (d)=>
            row_classes = ""
            row_classes = d.classes if typeof d.classes != "undefined"
            return col_classes + " " + row_classes
        )

        if index is 0
            column_td.attr("ref", column.key)
            column_td.attr('class', (d) => @utils.icon (d))
            @nested column_td if @table.is 'nested'
            @nested column_td if @table.is 'hierarchy_dragging'

        @renderNodes column,column_td


        if column.showCount
            td.append("span").attr("class", "nv-childrenCount").text (d) ->
                (if ((d.values and d.values.length) or (d._values and d._values.length)) then "(" + ((d.values and d.values.length) or (d._values and d._values.length)) + ")" else "")
            
    renderNodes: (column,column_td)->
        #console.log 'renderNode start'
        self = @
        column_td.each (t,i)->
            #console.log t[column.key]
            if t[column.key] and t[column.key].classes?
                classes = t[column.key].classes.split(' ')
                for _class in classes
                    d3.select(this).classed _class,true
                columnClass = t[column.key].classes
            if column.classes is 'boolean' or columnClass is 'boolean'
                #console.log 'here', classes
                span = d3.select(this).attr('class', (d)->
                    if d[column.key]
                        if typeof d[column.key] is 'string'
                            if d[column.key] is 'true' or d[column.key] is 'y' or d[column.key] is 'Y' or d[column.key] is 'yes' or d[column.key] is 'Yes' or d[column.key] is '+' or d[column.key] is 'good' or d[column.key] is 'ok'
                                'editable boolean-true'
                            else
                                'editable boolean-false'
                        else
                            if d[column.key].label is 'true'
                                'editable boolean-true'
                            else
                                'editable boolean-false')
                .on "click", (d) ->
                    if d3.select(this).attr('class') is 'editable boolean-false'
                       d[column.key] = 'true'
                       d3.select(this).attr('class', 'editable boolean-true')
                    else
                       d[column.key] = 'false'
                       d3.select(this).attr('class', 'editable boolean-false')

            else if columnClass is 'select_box'
                d3.select(this).classed('select', true)
                console.log 'here'
                select = d3.select(this).html('<select class="expand-select"></select>').select('.expand-select')
                for label in t[column.key].label
                    if typeof label is 'string'
                        option = select.append('option').text(label)
                    else
                        for options in label
                            if typeof options is 'string'
                                optgroup = select.append('optgroup').style('cursor', 'pointer').attr('label', options)
                            else
                                for index in options
                                    selection = optgroup.append('option').style('cursor', 'pointer').text(index)
            else
                span = d3.select(this).append("span").attr("class", d3.functor(column.classes))
                innerSpan = span.append('span').text (d) ->
                    #console.log d3.select(this)
                    if column.format
                        column.format(d) 
                    else 
                        if d[column.key]
                            if typeof d[column.key] is 'string'
                                d[column.key]
                            else if d[column.key].label is 'string'
                                d[column.key].label
                            else if typeof d[column.key].label[0] is 'string'
                                d[column.key].label[0]
                        else
                            "-"
                self.editable column_td,t,this,column if self.table.is('editable') and column.isEditable


    editable: (td,d,node,column)->
        self = @
        td.classed 'editable',true
        if @table.is 'nested'
            event = 'dblclick'
        else
            event = 'click'
        td.on event, (a,b,c)->
            self.events.editable this,a,b,c
        if d.activatedID == column.key
            d3.select(node).classed('active',true).attr('contentEditable',true)
            .on "keydown", (d)->
                self.events.keydown this, d
            .on "blur", (d) ->
                self.events.blur this, d, column
            .node().focus()
        else if d.changedID and d.changedID.indexOf(column.key) isnt -1
            d3.select(node).classed 'changed',true
