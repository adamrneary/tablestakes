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

findByID = (data, id, removeElement) ->
  result = null
  _.each data, (d, i) ->
    if d.id is id
      data.splice(i, 1) if removeElement
      result = d
    values = d.values or d._values
    obj = findByID(values, id, removeElement) if values?
    result = obj if obj?
  result

onDragHandler = (objectID, targetID) ->
  if targetID? and objectID?
    target = findByID(data, targetID, false)
    draggedObject = findByID(data, objectID, true)
    values = target.values or target._values? or (target.values = [])
    values.push(draggedObject)
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
