table = null
describe "Table: ", ->
    data = [
      key: 'Example1'
      type: "ahaha"
    ,
      key: "Simple Line"
      type: "Historical"
    ,
      key: "Scatter / Bubble"
      type: "Snapshot"
    ,
      key: "Stacked / Stream / Expanded Area"
      type: "Historical"
    ,
      key: "Discrete Bar"
      type: "Snapshot"
    ,
      key: "Grouped / Stacked Multi-Bar"
      type: "Snapshot / Historical"
    ,
      key: "Horizontal Grouped Bar"
      type: "Snapshot"
    ,
      key: "Line and Bar Combo"
      type: "Historical"
    ,
      key: "Cumulative Line"
      type: "Historical"
    ,
      key: "Line with View Finder"
      type: "Historical"
    ,
      key: "Legend"
      type: "Universal"
    ,
      key: "New Root"
      type: "tatata"
    ,
      key: "1"
      type: "123"
    ]

    columns = [
      key: "key"
      label: "Name"
      showCount: false
      width: "400px"
      isEditable: true
      classes: "row-heading"
    ,
      key: "type"
      label: "Type"
      width: "300px"
      isEditable: false
    ]

    grid = new window.TableStakes(
      columns: columns
      data: data
      el: "#example"
    )
    grid.render()
    table = new window.TableStakes
    #$('<input id="filter1" column="key" type="text" value="S" />').appendTo('#temp')


    it 'window.tablestakes is function', (done)->
        assert window.TableStakes
        assert typeof window.TableStakes is 'function'
        done()

    it 'constructor', (done)->
        assert table
        done()

    it 'table options', (done)->
        typeof table.filterCondition is 'object'
        table.filterCondition is 'd3_Map'
        typeof table.core is 'object'
        table.core is 'core'
        typeof table.events is 'object'
        table.events is 'events'
        typeof table.utils is 'object'
        table.utils is 'utils'
        done()

    it 'render', (done)->
        assert typeof table.render is 'function'
        assert table.render
        done()

    it 'update', (done)->
        assert typeof table.update is 'function'
        assert table.update
        done()

    it 'update  with argument', (done)->
        d3.select(table.get('el')).datum(table.gridFilteredData).call( (selection) => assert table.update selection )
        done()

    it 'dispatchManualEvent', (done)->
        assert typeof table.dispatchManualEvent is 'function'
        assert table.dispatchManualEvent
        done()

    it 'setID', (done)->
        assert typeof table.setID is 'function'
        assert table.setID
        done()

    it 'attributes options', (done)->
        assert typeof table.attributes is 'object'
        assert typeof table.attributes.columns is 'object'
        assert table.attributes.columns.length is columns.length
        assert typeof table.attributes.data is 'object'
        assert table.attributes.data.length is data.length
        assert table.attributes.el is "#example"
        assert table.attributes.reorder_dragging is false
        assert table.attributes.deletable is false
        assert table.attributes.filterable is false
        assert table.attributes.nested is false
        assert table.attributes.resizable is false
        assert table.attributes.sortable is false
        done()

    it 'attributes reorder_dragging', (done)->
        grid.reorder_dragging(true)
        assert table.attributes.reorder_dragging is true
        done()

    it 'attributes deletable', (done)->
        grid.isDeletable(true)
        assert table.attributes.deletable is true
        done()

    it 'attributes filterable', (done)->
        grid.filterable(true)
        assert table.attributes.filterable is true
        done()

    it 'attributes nested', (done)->
        grid.nested(true)
        assert table.attributes.nested is true
        done()

    it 'attributes resizable', (done)->
        grid.resizable(true)
        assert table.attributes.resizable is true
        done()

    it 'table.set(testdata) and table.get(testdata)', (done)->
        table.attributes = {deletable: false}
        assert table.set('deletable', true) 
        assert table.get('deletable') is true
        done()

    it 'table.is(testdata)', (done)->
        table.attributes = {deletable: true}
        assert table.is('deletable') is true
        done()


    it 'table.margin(testdata)', (done) ->
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
        assert table.margin.top is 40
        assert table.margin.right is 10
        assert table.margin.bottom is 30
        assert table.margin.left is 50
        done()

    it 'table.sortable is true', (done)->
        assert typeof table.sortable is 'function'
        assert table.sortable(true)
        done()

    it 'setFilter', (done)->
        assert typeof table.setFilter is 'function'
        assert grid.setFilter grid.gridFilteredData[0], grid.filterCondition
        done()

    it 'filter', (done)->
        data = data[0]
        assert typeof table.filter is 'function'
        assert grid.filter 'key', 'S' 
        assert grid.filterCondition.get('key') is 'S'
        done()

describe "Table: test function", ->
    table = new window.TableStakes
    it 'editable', (done)->
        assert table.editable(true)
        done()

    it 'isDeletable', (done)->
        assert table.isDeletable(true)
        done()

    it 'nested', (done)->
        assert table.nested(true)
        done()

    it 'boolean', (done)->
        assert table.boolean(true)
        done()

    it 'filterable', (done)->
        assert table.filterable(true)
        done()

    it 'hierarchy_dragging', (done)->
        assert table.hierarchy_dragging(true)
        done()

    it 'resizable', (done)->
        assert table.resizable(true)
        done()

    it 'reorder_dragging', (done)->
        assert table.reorder_dragging(true)
        done()


describe "Events", ->
    event = window.TableStakesLib.events

    it 'window.TableStakesLib.events is function', (done)->
        assert typeof window.TableStakesLib.events is 'function'
        assert window.TableStakesLib.events
        done()

    it 'events constructor', (done)->
        assert event
        done()
#console.log 'cofeelint', coffeelint.lint("")

