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
      return true
  }

  it 'window.TableStakesLib.Events is function', (done)->
    assert window.TableStakesLib
    assert typeof window.TableStakesLib.Events is 'function'
    assert window.TableStakesLib.Events
    done()

  it 'events constructor', (done)->
    # Test data, add real data
    event = new window.TableStakesLib.Events
      core: {
        table: {
          isInRender: false,
          el: ->
            return '#example'
        }
        update: ->
          return true
        utils: {
          getCurrentColumnIndex: ->
            # return 1
            # return 3
            return 0
          findNextNode: ->
            return d
          findPrevNode: ->
            return d
        }
        columns: [0: {'id': 2}, 1: {'id': 3}, 2: {'id': 4}],
        # columns: {0: {'id': 2}, 1: {'id': 3}, 2: {'id': 4}},
        nodes: []
      }
    # Test data, add real data
    assert event
    done()


  it 'blur', (done)->
    table = new window.TableStakes()
      .el("#example")
      .data(data)
      .columns(column)
    td = d3.select('td').node()
    assert event.blur(td, d, column)
    done()

  it 'keydown press tab', (done)->
    # Test data, add real data
    d3.event = {
      'keyCode': 9,
      # 'shiftKey': true,
      'shiftKey': false,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    # Test data, add real data
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  it 'keydown press up', (done)->
    # Test data, add real data
    d3.event = {
      'keyCode': 38,
      'shiftKey': true,
      # 'shiftKey': false,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    # Test data, add real data
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  it 'keydown press down', (done)->
    # Test data, add real data
    d3.event = {
      'keyCode': 40,
      'shiftKey': true,
      # 'shiftKey': false,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    # Test data, add real data
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  it 'keydown press Enter', (done)->
    # Test data, add real data
    d3.event = {
      'keyCode': 13,
      'shiftKey': true,
      # 'shiftKey': false,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    # Test data, add real data
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  it 'keydown press Escape', (done)->
    # Test data, add real data
    d3.event = {
      'keyCode': 27,
      'shiftKey': true,
      'x': 45,
      'y': 56,
      # 'shiftKey': false,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    # Test data, add real data
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  # it 'dragStart', (done)->
  #   tr = d3.select('tr').node()
  #   assert event.dragStart(tr, d)
  #   done()

  # it 'dragMove', (done)->
  #   d3.event = {
  #     'x': 45,
  #     'y': 56
  #   }
  #   tr = d3.select('tr').node()
  #   assert event.dragMove(tr, d, 14, 25)
  #   done()

  it 'resizeDrag', (done)->
    assert event.resizeDrag
    done()
