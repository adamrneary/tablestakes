data = [
  key: "NVD3"
  type: "-"
,
  key: "Simple Line"
  type: "+"
,
  key: "Scatter / Bubble"
  type: "Y"
,
  key: "Stacked / Stream / Expanded Area"
  type: "y"
,
  key: "Discrete Bar"
  type: "yes"
,
  key: "Grouped / Stacked Multi-Bar"
  type: "no"
,
  key: "Horizontal Grouped Bar"
  type: "-"
,
  key: "Line and Bar Combo"
  type: "n"
,
  key: "Cumulative Line"
  type: "N"
,
  key: "Line with View Finder"
  type: "Bad"
,
  key: "Legend"
  type: "false"
,
  key: "New Root"
  type: "true"
,
  key: "1"
  type: 
      label: "true"
      classes: "boolean"
]

columns = [
  key: "key"
  label: "Name"
  showCount: false
  isEditable: true
  classes: "row-heading"
,
  key: "type"
  label: "Type"
  isEditable: false
  classes: "boolean"
]

grid = new window.TablesStakes(
  columns: columns
  data: data
  el: "#example"
)
grid.render()
