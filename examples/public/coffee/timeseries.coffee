data = [
  id: "nerds for good"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "Simple Line"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "Scatter / Bubble"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "Stacked / Stream / Expanded Area"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "Discrete Bar"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "Grouped / Stacked Multi-Bar"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "Horizontal Grouped Bar"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "Line and Bar Combo"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "Cumulative Line"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "Line with View Finder"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "Legend"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "New Root"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
,
  id: "1"
  nov: "nov1"
  dec: "dec1"
  jan: "jan1"
]

availableTimeframe = [
  new Date(2012,  9, 1),
  new Date(2012, 10, 1),
  new Date(2012, 11, 1),
  new Date(2013,  0, 1),
  new Date(2013,  1, 1)
]
#availableTimeframe = ['feb', 'mar', 'apr'] #reformat to dates array
labelFunction = (label)->
  id: label.toDateString().split(' ')[1].toLowerCase()
  label: label.toDateString().split(' ')[1].toUpperCase()

labelFunctionYear = (label)->
  id: label.toDateString().split(' ')[1].toLowerCase()
  label: label.getFullYear().toString()

columns = [
  col: [
    id: "id"
    label: "Name"
    classes: ""
  ,
    timeSeries: availableTimeframe
    label: labelFunctionYear
  ],
  headClasses: 'secondary'
,
  col: [
    id: "id"
    label: "Name"
    classes: "row-heading"
  ,
    timeSeries: availableTimeframe
    label: labelFunction
  ],
  headClasses: 'row-heading'
]
#columns = [
#  id: "id"
#  label: "Name"
#  classes: "row-heading"
#,
#  timeSeries: availableTimeframe
#  label: labelFunction
#  classes: "well"
#]

grid = new window.TableStakes()
  .el("#example")
#  .columns(columns)
  .headRows(columns)
  .data(data)
  .render()

displayPeriods = [
  new Date(2012, 10, 1),
  new Date(2012, 11, 1),
  new Date(2013,  0, 1)]
#displayPeriods = ['mar']
#displayPeriods = 'mar'

toggle = true

yearDisplay = (column) ->
  # Table header row filter function. Returns label for column.
  unless !!column.timeSeries
    label = ""
  else
    period = if toggle then availableTimeframe else displayPeriods
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
  grid.displayColumns(_.map(displayPeriods, (value, key, list) ->
    value.toDateString().split(' ')[1].toLowerCase()
  ),toggle).render()
  grid.headRowsFilter(yearDisplay).render()
