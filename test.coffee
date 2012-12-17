testColumns = undefined
testTree = undefined
testTree = [
  key: "NVD3"
  url: "http://novus.github.com/nvd3"
  values: [
    key: "Charts"
    _values: [
      key: "Simple Line"
      type: "Historical"
      url: "http://novus.github.com/nvd3/ghpages/line.html"
    ,
      key: "Scatter / Bubble"
      type: "Snapshot"
      url: "http://novus.github.com/nvd3/ghpages/scatter.html"
    ,
      key: "Stacked / Stream / Expanded Area"
      type: "Historical"
      url: "http://novus.github.com/nvd3/ghpages/stackedArea.html"
    ,
      key: "Discrete Bar"
      type: "Snapshot"
      url: "http://novus.github.com/nvd3/ghpages/discreteBar.html"
    ,
      key: "Grouped / Stacked Multi-Bar"
      type: "Snapshot / Historical"
      url: "http://novus.github.com/nvd3/ghpages/multiBar.html"
    ,
      key: "Horizontal Grouped Bar"
      type: "Snapshot"
      url: "http://novus.github.com/nvd3/ghpages/multiBarHorizontal.html"
    ,
      key: "Line and Bar Combo"
      type: "Historical"
      url: "http://novus.github.com/nvd3/ghpages/linePlusBar.html"
    ,
      key: "Cumulative Line"
      type: "Historical"
      url: "http://novus.github.com/nvd3/ghpages/cumulativeLine.html"
    ,
      key: "Line with View Finder"
      type: "Historical"
      url: "http://novus.github.com/nvd3/ghpages/lineWithFocus.html"
    ]
  ,
    key: "Chart Components"
    values: [
      key: "Legend"
      type: "Universal"
      url: "http://novus.github.com/nvd3/examples/legend.html"
    ]
  ]
]
testColumns = [
  key: "key"
  label: "Name"
  showCount: true
  width: "200px"
  type: "text"
  classes: (d) ->
    if d.url
      "clickable name"
    else
      "name"
  click: (d) ->
    #d3.select(this).append("input").attr("type","text").attr("value","inserted")
    d3.select(this).html("hallo you were clicked")
    #window.location.href = d.url ? d.url
,
  key: "type"
  label: "Type"
  width: "300px"
  type: "text"
]
grid = new window.TablesStakes()
grid.columns testColumns
grid.data testTree
grid.render '#example1'
