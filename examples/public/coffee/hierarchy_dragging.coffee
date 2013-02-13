data = [
  id: "NVD3"
  type: "ahaha"
  values: [
    id: "Charts"
    _values: [
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
    ]
  ,
    id: "Chart Components"
    type: "Universal"
  ]
,
  id: "New Root"
  type: "tatata"
]

columns = [
  id: "id"
  label: "Name"
  isNested: true
,
  id: "type"
  label: "Type"
]

onDragHandler = (objectId, targetId) ->
  console.log objectId, targetId
  # TODO: find and record objectId's node (with children)
  # TODO: remove objectId's node from objectId's parent node
  # TODO: find targetId's node and add objectId's node (with children)
  grid.data(data).render()

grid = new window.TableStakes()
  .el('#example')
  .columns(columns)
  .data(data)
  .isDraggable(true)
  .dragMode('hierarchy')
  .isDragDestination(true)
  .onDrag(onDragHandler)
  .render()
