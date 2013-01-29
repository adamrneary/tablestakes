window.TablesStakesLib = {} unless window.TablesStakesLib
class window.TablesStakesLib.utils

    constructor: (options)->
        @core = options.core

    getCurrentColumnIndex: (id) ->
        console.log 'core getCurrentColumnIndex, id:',id
        currentindex = @core.columns.length
        for col, i in @core.columns
          if col.key == id
            currentindex = i
            break
        currentindex

    findNextNode: (d) ->
        console.log 'core findNextNode'
        nextNodeID = null
        for leaf, i in @core.nodes
          if leaf._id == d._id
            if @core.nodes.length != i + 1
              nextNodeID = @core.nodes[i + 1]._id
            break
        return null if nextNodeID is null
        idPath = nextNodeID.split "_"
        root = @core.data[0]
        root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
        root

    findPrevNode: (d) ->
        console.log 'core findPrevNode'
        prevNodeID = null
        for leaf, i in @core.nodes
          if leaf._id == d._id
            break
          prevNodeID = leaf._id
        return null if prevNodeID is null or prevNodeID is "0"
        idPath = prevNodeID.split "_"
        root = @core.data[0]
        root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
        root

    removeNode: (d) ->
        parent = d.parent
        currentindex = parent.values.length
        for i in [0..parent.values.length - 1]
            if d._id == parent.values[i]._id
                currentindex = i
                break
        parent.values.splice currentindex, 1
        parent.children.splice currentindex, 1
        @core.table.setID parent, parent._id

    appendNode: (d, child) ->
        if d.values
            d.values.push(child)
        else if d._values
            d._values.push(child)
        else 
            d.values = [child]
        @core.table.setID d, d._id
        #child.parent = d

    findNodeByID: (id) ->
        idPath = id.split "_"
        root = @core.table.gridFilteredData[0]
        root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
        root

    deactivateAll: (d) ->
        d.activatedID = null
        if d.values
            d.values.forEach (item, index) => @core.utils.deactivateAll(item)
        if d._values
            d._values.forEach (item, index) => @core.utils.deactivateAll(item)
        return

    hasChildren: (d) ->
        values = d.values or d._values
        values and values.length

    folded: (d) ->
        d._values and d._values.length

    # change icons during deployment-folding
    icon: (d)->
        if d._values and d._values.length
            'expandable' + ' ' + 'indent' + d.depth
        else 
            if d.values and d.values.length
                'collapsible' + ' ' + 'indent' + d.depth
            else 'indent' + d.depth
