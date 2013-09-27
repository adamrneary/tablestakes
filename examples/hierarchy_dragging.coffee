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
  isNested: true,
  classes: 'row-heading'
,
  id: "type"
  label: "Type"
]

onDragHandler = (object, target) ->
  u = grid.core.utils
  if target? and object? and
  not u.isChild(target, object) and not u.isParent(target, object)
    u.removeNode(object)
    u.appendNode(target, object)
    grid.data(data).render()

dragDestination = (d) ->
  d.depth > 1

draggable = (d) ->
  d.depth > 1

grid = new window.TableStakes()
  .el('#example')
  .columns(columns)
  .data(data)
  .isDraggable(draggable)
  .dragMode('hierarchy')
  .isDragDestination(dragDestination)
  .onDrag(onDragHandler)
  .render()
