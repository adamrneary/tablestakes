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
  isEditable: true
  classes: "name"
]
grid = new window.TableStakes()
  .el('#example')
  .columns(columns)
  .data(data)
  .nested(true)
  .render()
