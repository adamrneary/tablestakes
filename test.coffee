# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
testColumns = undefined
testTree = undefined
testTree = [
  key: "NVD3"
  type: "ahaha"
  values: [
    key: "Charts"
    _values: [
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
    ]
  ,
    key: "Chart Components"
    values: [
      key: "Legend"
      type: "Universal"
    ]
  ]
,
  key: "New Root"
  type: "tatata"
  values: [
    key: "1"
    type: "123"
  ]
]
testColumns = [
  key: "key"
  label: "Name"
  showCount: false
  width: "400px"
  type: "text"
  isEditable : true
  classes: (d) ->
    if d.url
      "clickable name"
    else
      "name"
  click: (d) ->
    d3.select(this).html("hallo you were clicked")
,
  key: "type"
  label: "Type"
  width: "300px"
  type: "text"
  classes: "name"
  isEditable: true
]

drawGraph = ()->
  grid = new window.TablesStakes()
  grid.columns testColumns
  grid.data testTree
  grid.render '#example1'  

drawGraph()
