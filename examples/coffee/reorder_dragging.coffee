drawGraph = undefined
testColumns = undefined
testTree = undefined
testTree = [
  key: "NVD3"
  type: "ahaha"
  values: [
    key: "Charts"
    _values: [
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
    ]
  ,
    key: "Chart Components"
    type: "Universal"
  ]
,
  key: "New Root"
  type: "tatata"
]
testColumns = [
  key: "key"
  label: "Name"
  showCount: false
  width: "400px"
  type: "text"
  isEditable: true
  classes: "keyfield"
  click: (d) ->
    d3.select(this).html "hallo you were clicked"
,
  key: "type"
  label: "Type"
  width: "300px"
  type: "text"
  classes: "name"
]
grid = new window.TablesStakes(
  columns: testColumns
  data: testTree
  el: "#example"
  reorder_dragging: true
  nested: true
)
grid.set "reorder_dragging", true
grid.render()
