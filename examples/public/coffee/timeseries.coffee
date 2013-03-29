availableTimeFrame = [
  new Date(2013,  0, 1).getTime(),
  new Date(2013,  1, 1).getTime(),
  new Date(2013,  2, 1).getTime(),
  new Date(2013,  3, 1).getTime(),
  new Date(2013,  4, 1).getTime(),
  new Date(2013,  5, 1).getTime(),
  new Date(2013,  6, 1).getTime(),
  new Date(2013,  7, 1).getTime(),
  new Date(2013,  8, 1).getTime(),
  new Date(2013,  9, 1).getTime(),
  new Date(2013, 10, 1).getTime(),
  new Date(2013, 11, 1).getTime()
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

sliders = $('<div id="sliders"></div>').appendTo('#temp')

labelTimeFrame =  $('<label>')
  .attr('for', 'sliderTimeFrame')
  .text("Available Time Frame:
  #{ new Date(_.first(availableTimeFrame)).toDateString().slice(4) }
   - #{ new Date(_.last(availableTimeFrame)).toDateString().slice(4) }")
  .appendTo '#sliders'
sliderTimeFrame = $("<div>").attr("id", "sliderTimeFrame").appendTo '#sliders'
sliderTimeFrame.slider
  min: 0  # TODO: temporary solution
  max: 71 # TODO: temporary solution
  values: [36, 47] # TODO: temporary solution
  range: true
  slide: (event, ui) ->
    availableTimeFrame = []
    val = ui.values[0]
    while val <= ui.values[1]
      availableTimeFrame.push new Date(2010, 0+val).getTime()
      val++
    columns[1].timeSeries = availableTimeFrame # TODO: temporary solution
    labelTimeFrame.text(
      "Available Time Frame:
      #{ new Date(_.first(availableTimeFrame)).toDateString().slice(4) }
       - #{ new Date(_.last(availableTimeFrame)).toDateString().slice(4) }"
    )
    grid.columns(columns)
      .headRows('secondary')
      .render()

labelPeriod =  $('<label>')
  .attr('for', 'sliderPeriod')
  .text("Display Period:
  #{ new Date(_.first(displayPeriods)).toDateString().slice(4) }
   - #{ new Date(_.last(displayPeriods)).toDateString().slice(4) }")
  .appendTo '#sliders'
sliderPeriod = $("<div>").attr("id", "sliderPeriod").appendTo '#sliders'
sliderPeriod.slider
  min: 0  # TODO: temporary solution
  max: 71 # TODO: temporary solution
  values: [37, 46]  # TODO: temporary solution
  range: true
  slide: (event, ui) ->
    displayPeriods = []
    val = ui.values[0]
    while val <= ui.values[1]
      displayPeriods.push new Date(2010, 0+val).getTime()
      val++
    labelPeriod.text(
      "Display Period:
            #{ new Date(_.first(displayPeriods)).toDateString().slice(4) }
             - #{ new Date(_.last(displayPeriods)).toDateString().slice(4) }"
    )