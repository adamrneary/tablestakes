
data = [
    id: "NVD3"
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
  ,
    id: "type"
    label: "Type"
  ]

onDragHandler = (objectId, index) ->
  obj = _.find(data, (d) -> d.id is objectId)
  data = _.without(data, obj)
  data.splice(index, 0, obj)
  grid.data(data).render()

grid = new window.TableStakes()
  .el('#example')
  .columns(columns)
  .data(data)
  .isDraggable(true)
  .dragMode('reorder')
  .onDrag(onDragHandler)
  .render()