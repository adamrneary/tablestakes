data = [
  key: "NVD3"
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
  class: "total"
]

columns = [
  key: "key"
  label: "Name"
  showCount: false
  width: "400px"
  # what does "type" do?
  type: "text"
  isEditable: true
  classes: "row-heading"
  # is click() functional? if not, let's pull it from examples for now
  click: (d) ->
    d3.select(this).html "hallo you were clicked"
,
  key: "type"
  label: "Type"
  width: "300px"
  # what does "type" do?
  type: "text"
  isEditable: false
]

grid = new window.TablesStakes(
  columns: columns
  data: data
  el: "#example"
)
grid.render()
