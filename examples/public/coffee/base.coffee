data = [
  key: 
      label: ['Example1', 'Example2', 'Example3']
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
