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
        console.log 'here update'
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
            .on "dragend", (a,b,c)->
                self.events.reordragend this,a,b,c
        @nodeEnter.call dragbehavior


    #editable: (td)->
        #self = @
        #td.classed 'editable',true
        #td.select("span").on "click", (a,b,c)->
            #self.events.editable this,a,b,c 
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
            if column.classes?
                th.classed(column.classes, true)
        @deletable true if @table.is 'deletable'
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

        # @deletable() if @table.is 'deletable'
        console.log 1111
        if @table.is('deletable')
            console.log 444
            console.log 'boolean'
            @deletable()
        else if @table.is('deletable-filter')
            # console.log 555
            console.log 'function deletable-filter'
            filter = @table.get('deletable-filter')
            ok = filter(column)
            if ok
                @deletable()
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
            # @nested column_td if @table.is 'nested'
            console.log 222
            if @table.is('nested')
                console.log 888
                console.log 'boolean'
                @nested column_td
            else if @.table.is('nested-filter')
                console.log 'function nested-filter'
                filter = @.table.get('nested-filter')
                ok = filter(column)
                if ok
                    @nested column_td
            # @nested column_td if @table.is 'hierarchy_dragging'
            if @table.is('nested')
                console.log 999
                console.log 'boolean'
                @nested column_td
            else if @table.is('nested-filter')
                console.log 'function nested-filter'
                filter = @table.get('nested-filter')
                ok = filter(column)
                if ok
                    @nested column_td

        @renderNodes column,column_td

            #if column.classes?
                #th.classed(column.classes, true)
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

            if columnClass?
                d3.select(this).classed(columnClass, true)
            if column.classes?
                d3.select(this).classed(column.classes, true)

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
                                'editable boolean-false').style('display', 'table-cell')
                .on "click", (d) ->
                    if d3.select(this).attr('class') is 'editable boolean-false'
                       d[column.key] = 'true'
                       d3.select(this).attr('class', 'editable boolean-true')
                    else
                       d[column.key] = 'false'
                       d3.select(this).attr('class', 'editable boolean-false')
            else if columnClass is 'select'
                select = d3.select(this).classed('active', true).html('<select class="expand-select"></select>').select('.expand-select')
                for label in t[column.key].label
                    if typeof label is 'string'
                        option = select.append('option').text(label)
                    else
                        for options in label
                            if typeof options is 'string'
                                optgroup = select.append('optgroup').attr('label', options)
                            else
                                for index in options
                                    option = optgroup.append('option').text(index)


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
                            else if typeof d[column.key].label is 'string'
                                d[column.key].label
                        else
                            "-"
                console.log 'column.classes', column.classes

                ###console.log 3
                console.log 'editable'
                console.log 'table isEditable'
                console.log self.table.is('editable')
                console.log 'column isEditable'
                console.log column.isEditable###
                if self.table.is('editable') and column.isEditable
                    # console.log 4
                    console.log 'boolean'
                    self.editable column_td,t,this,column
                else if self.table.is('editable-filter')
                    # console.log 5
                    console.log 'function editable-filter'
                    filter = self.table.get('editable-filter')
                    ok = filter(column)
                    if ok
                        self.editable

                # if self.table.is('deletable') and column.isDeletable
                #     # console.log 444
                #     console.log 'boolean'
                #     self.deletable column_td,t,this,column
                # else if self.table.is('deletable-filter')
                #     # console.log 555
                #     console.log 'function deletable-filter'
                #     filter = self.table.get('deletable-filter')
                #     ok = filter(column)
                #     if ok
                #         self.deletable

                # if self.table.is('nested') and column.isNested
                #     console.log 'boolean'
                #     self.nested column_td,t,this,column
                # else if self.table.is('nested-filter')
                #     console.log 'function nested-filter'
                #     filter = self.table.get('nested-filter')
                #     ok = filter(column)
                #     if ok
                #         self.nested

                # if self.table.is('boolean') and column.isFilterable
                #     console.log 'boolean'
                #     self.boolean
                # elseif self.table.is('boolean-filter')
                #     console.log 'function boolean-filter'
                #     filter = self.table.get('boolean-filter')
                #     ok = filter(column)
                #     if ok
                #         self.boolean

                if self.table.is('filterable') and column.isFilterable
                    console.log 'boolean'
                    self.filterable
                else if self.table.is('filterable-filter')
                    console.log 'function filterable-filter'
                    filter = self.table.get('filterable-filter')
                    ok = filter(column)
                    if ok
                        self.filterable

                if self.table.is('hierarchy_dragging')
                    console.log 'boolean'
                    self.draggable
                else if self.table.is('hierarchy_dragging-filter')
                    console.log 'function hierarchy_dragging-filter'
                    filter = self.table.get('hierarchy_dragging-filter')
                    ok = filter(column)
                    if ok
                        self.draggable

                if self.table.is('resizable')
                    console.log 'boolean'
                    self.resizable
                else if self.table.is('resizable-filter')
                    console.log 'function resizable-filter'
                    filter = self.table.get('resizable-filter')
                    ok = filter(column)
                    if ok
                        self.resizable

                if self.table.is('reorder_dragging')
                    console.log 'boolean'
                    self.reorder_draggable
                else if self.table.is('reorder_dragging-filter')
                    console.log 'function reorder_dragging-filter'
                    filter = self.table.get('reorder_dragging-filter')
                    ok = filter(column)
                    if ok
                        self.reorder_draggable

    selectBox: (node,d,column)->
        #d3.select(node).classed('active', true)
        #console.log '.childNodes', d3.select(node)
        #select = d3.select(node).html('<span><select class="expand-select"></select></span>').select('.expand-select')
        #self = @
        #d3.select(node).classed('active', true)
        #select = d3.select(node).html('<select class="expand-select"></select>').select('.expand-select')
        #if @val?
            #option = select.append('option').style('cursor', 'pointer').text(@val).style('display', 'none')
        #for label in d[column.key].label
            #if typeof label is 'string'
                #option = select.append('option').text(label)
            #else
                #for options in label
                    #if typeof options is 'string'
                        #optgroup = select.append('optgroup').style('cursor', 'pointer').attr('label', options)
                    #else
                        #for index in options
                            #option = optgroup.append('option').style('cursor', 'pointer').text(index)
        #select.on 'click', (d) ->
            #select.remove()
            #d3.select(node).append('span').text(d3.event.target.value)
            #self.val = d3.event.target.value


    editable: (td,d,node,column)->
        self = @
        td.classed 'editable',true
        if @table.is 'nested'
            event = 'dblclick'
        else
            event = 'click'
        td.on event, (a,b,c)->
            self.events.editable this,a,b,c,column
        if d.activatedID == column.key
            if d[column.key].classes is 'select'
                @selectBox(node,d,column)
            else
                d3.select(node).classed('active',true).attr('contentEditable',true)
                .on "keydown", (d)->
                    self.events.keydown this, d
                .on "blur", (d) ->
                    self.events.blur this, d, column
                .node().focus()
        else if d.changedID and d.changedID.indexOf(column.key) isnt -1
            d3.select(node).classed 'changed',true
