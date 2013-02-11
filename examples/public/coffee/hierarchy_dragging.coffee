  testTree = [
    id: "NVD3"
    type: "ahaha"
  ,
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
  ,
    id: "Legend"
    type: "Universal"
  ,
    id: "New Root"
    type: "tatata"
  ,
    id: "1"
    type: "123"
  ]
  testColumns = [
    key: "id"
    label: "Name"
    showCount: false
    type: "text"
    isEditable: true
    classes: "keyfield"
    click: (d) ->
      d3.select(this).html "hallo you were clicked"
  ,
    key: "type"
    label: "Type"
    type: "text"
    classes: "name"
    isEditable: false
  ]
  grid = new window.TableStakes(
    columns: testColumns
    data: testTree
    el: "#example"
  )
  # grid.set "hierarchy_dragging", true
  .hierarchy_dragging true
  # .hierarchy_dragging (row)->
  #   if row is 'hierarchy_dragging-filter'
  #     row
  grid.render()

