  testTree = [
    key:
      label: [
          ['Example1',['Example1.1', 'Example1.2', 'Example1.3']],
          'Example2',
          'Example3'
      ]
      classes: 'select'
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
    type:
      label: [
          ['Example2.1',['Example2.1.1', 'Example2.1.2', 'Example2.1.3']],
          'Example2.2',
          'Example2.3'
      ]
      classes: 'select'
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
    key: "tatata"
    type:
        label: "02/12/2012"
        classes: 'calendar'
  ,
    key:
        label: "yes"
        classes: "calendar"
    type: "123"
  ]
  testColumns = [
    key: "key"
    label: "Name"
    showCount: false
    type: "text"
    isEditable: (row) ->
      row.key is 'Horizontal Grouped Bar'
    classes: "keyfield"
    click: (d) ->
      d3.select(this).html "hallo you were clicked"
  ,
    key: "type"
    label: "Type"
    type: "text"
    classes: "name"
    isEditable: true
    onEdit: (rowKey, field, newValue) ->
      _.find testTree, (row) ->
        row[field] = newValue if row.key is rowKey
      grid.render()
  ]
  grid = undefined
  grid = new window.TablesStakes(
    columns: testColumns
    data: testTree
    el: "#example"
  )
  grid.render()
