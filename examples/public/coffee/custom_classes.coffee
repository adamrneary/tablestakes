data = [
  key: "NVD3"
  type: "ahaha"
  etc: 'etc1'
,
  key: 
      label: "Simple Line"
      classes: "plan"
  type: "Historical"
  etc: 'etc2'
,
  key: "Scatter / Bubble"
  type: 
      label: "Snapshot"
      classes: "old"
  etc: 'etc3'
,
  key: "Stacked / Stream / Expanded Area"
  type: "Historical"
  etc: 'etc3'
,
  key: "Discrete Bar"
  type: "Snapshot"
  etc: 'etc4'
,
  key: "Grouped / Stacked Multi-Bar"
  type: "Snapshot / Historical"
  etc: 'etc5'
,
  key: "Horizontal Grouped Bar"
  type: "Snapshot"
  etc: 'etc6'
,
  key: "Line and Bar Combo"
  type: "Historical"
  etc: 'etc7'
,
  key: "Cumulative Line"
  type: "Historical"
  etc: 'etc8'
,
  key: "Line with View Finder"
  type: "Historical"
  etc: 'etc9'
,
  key: "Legend"
  type: "Universal"
  etc: 'etc10'
,
  key: "New Root"
  type: "tatata"
  etc: 'etc11'
,
  key: "1"
  type: "123"
  etc: 'etc12'
  _classes: "total"
]

columns = [
  key: "key"
  label: "Name"
  showCount: false
  isEditable: true
  classes: "row-heading"
,
  key: "type"
  label: "Type"
  isEditable: false
,
  key: "etc"
  label: "etc"
  classes: "plan"
  isEditable: false
]

grid = new window.TableStakes(
  columns: columns
  data: data
  el: "#example"
)
grid.render()
