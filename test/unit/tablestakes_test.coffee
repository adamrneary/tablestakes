describe "Tablestakes API ", ->
  table = null
  data = [
    id: "NVD3"
    type: "ahaha"
    values: [
      id: "Charts"
      values: [
        id: "Simple Line"
        type: "Historical"
        values: [
          id: "Scatter / Bubble"
          type: "Snapshot"
          values: [
            id: "Stacked / Stream / Expanded Area"
            type: "Historical"
            values: [
              id: "Stacked / Stream / Expanded Area"
              type: "Historical"
              values: [
                id: "Line and Bar Combo"
                type: "Historical"
                values: [
                  id: "Cumulative Line"
                  type: "Historical"
                ]
              ,
                id: "Cumulative Line"
                type: "Historical"
              ]
            ]
          ]
        ]
      ]
    ,
      id: "Chart Components"
      _values: [
        id: "Legend"
        type: "Universal"
      ]
    ]
  ]
  setNewTreeValue = (tree, id, field, newValue) ->
    for node in tree
      if node.id is id
        node[field] = newValue
      else if node.values?
        setNewTreeValue(node.values, id, field, newValue)

  editHandler = (id, field, newValue) ->
    setNewTreeValue data, id, field, newValue
    table.data(data).render()

  columns = [
    id: "id"
    label: "Name"
    isEditable: true
    isNested: true
    onEdit: editHandler
  ,
    id: "type"
    label: "Type"
    isEditable: true
    onEdit: editHandler
  ]

  it 'is a function', (done) ->
    assert window.TableStakes
    assert typeof window.TableStakes is 'function'
    done()

  it 'has a basic constructor', (done) ->
    table = new window.TableStakes
    table.render()
    assert table
    done()

  describe "chainable getter/setter methods for most internal attributes", ->

    it 'should return the value set by the same method', ->

      attributes = [
        'data', 'isDeletable', 'onDelete', 'isResizable', 'isSortable',
        'dragMode', 'isDraggable', 'onDrag', 'isDragDestination', 'el',
        'rowClasses'
      ]
      _.each attributes, (attribute) ->
        testVal = Math.random()
        assert table[attribute](testVal) is table
        assert table[attribute]() is testVal

  describe "margin", ->
    it 'can set all margin attributes at once', (done) ->
      testHash =
        top: 40
        right: 10
        bottom: 30
        left: 50
      assert table.margin(testHash) is table
      assert table.margin()['top'] is 40
      assert table.margin()['right'] is 10
      assert table.margin()['bottom'] is 30
      assert table.margin()['left'] is 50
      done()

    it 'can set 1-2 margin attributes at a time', (done) ->
      testHash =
        top: 40
        right: 10
        bottom: 30
        left: 50
      assert table.margin(testHash) is table
      assert table.margin({top: 100}) is table
      assert table.margin({left: 200, right: 300}) is table
      assert table.margin()['top'] is 100
      assert table.margin()['right'] is 300
      assert table.margin()['bottom'] is 30
      assert table.margin()['left'] is 200
      done()

  describe "columns", ->
    it 'returns table on set and an array of Columns on get'

    it 'table options', (done) ->
      typeof table.filterCondition is 'object'
      table.filterCondition is 'd3_Map'
      typeof table.core is 'object'
      table.core is 'core'
      typeof table.events is 'object'
      table.events is 'events'
      typeof table.utils is 'object'
      table.utils is 'utils'
      done()

    it 'column', (done) ->
      table = new window.TableStakes()
        .el("#example")
        .data(data)
      assert table.columns(columns)
      done()

    it 'setID', (done) ->
      table.gridData = [values: table.data()]
      table.columns().forEach (column, i) =>
        table.gridData[0][column['id']] = column['id']
      table.setID table.gridData[0], "0"
      assert table.gridData[0]._id is "0"
      done()

    it 'render', (done) ->
      assert typeof table.render is 'function'
      assert table.render()
      done()

    it 'update', (done) ->
      #console.log 'table', table
      d3.select(table.el())
        .html('')
        .call( (selection) => assert table.update selection)
      assert typeof table.update is 'function'
      done()

    # it 'update with argument', (done) ->
    #   $(table.el())
    #     .datum(table.gridFilteredData)
    #     .call( (selection) => assert table.update selection )
    #   done()

    it 'dispatchManualEvent', (done) ->
      assert typeof table.dispatchManualEvent is 'function'
      #console.log d3.select('td')[0][0]._attributes.class._nodeValue
      #console.log d3.select('td').node()
      #table.dispatchManualEvent(d3.select('td').node())
      #d3.select('td')[0][0]._attributes.class._nodeValue
      #console.log d3.select('td')[0][0]._attributes.class._nodeValue
      #console.log 'node'
      #console.log d3.select('td').node()
      done()

    it 'table.set(testdata) and table.get(testdata)', (done) ->
      assert table.set('isResizable', true)
      assert table.get('isResizable') is true
      done()

    it 'table.is(testdata)', (done) ->
      assert table.is('isResizable') is true
      done()

    it 'columns', (done) ->
      table = new window.TableStakes()
        .el("#example")
        .data(data)
      columns = 'isnt array'
      assert table.columns(columns)
      done()

    it 'table.is(testdata)', (done) ->
      assert table.is('isResizable') is true
      assert table.is('isEditable') is false
      done()

    it 'filter', (done) ->
      assert typeof table.filter is 'function'
      assert table.filter 'key', 'S'
      assert table.filter 'id', 'NVD3'
      assert table.filterCondition.get('id') is 'NVD3'
      done()

    it 'has a basic constructor', (done) ->
      table = new window.TableStakes('editable': true)
      assert table
      done()

  # it 'attributes options', (done) ->
  #   assert typeof table.attributes is 'object'
  #   assert table.attributes.reorder_dragging is false
  #   assert table.attributes.nested is false
  #   assert table.attributes.resizable is false
  #   assert table.attributes.sortable is false
  #   done()
  #
  # it 'attributes reorder_dragging', (done) ->
  #   table.reorder_dragging(true)
  #   assert table.attributes.reorder_dragging is true
  #   done()
  #
  # it 'attributes nested', (done) ->
  #   table.nested(true)
  #   assert table.attributes.nested is true
  #   done()
  #
  # it 'attributes resizable', (done) ->
  #   table.resizable(true)
  #   assert table.attributes.resizable is true
  #   done()
  #
  # it 'table.set(testdata) and table.get(testdata)', (done) ->
  #   table.attributes = {resizable: false}
  #   assert table.set('resizable', true)
  #   assert table.get('resizable') is true
  #   done()
  #
  # it 'table.is(testdata)', (done) ->
  #   table.attributes = {resizable: true}
  #   assert table.is('resizable') is true
  #   done()


  #it 'table.sortable is true', (done) ->
    #assert typeof table.sortable is 'function'
    #assert table.sortable(true)
    #done()

  #it 'setFilter', (done) ->
    #assert typeof table.setFilter is 'function'
    #assert table.setFilter table.gridFilteredData[0], table.filterCondition
    #done()


#describe "Table: test function", ->
  #table = new window.TableStakes
  #it 'editable', (done)->
    #assert table.editable(true)
    #done()

  #it 'isDeletable', (done)->
    #assert table.isDeletable(true)
    #done()

  #it 'nested', (done)->
    #assert table.nested(true)
    #done()

  #it 'boolean', (done)->
    #assert table.boolean(true)
    #done()

  #it 'hierarchy_dragging', (done)->
    #assert table.hierarchy_dragging(true)
    #done()

  #it 'resizable', (done)->
    #assert table.resizable(true)
    #done()

  #it 'reorder_dragging', (done)->
    #assert table.reorder_dragging(true)
    #done()


#console.log 'cofeelint', coffeelint.lint("")
