describe "Events", ->
  event = null
  table = null
  data = [
    id: "NVD3"
    type: "ahaha"
    values: [
      id: "Charts"
      _values: [
        id: "Simple Line"
        type: "Historical"
      ,
        id: "Scatter / Bubble"
        type: "Snapshot"
      ,
        id: "Stacked / Stream / Expanded Area"
        type: "Historical"
      ,
        id: "Discrete Bar"
        type: "Snapshot"
      ,
        id: "Grouped / Stacked Multi-Bar"
        type: "Snapshot / Historical"
      ,
        id: "Horizontal Grouped Bar"
        type: "Snapshot"
      ,
        id: "Line and Bar Combo"
        type: "Historical"
      ,
        id: "Cumulative Line"
        type: "Historical"
      ,
        id: "Line with View Finder"
        type: "Historical"
      ]
    ,
      id: "Chart Components"
      values: [
        id: "Legend"
        type: "Universal"
      ]
    ]
  ,
    id: "New Root"
    type: "tatata"
    classes: "rowcustom1"
    values: [
      id: "1"
      type: "123"
      classes: "rowcustom"
    ]
  ]
  columns = [
    id: "id"
    label: "Name"
    classes: 'row-heading'
    isEditable: true
    isNested: true
  ,
    id: "type"
    label: "Type"
    isEditable: true
  ]

  d = {
    _hiddenvalues: [],
    _id: "0_6",
    activatedID: "Simple Line",
    changedID: null,
    depth: 1,
    id: "Simple Line",
    parent: {}
    type: "Snapshot",
    x: 0.5,
    y: 1
  }
  column = {
    id: "id",
    label: "Name",
    classes: "row-heading",
    onEdit: ->
      d.id = 'test'
  }

  before (done)->
    d3.select('body').append('div').attr('id','example')
    done()

  it 'window.TableStakesLib.Events is function', (done)->
    assert window.TableStakesLib
    assert typeof window.TableStakesLib.Events is 'function'
    assert window.TableStakesLib.Events
    done()

  it 'events constructor', (done)->
    event = new window.TableStakesLib.Events
      core: {
        table: {
          isInRender: false,
          el: ->
            return '#example'
          onDrag: ->
            return d
          dragMode: ->
            'reorder'
        }
        update: ->
          return true
        utils: {
          getCurrentColumnIndex: ->
            return 3
          findNextNode: ->
            return d
          findPrevNode: ->
            return d
          deactivateAll: ->
            true
        }
        columns: [{'id': 2}, {'id': 3}, {'id': 4}],
        nodes: [],
        data: [{'id': 2}]
      }
    assert event
    done()


  it 'blur', (done)->
    table = new window.TableStakes()
      .el("#example")
      .data(data)
      .columns(column)
    td = d3.select('#NVD3')
    assert event.blur(td, d, column)
    done()

  it 'keydown press tab, shiftKey-false and ColumnIndex=3', (done)->
    d3.event = {
      'keyCode': 9,
      'shiftKey': false,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    _table = new window.TableStakes()
      .el("#example")
      .columns(columns)
      .data(data)
      .render()
    event = _table.core.events
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  it 'keydown press tab, shiftKey-false and ColumnIndex = 1', (done)->
    d3.event = {
      'keyCode': 9,
      'shiftKey': false,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    td = d3.select('td').node()
    _table = new window.TableStakes()
      .el("#example")
      .columns(columns)
      .data(data)
      .render()
    event = _table.core.events
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  it 'keydown press tab, shiftKey-true and ColumnIndex = 3', (done)->
    d3.event = {
      'keyCode': 9,
      'shiftKey': true,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    _table = new window.TableStakes()
      .el("#example")
      .columns(columns)
      .data(data)
      .render()
    event = _table.core.events
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  it 'keydown press tab, shiftKey-true and  ColumnIndex = 0', (done)->
    d3.event = {
      'keyCode': 9,
      'shiftKey': true,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    td = d3.select('td').node()
    _table = new window.TableStakes()
      .el("#example")
      .columns(columns)
      .data(data)
      .render()
    event = _table.core.events
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  it 'keydown press up', (done)->
    d3.event = {
      'keyCode': 38,
      'shiftKey': true,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    _table = new window.TableStakes()
      .el("#example")
      .columns(columns)
      .data(data)
      .render()
    event = _table.core.events
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  it 'keydown press down', (done)->
    d3.event = {
      'keyCode': 40,
      'shiftKey': true,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    _table = new window.TableStakes()
      .el("#example")
      .columns(columns)
      .data(data)
      .render()
    event = _table.core.events
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  it 'keydown press Enter', (done)->
    d3.event = {
      'keyCode': 13,
      'shiftKey': true,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    td = d3.select('#NVD3')
    assert event.keydown(td, d, column)
    done()

  it 'keydown press Escape', (done)->
    d3.event = {
      'keyCode': 27,
      'shiftKey': true,
      'x': 45,
      'y': 56,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    td = d3.select('#NVD3')
    assert event.keydown(td, d, column)
    done()

  it 'dragStart', (done)->
    tr = d3.select('#NVD3')
    tr['getBoundingClientRect'] = -> [34, 23]
    # assert event.dragStart(tr, d, 120, 70)
    done()

  it 'dragMove', (done)->
    tr = d3.select('#NVD3')
    # assert event.dragMove(tr, d, 14, 25)
    done()

  #it 'dragEnd', (done)->
    #tr = d3.select('tr').node()
    #event['destinationIndex'] = 45
    #event['destination'] = 23
    #console.log event.dragEnd(tr, d, 56, 78)
    #event.core.table.dragMode = 'hierarchy'
    #assert event.dragEnd(tr, d, 56, 78)
    #done()

  it 'resizeDrag'
  #it 'resizeDrag', (done)->
    #_table = new window.TableStakes()
      #.el("#example")
      #.columns(columns)
      #.data(data)
      #.render()
    #event = _table.core.events

    #td = d3.select('.resizeable-handle')[0]
    #console.log td
    ##td = '.resizeable-handle'
    #assert event.resizeDrag(td)

    #done()

  it 'editableClick', (done)->
    td = d3.select('#NVD3')
    # assert event.editableClick(td, d, 2, 0)
    # assert d.activatedID is 'id'
    done()

  it 'nestedClick', (done)->
    td = d3.select('td').node()
    a = {
      values:[3,8]
    }
    d.values = [a]
    #td.values = [5,7]
    assert event.nestedClick(td, d, 2, false)
    assert d.values[0].values is null
    assert d.values[0]._values isnt null
    assert event.nestedClick(td, d, 2, true)
    assert d.values is null
    assert d._values isnt null
    assert event.nestedClick(td, d, 2, true)
    assert d.values isnt null
    assert d._values is null
    done()

  it 'toggleBoolean', (done)->
    td = d3.select('td').node()
    assert event.toggleBoolean(td, d, 2, 0, column)
    assert d.id is 'test'
    done()

  it 'selectClick', (done)->
    d.id = 0
    d3.event = {
      target: {
        value: 1
      }
    }
    td = d3.select('td').node()
    assert event.selectClick(td, d, 2, 0, column)
    assert d.id is 'test'
    done()

#describe "Events+zombie", ->
  #event = null
  #$ = null
  #window = null
  #browser = null
  #before (done) ->
    #glob.zombie.visit glob.url+"#reorder_dragging", (err, _browser) ->
      #browser = _browser
      #window = browser.window
      #$ = window.$
      #done()

  #it 'dragStart', (done)->
    #tr = d3.select('tr').node()
    #event = new window.TableStakesLib.Events
    #assert event.dragStart(tr, d)
    #done()

