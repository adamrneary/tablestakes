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
]
columns = [
  key: "key"
  label: "Name"
  classes: "row-heading"
,
  key: "type"
  label: "Type"
]

grid = new window.TableStakes
  onDelete: (rowKey) ->
      testTree = _.reject(testTree, (row) -> row.key is rowKey)
      grid.set 'data', testTree
      grid.render()
.isDeletable (d) ->
  d.type is 'Historical' or d.type is 'Snapshot'
.el("#example")
.columns(columns)
.data(data)
.render()
