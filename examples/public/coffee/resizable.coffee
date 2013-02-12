data = [
  id: "NVD3"
  type: "ahaha"
  etc: 'etc1'
,
  id: "Simple Line"
  type: "Historical"
  etc: 'etc2'
,
  id: "Scatter / Bubble"
  type: "Snapshot"
  etc: 'etc3'
,
  id: "Stacked / Stream / Expanded Area"
  type: "Historical"
  etc: 'etc3'
,
  id: "Discrete Bar"
  type: "Snapshot"
  etc: 'etc4'
,
  id: "Grouped / Stacked Multi-Bar"
  type: "Snapshot / Historical"
  etc: 'etc5'
,
  id: "Horizontal Grouped Bar"
  type: "Snapshot"
  etc: 'etc6'
,
  id: "Line and Bar Combo"
  type: "Historical"
  etc: 'etc7'
,
  id: "Cumulative Line"
  type: "Historical"
  etc: 'etc8'
,
  id: "Line with View Finder"
  type: "Historical"
  etc: 'etc9'
,
  id: "Legend"
  type: "Universal"
  etc: 'etc10'
,
  id: "New Root"
  type: "tatata"
  etc: 'etc11'
,
  id: "1"
  type: "123"
  etc: 'etc12'
]

columns = [
  key: "id"
  label: "Name"
  classes: "row-heading"
,
  key: "type"
  label: "Type"
,
  key: "etc"
  label: "Etc"
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()