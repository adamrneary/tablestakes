data = [
  id: "nerds for good"
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

columns = [
  id: "id"
  label: "Name"
  classes: "row-heading"
,
  id: "type"
  label: "Type"
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()
