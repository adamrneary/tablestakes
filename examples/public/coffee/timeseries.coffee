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
#  .headRows(columns)
  .data(data)
  .render()

toggle = true

yearDisplay = (column) ->
  # Table header row filter function. Returns label for column.
  unless !!column.timeSeries
    label = ""
  else
    period = if toggle then availableTimeFrame else displayPeriods
    first = _.chain(period)
      .filter((date) -> date.getFullYear().toString() is column.label)
      .first()
      .value()
    first = _.first(period) unless !!first

    first = labelFunctionYear(first)
    if column.id is first.id
      label = first.label
    else
      label = ""
  label

grid.headRowsFilter(yearDisplay).render()

$('<button>display/hide</button>').appendTo('#temp').on 'click', (e)->
  toggle = !toggle
  grid.displayColumns(displayPeriods, toggle).render()
  grid.headRowsFilter(yearDisplay).render()
