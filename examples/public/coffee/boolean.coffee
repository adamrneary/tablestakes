data = [
  id: "NVD3"
  type: "-"
,
  id: "Simple Line"
  type: "+"
,
  id: "Scatter / Bubble"
  type: "Y"
,
  id: "Stacked / Stream / Expanded Area"
  type: "y"
,
  id: "Discrete Bar"
  type: "yes"
,
  id: 'ok'
  type: "no"
,
  id: "Horizontal Grouped Bar"
  type: "-"
,
  id: "Line and Bar Combo"
  type: "n"
,
  id: "Cumulative Line"
  type: "N"
,
  id: "Line with View Finder"
  type: "Bad"
,
  id: "Legend"
  type: "false"
,
  id: "New Root"
  type: "true"
,
  id: "true"
  type: "true"
]

columns = [
  key: "id"
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

grid = new window.TableStakes(
  columns: columns
  data: data
  el: "#example"
)
.boolean true
# .boolean (row)->
#     if row is 'boolean-filter'
#       row
grid.render()
