class window.TablesStakes

# Public Variables
    attributes: {}

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
    gridData : []
    gridFilteredData : []
    tableObject : null
    minWidth : 50
    tableWidth : 0

    isInRender : false
    filterCondition : []

    constructor: (options)->
        @set 'sortable', false
        @set 'editable', false
        @set 'deletable', false
        @set 'filterable', false
        @set 'resizable', false
        @set 'hierarchy_dragging', false
        if options?
            for key of options
                @set key, options[key]

    render: () ->
        #console.log 'Table render'
        @gridData = [values: @get('data')]
        @columns.forEach ( column, i) =>
          @gridData[0][column['key']] = column['key'] 
        @setID @gridData[0], "0"
        @gridFilteredData = @gridData
        @setFilter @gridFilteredData[0], @filterCondition
        console.log @gridFilteredData
        d3.select(@get('el')).datum(@gridFilteredData).call( (selection) => @update selection )
        #console.log 'table render end'
        @

    update: (selection) -> 
        #console.log 'table update, selection:',selection
        selection.each (data)=> 
            new window.TablesStakesLib.render
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
        #console.log 'table setFilter start',data,filter
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

    set: (key,value,options)->
        @attributes[key] = value if key? and value?
        #@[key] = value
        switch key
            when 'columns'
                @filterCondition = d3.map([])
        @

    get: (key)->
        @attributes[key]

    is: (key)->
        if @attributes[key]
            true
        else
            false

    #============================================================
    # Expose Public Variables
    #------------------------------------------------------------

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



