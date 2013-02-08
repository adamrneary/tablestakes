data = [
  key: "nerds for good"
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

editHandler = (rowKey, field, newValue) ->
  (row[field] = newValue if row.key is rowKey) for row in data
  grid.data(data).render()

columns = [
  key: "key"
  label: "Name"
  classes: "row-heading"
  isEditable: (d) ->
    d.key is 'Horizontal Grouped Bar'    
  onEdit: editHandler
,
  key: "type"
  label: "Type"
  isEditable: true
  onEdit: editHandler
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()