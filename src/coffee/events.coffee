window.TableStakesLib = {} unless window.TableStakesLib
class window.TableStakesLib.events

    constructor: (options)->
        console.log 'core', options.core
        @core = options.core


    # keydown editing cell
    keydown: (node, d, column) ->
        switch d3.event.keyCode
            when 9  #tab
                currentindex = @core.utils.getCurrentColumnIndex d.activatedID
                if d3.event.shiftKey == false                                                  # if shiftkey is not pressed, get next
                    if(currentindex < @core.columns.length - 1)
                        d.activatedID = @core.columns[currentindex+1].key
                    else
                        nextNode = @core.utils.findNextNode d, @core.nodes
                        if nextNode isnt null
                            nextNode.activatedID = @core.columns[0].key
                            d.activatedID = null
                else                                                                           # if shiftkey is not pressed, get previous
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
                column.onEdit(d.key, column.key, val) if column.onEdit
                d.changedID ?= []
                d.changedID.push d.activatedID if d.changedID.indexOf(d.activatedID) is -1
                d.activatedID = null
                @core.update()

            when 27 #escape
                d3.select(node).node().value = d[d.activatedID]
                d.activatedID = null
                @core.update()
        # clavey handler enter and esc

    # removal of the selection from the active cell
    blur: (node, d, column) ->
        if @core.table.isInRender == false
            val = d3.select(node).text()
            column.onEdit(d, column.key, val) if column.onEdit
            d.activatedID = null
            @core.update()

    dragstart: (node, d) ->
        console.log 'dragstart'
        self = @
        d3.select(node).classed('dragged',true)
        targetRow = @core.table.get('el') + " tbody tr:not(.dragged)"
        @draggingObj = d._id
        console.log '@draggingObj', @draggingObj
        @draggingTargetObj = null
        @init_coord = $(node).position()
        @init_pos = d.parent.children
        @pos = $(node).position()
        @pos.left += d3.event.sourceEvent.layerX
        $(node).css
            left: @pos.left
            top: @pos.top
        d3.selectAll(targetRow).on("mouseover", (d) ->
            console.log 'mouseover'
            d3.select(this).attr("class", "draggable-destination")
            self.draggingTargetObj = d._id
            d3.event.stopPropagation()
            d3.event.preventDefault()
        )
        .on("mouseout", (d) ->
            console.log 'mouseout'
            d3.select(this).classed("draggable-destination",false)
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
        console.log 'dragend'
        d.parent.children = @init_pos
        $(node).css
            left: @init_coord.left
            top: @init_coord.top
        d3.select(node).attr("class", "")
        targetRow = @core.table.get('el') + " tbody tr"
        d3.selectAll(targetRow)
        .on("mouseover", null)
        .on("mouseout", null)
        .style("background-color", null)
        if @draggingTargetObj == null
            return;
        if @draggingObj.substr(0,3) == @draggingTargetObj.substr(0,3)
            return
        parent = @core.utils.findNodeByID @draggingTargetObj
        child = @core.utils.findNodeByID @draggingObj
        console.log 'child', child
        @core.utils.removeNode child
        @core.utils.appendNode parent, child
        @core.update()

    reordragstart: (node, d) ->
        console.log 'dragstart', @core.table.get('el')
        self = @
        targetRow = @core.table.get('el') + " tbody tr .draggable"
        @draggingObj = d._id
        @draggingTargetObj = null
        d3.selectAll(targetRow).on("mouseover", (d) ->
            if(self.draggingObj == d._id.substring(0, self.draggingObj.length))
                return
            d3.select(this.parentNode).attr("class", "draggable-destination1")
            self.draggingTargetObj = d._id
        )
        .on("mouseout", (d) ->
            d3.select(this.parentNode).attr("class", "")
            self.draggingTargetObj = null
        )

    reordragend: (node,d) ->
        console.log 'dragend'
        targetRow = @core.table.get('el') + " tbody tr .draggable"
        d3.selectAll(targetRow)
        .on("mouseover", null)
        .on("mouseout", null)
        .style("background-color", null)
        if @draggingTargetObj == null
            return;
        brother = @core.utils.findNodeByID @draggingTargetObj
        child = @core.utils.findNodeByID @draggingObj
        @core.utils.removeNode child
        @core.utils.pastNode brother, child
        @core.update()

    # change row if class editable
    editable: (node,d, _, unshift)->
        console.log 'events editable'
        unless d3.select(node).classed('active')
            @core.utils.deactivateAll @core.data[0]
            d.activatedID = d3.select(d3.select(node).node()).attr("meta-key")
            @core.update()
            d3.event.stopPropagation()
            d3.event.preventDefault()

    # toggle nested
    click: (node,d, _, unshift) ->
        console.log 'events toggle nested click'

        if d3.event.shiftKey and not unshift
            #If you shift-click, it'll toggle fold all the children, instead of itself
            #d3.event.shiftKey = false
            self = @
            if d.values
                d.values.forEach (node)->
                    self.click this,node, 0, true if node.values or node._values
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
