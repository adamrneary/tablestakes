  testTree = [
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
  testColumns = [
    key: "id"
    label: "Name"
    showCount: false
    type: "text"
    isEditable: true
    classes: "keyfield"
    click: (d) ->
      d3.select(this).html "hallo you were clicked"
  ,
    key: "type"
    label: "Type"
    type: "text"
    classes: "name"
  ]

  grid = new window.TableStakes
    columns: testColumns
    data: testTree
    el: "#example"
    # filterable: true
    # nested: true
  .filterable true
  # .nested true
  # .filterable (row)->
  #   if row is 'filterable-filter'
  #     row
  # .nested (row)->
  #   if row is 'nested-filter'
  #     row

  grid.render()

  keyup = -> grid.filter $(this).attr('column'), $(this).val()
  $('<input id="filter1" column="key" type="text" value="" />').appendTo('#temp').on 'keyup', keyup
  $('<input id="filter2" column="type" type="text" value="" />').appendTo('#temp').on 'keyup', keyup
