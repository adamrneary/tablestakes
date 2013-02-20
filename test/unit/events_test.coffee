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
    event = new window.TableStakesLib.Events
      core: {
        table: {
          isInRender: false,
          el: ->
            return '#example'
          onDrag: ->
            return d
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
    td = d3.select('td').node()
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
    td = d3.select('td').node()
    assert event.keydown(td, d, column)
    done()

  it 'keydown press tab, shiftKey-false and ColumnIndex = 1', (done)->
    testevent = new window.TableStakesLib.Events
      core: {
        table: {
          isInRender: false,
          el: ->
            return '#example'
          onDrag: ->
            return d
        }
        update: ->
          return true
        utils: {
          getCurrentColumnIndex: ->
            return 1
          findNextNode: ->
            return d
          findPrevNode: ->
            return d
        }
        columns: [{'id': 2}, {'id': 3}, {'id': 4}],
        nodes: []
      }
    d3.event = {
      'keyCode': 9,
      'shiftKey': false,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    td = d3.select('td').node()
    assert testevent.keydown(td, d, column)
    done()

  it 'keydown press tab, shiftKey-true and ColumnIndex = 3', (done)->
    testevent = new window.TableStakesLib.Events
      core: {
        table: {
          isInRender: false,
          el: ->
            return '#example'
          onDrag: ->
            return d
        }
        update: ->
          return true
        utils: {
          getCurrentColumnIndex: ->
            return 1
          findNextNode: ->
            return d
          findPrevNode: ->
            return d
        }
        columns: [{'id': 2}, {'id': 3}, {'id': 4}],
        nodes: []
      }
    d3.event = {
      'keyCode': 9,
      'shiftKey': true,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    td = d3.select('td').node()
    assert testevent.keydown(td, d, column)
    done()

  it 'keydown press tab, shiftKey-true and  ColumnIndex = 0', (done)->
    testevent = new window.TableStakesLib.Events
      core: {
        table: {
          isInRender: false,
          el: ->
            return '#example'
          onDrag: ->
            return d
        }
        update: ->
          return true
        utils: {
          getCurrentColumnIndex: ->
            return 0
          findNextNode: ->
            return d
          findPrevNode: ->
            return d
        }
        columns: [{'id': 2}, {'id': 3}, {'id': 4}],
        nodes: []
      }
    d3.event = {
      'keyCode': 9,
      'shiftKey': true,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    td = d3.select('td').node()
    assert testevent.keydown(td, d, column)
    done()

  it 'keydown press up', (done)->
    testevent = new window.TableStakesLib.Events
      core: {
        table: {
          isInRender: false,
          el: ->
            return '#example'
          onDrag: ->
            return d
        }
        update: ->
          return true
        utils: {
          getCurrentColumnIndex: ->
            return 2
          findNextNode: ->
            return d
          findPrevNode: ->
            return d
        }
        columns: {0: {'id': 2}, 1: {'id': 3}, 2: {'id': 4}},
        nodes: []
      }
    d3.event = {
      'keyCode': 38,
      'shiftKey': true,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    td = d3.select('td').node()
    assert testevent.keydown(td, d, column)
    done()

  it 'keydown press down', (done)->
    testevent = new window.TableStakesLib.Events
      core: {
        table: {
          isInRender: false,
          el: ->
            return '#example'
          onDrag: ->
            return d
        }
        update: ->
          return true
        utils: {
          getCurrentColumnIndex: ->
            return 1
          findNextNode: ->
            return d
          findPrevNode: ->
            return d
        }
        columns: {0: {'id': 2}, 1: {'id': 3}, 2: {'id': 4}},
        nodes: []
      }
    d3.event = {
      'keyCode': 40,
      'shiftKey': true,
      preventDefault: ->
        return true
      stopPropagation: ->
        return true
    }
    td = d3.select('td').node()
    assert testevent.keydown(td, d, column)
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
    td = d3.select('td').node()
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

  # it 'dragEnd', (done)->
  #   tr = d3.select('tr').node()
  #   assert event.dragEnd(tr, d)
  #   done()

  it 'resizeDrag', (done)->
    context = {
      columns: [
        0: {
          classes: "row-heading"
          id: "id"
          label: "Name"
        }
        1: {
          id: "type"
          label: "Type"
        }
      ]
      data: [
        0: {
          _hiddenvalues: []
          _id: "0"
          children: [13]
          depth: 0
          etc: "etc"
          id: "id"
          type: "type"
          values: [13]
          x: 0.5
          y: 0
        }
      ]
      enterRows: []
      events: event
      nodes: []
      rows: []
      selection: []
      table: table
      tableEnter: []
      tableObject: []
      tbody: []
      updateRows: []
    }

    td = d3.select('td').node()

    assert event.resizeDrag(context, td, d, 2, 0)
    done()

  it 'editableClick', (done)->
    td = d3.select('td').node()
    event.editableClick(td, d, 2, 0)
    done()

  it 'nestedClick', (done)->
    td = d3.select('td').node()
    d.values = [td, td]
    td.values = [5,7]
    event.nestedClick(td, d, 2, 0)
    done()

  it 'toggleBoolean', (done)->
    td = d3.select('td').node()
    event.toggleBoolean(td, d, 2, 0, column)
    done()

  it 'selectClick', (done)->
    d3.event = {
      target: {
        value: 1
      }
    }
    td = d3.select('td').node()
    event.selectClick(td, d, 2, 0, column)
    done()
