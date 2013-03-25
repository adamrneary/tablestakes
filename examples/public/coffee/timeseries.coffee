availableTimeFrame = [
  new Date(2012,  9, 1).getTime(),
  new Date(2012, 10, 1).getTime(),
  new Date(2012, 11, 1).getTime(),
  new Date(2013,  0, 1).getTime(),
  new Date(2013,  1, 1).getTime()
]

displayPeriods = [
  new Date(2012, 10, 1).getTime(),
  new Date(2012, 11, 1).getTime(),
  new Date(2013,  0, 1).getTime()
]

columns = [
  id: "firstColumn"
  label: "Name"
  classes: "row-heading"
,
  id: 'period'
  dataValue: 'dataValue'
  timeSeries: availableTimeFrame
]

data = []
_.each ["row1","row2","row3","row4","row5","row6","row7","row8"], (rowLabel) ->
  data.push
    firstColumn: rowLabel
    period: _.map(availableTimeFrame, (period) -> period)
    dataValue: _.map(availableTimeFrame, () -> Math.floor((Math.random()*100)+1))

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .headRows('secondary')
  .data(data)
  .render()

toggle = true

$('<button>display/hide</button>').appendTo('#temp').on 'click', (e)->
  toggle = !toggle
  grid.displayColumns(displayPeriods, toggle)
    .headRows('secondary')
    .render()
