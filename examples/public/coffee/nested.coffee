data = [
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
    values: [
      key: "Legend"
      type: "Universal"
    ]
  ]
,
  key: "New Root"
  type: "tatata"
  classes: "rowcustom1"
  values: [
    key: "1"
    type: "123"
    classes: "rowcustom"
  ]
]
columns = [
  key: "key"
  label: "Name"
  classes: "row-heading"
,
  key: "type"
  label: "Type"
]
grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .nested(true)
  .render()