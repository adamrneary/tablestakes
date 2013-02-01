window.TablesStakesLib = {} unless window.TablesStakesLib
class window.TablesStakesLib.events

    constructor: (options)->
        @core = options.core


    # keydown editing cell
    keydown: (node,d) ->
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
                d.changedID = [] unless d.changedID
                d.changedID.push d.activatedID
                d.activatedID = null
                @core.update()
            when 27 #escape
                d3.select(node).node().value = d[d.activatedID]
                d.activatedID = null
                @core.update()
        # clavey handler enter and esc 

    # decrease of the selection from the active cell
    blur: (node,d, column) ->
        #cell = d3.select(node)
        #hz = d3.select(node)[0][0]
        #cell.text(d3.select(node).node().value)
        if @core.table.isInRender == false
            val = d3.select(node).text()
            columnKey = d3.select(node)[0][0].getAttribute("ref")
            d[columnKey] = val
            d[column.key] = val
            d[column.key] = val
            d.activatedID = null
            @core.update()

    dragstart: (node,d) ->
        console.log 'dragstart'
        self = @
        targetRow = @core.table.get('el') + " tbody tr"
        @draggingObj = d._id
        console.log '@draggingObj', @draggingObj
        @draggingTargetObj = null
        d3.selectAll(targetRow).on("mouseover", (d) ->
            if(self.draggingObj == d._id.substring(0, self.draggingObj.length))
                return
            d3.select(this).attr("class", "draggable-destination")
            self.draggingTargetObj = d._id
        )
        .on("mouseout", (d) ->
            d3.select(this).attr("class", "") 
            self.draggingTargetObj = null 
        )
    dragmove: (d) ->
        #console.log 'dragmove'
        
    dragend: (node,d) ->
        console.log 'dragend'
        targetRow = @core.table.get('el') + " tbody tr"
        d3.selectAll(targetRow)
        .on("mouseover", null)
        .on("mouseout", null)
        .style("background-color", null)
        if @draggingTargetObj == null
            return;
        parent = @core.utils.findNodeByID @draggingTargetObj
        child = @core.utils.findNodeByID @draggingObj
        console.log 'child', child
        @core.utils.removeNode child
        @core.utils.appendNode parent, child
        @core.update()

    reordragstart: (node,d) ->
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
        console.log 'node', node.childNodes[0]
        console.log 'events editable'
        unless d3.select(node).classed('active')
            @core.utils.deactivateAll @core.data[0]
            d.activatedID = d3.select(d3.select(node).node()).attr("meta-key")
            @core.update()
            #$(".active .date").datepicker()
            d3.event.stopPropagation()
            d3.event.preventDefault()
            #console.log $(".active .date").datepicker().val


    # toggle nested
    click: (node,d, _, unshift) ->
        console.log 'events toggle nested click'
        #d.activatedID = null

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
