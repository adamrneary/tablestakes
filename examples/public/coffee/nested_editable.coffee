data = [
  id: "NVD3"
  type: "ahaha"
  values: [
    id: "Charts"  # editable
    # TODO: expand only on arrow
    # TODO: edit on text click
    # TODO: edit on cell click
    _values: [
      id: "Simple Line" # editable
      # TODO: edit on text click
      # TODO: edit on cell click
      type: "Historical"
    ,
      id: "Scatter / Bubble <a href='#timeseries'>TimeSeries</a>" # link
      # TODO: prevent any editing
      type: "Snapshot"
      # TODO: edit on text click
      # TODO: edit on cell click
    ,
      id: "Stacked / Stream / Expanded Area"
      # TODO: edit on text click
      # TODO: edit on cell click
      type: "Historical  <a href='#timeseries'>TimeSeries</a>" # link
      # TODO: prevent any editing
    ,
      id: "Discrete Bar <a href='#timeseries'>TimeSeries</a>" # link
      # TODO: prevent any editing
      type: "Snapshot <a href='#timeseries'>TimeSeries</a>" # link
      # TODO: prevent any editing
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
    id: "Chart Components <a href='#timeseries'>TimeSeries</a>"  # link
    # TODO: expand only on arrow
    # TODO: prevent any editing
    # TODO: link action on click
    values: [
      id: "Legend"
      type: "Universal"
    ]
  ]
,
  id: "New Root"
  type: "tatata  <a href='#timeseries'>TimeSeries</a>" # link
  # TODO: prevent any editing
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
