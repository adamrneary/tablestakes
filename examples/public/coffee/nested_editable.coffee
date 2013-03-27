data = [
  id: "NVD3"
  type: "ahaha"
  values: [
    id: "Charts"
    values: [
      id: "Simple Line with <a href='http://www.google.com'>Simple Link</a>"
      type: "Some text with <a href='http://www.yahoo.com'>Another Link</a>"
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
    id: "expand/collapse or <a href='http://www.yandex.com'>link to Link</a>"
    type: "dblClick for editing <a href='http://www.bing.com'>link</a>"
    values: [
      id: "Legend"
      type: "Universal"
    ]
  ]
,
  id: "New Root"
  type: "tatata  <a href='#timeseries'>TimeSeries</a>" # link
  classes: "rowcustom1"
  values: [
    id: "1"
    type: "123"
    classes: "rowcustom"
  ]
]

setNewTreeValue = (tree, id, field, newValue) ->
  for node in tree
    if node.id is id
      node[field] = newValue
    else if node.values?
      setNewTreeValue(node.values, id, field, newValue)

editHandler = (id, field, newValue) ->
  setNewTreeValue data, id, field, newValue
  grid.data(data).render()

columns = [
  id: "id"
  label: "Name"
  classes: 'row-heading'
  isEditable: true
  isNested: true
  onEdit: editHandler
,
  id: "type"
  label: "Type"
  isEditable: true
  onEdit: editHandler
]

grid = new window.TableStakes()
  .el('#example')
  .columns(columns)
  .data(data)
  .render()
