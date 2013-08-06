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
  editable: true
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
  type: "1"
]

editHandler = (id, field, newValue) ->
  (row[field] = newValue if row.id is id) for row in data
  grid.data(data).render()

columns = [
  id: "id"
  label: "Name"
  classes: "row-heading"
  isEditable: (d) ->
    d.editable
  onEdit: editHandler
  format: (d) ->
    if d.id is '1' then "#{d.id} period" else d.id
,
  id: "type"
  label: "Type"
  isEditable: true
  onEdit: editHandler
  format: (d)->
    if d.type is '1' then "#{d.type} period" else d.type
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()
