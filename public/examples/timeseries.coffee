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

dataFromStriker = []
_.each ["row1","row2","row3","row4","row5","row6","row7"], (rowLabel, i) ->
  _.each _.range(72), (month, j) ->
    dataFromStriker.push
      firstColumn: rowLabel
      period_id: new Date(2010, 0+month).getTime()
      value: (i+1) + (j+1)

data = []
_.each _.keys(_.groupBy(dataFromStriker, (obj) -> obj.firstColumn)),
(rowLabel, i) ->
  data.push
    id: i
    firstColumn: rowLabel
    period: _.chain(dataFromStriker)
      .filter((obj) -> obj.firstColumn is rowLabel)
      .map((obj) -> obj.period_id).value()
    dataValue: _.chain(dataFromStriker)
      .filter((obj) -> obj.firstColumn is rowLabel)
      .map((obj) -> obj.value).value()

editHandler = (id, field, newValue) ->
  newValue = if _.isNaN(parseInt newValue) then newValue else parseInt newValue
  for row in data
    if row.id is id
      row.dataValue[_.indexOf row.period, field] = newValue
  grid.data(data).render()

columns = [
  id: "firstColumn"
  label: "Name"
  classes: "row-heading"
,
  id: 'period'
  dataValue: 'dataValue'
  timeSeries: availableTimeFrame
  isEditable: true
  onEdit: editHandler
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .headRows('secondary')
  .data(data)
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
  min: 0            # TODO: temporary solution
  max: 71           # TODO: temporary solution
  values: [36, 47]  # TODO: temporary solution
  range: true
  slide: (event, ui) ->
    availableTimeFrame = []
    _.each _.range(ui.values[0], ui.values[1]+1), (val) ->
      availableTimeFrame.push new Date(2010, 0+val).getTime()

    _.each columns, (col) ->
      if col.timeSeries?
        col.timeSeries = availableTimeFrame
        if availableTimeFrame.length > 12
          col.isEditable = false
          col.onEdit = null
        else
          col.isEditable = true
          col.onEdit = editHandler

    labelTimeFrame.text(
      "Available Time Frame:
      #{ new Date(_.first(availableTimeFrame)).toDateString().slice(4) }
       - #{ new Date(_.last(availableTimeFrame)).toDateString().slice(4) }"
    )
    grid.columns(columns)
      .headRows('secondary')
      .dataAggregate('sum')
      .render()
