testTree = [
    key: "NVD3"
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
testColumns = [
    key: "key"
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

grid = new window.TablesStakes
    columns: testColumns
    data: testTree
    el: "#example"
.isDeletable true
grid.render()
