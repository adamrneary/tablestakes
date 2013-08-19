availableTimeFrame = [
  new Date(2013,  0, 2).getTime(),
  new Date(2013,  1, 2).getTime(),
  new Date(2013,  2, 2).getTime(),
  new Date(2013,  3, 2).getTime(),
  new Date(2013,  4, 2).getTime(),
  new Date(2013,  5, 2).getTime(),
  new Date(2013,  6, 2).getTime(),
  new Date(2013,  7, 2).getTime(),
  new Date(2013,  8, 2).getTime(),
  new Date(2013,  9, 2).getTime(),
  new Date(2013, 10, 2).getTime(),
  new Date(2013, 11, 2).getTime(),
]

dataFromStriker = []
_.each ["hash_key_1","hash_key_2","hash_key_3","hash_key_4","hash_key_5","hash_key_6","hash_key_7"], (rowLabel, i) ->
  _.each _.range(72), (month, j) ->
    dataFromStriker.push
#      firstColumn: rowLabel
      product_id: rowLabel  # TODO: temporary solution. hash value should be
      period_id: month      # TODO: temporary solution. hash value should be
      periodUnix: new Date(2010, 0+month, 2).getTime()
      actual: if i*12 <= j < (i+1)*12 then 0 else (i+1) + (j+1)

editHandler = (id, field, newValue) ->
  newValue = if _.isNaN(parseInt newValue) then newValue else parseInt newValue
  obj = _.filter(dataFromStriker, (obj) -> obj.periodUnix is field)[id]
  dataFromStriker[_.indexOf dataFromStriker, obj].actual = newValue
  grid.columns(columns)
    .headRows('secondary')
    .parseFlatData(dataFromStriker, 'product_id')
    .dataAggregate(aggregator)
    .render()

columns = [
  id: "id"
  label: "Name"
  classes: "row-heading"
  format: (d, column) -> "row" + d.id
,
  id: 'period'
  dataValue: 'actual'
  timeSeries: availableTimeFrame
  isEditable: true
  filterZero: true
  sorted: 'desc'
  onEdit: editHandler
  format: (d, column) -> '$'+d.dataValue
]

aggregator = 'sum'

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .headRows('secondary')
  .parseFlatData(dataFromStriker, 'product_id')
  .dataAggregate(aggregator)
  .render()

sliders = $('<div id="sliders" class="ui-horizontal-slider"></div>').appendTo('#temp')

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
      availableTimeFrame.push new Date(2010, 0+val, 2).getTime()

    _.each columns, (col) ->
      if col.timeSeries?
        col.timeSeries = availableTimeFrame

    labelTimeFrame.text(
      "Available Time Frame:
      #{ new Date(_.first(availableTimeFrame)).toDateString().slice(4) }
       - #{ new Date(_.last(availableTimeFrame)).toDateString().slice(4) }"
    )
    grid.columns(columns)
      .headRows('secondary')
      .parseFlatData(dataFromStriker, 'product_id')
      .dataAggregate(aggregator)
      .render()

sumButton = $("<button class='btn btn-mini'>Sum aggregated data</button>")
firstButton = $("<button class='btn btn-mini'>'First' of aggregated data</button>")
lastButton = $("<button class='btn btn-mini'>'Last' of aggregated data</button>")
buttonGroup = $("<div class='btn-group'></div>")
buttonGroup.append sumButton
buttonGroup.append firstButton
buttonGroup.append lastButton

$("#temp").append buttonGroup

sumButton.click (e) ->
  aggregator = 'sum'
  grid.columns(columns)
    .headRows('secondary')
    .parseFlatData(dataFromStriker, 'product_id')
    .dataAggregate(aggregator)
    .render()
  e.stopPropagation()

firstButton.click (e) ->
  aggregator = 'first'
  grid.columns(columns)
    .headRows('secondary')
    .parseFlatData(dataFromStriker, 'product_id')
    .dataAggregate(aggregator)
    .render()
  e.stopPropagation()

lastButton.click (e) ->
  aggregator = 'last'
  grid.columns(columns)
    .headRows('secondary')
    .parseFlatData(dataFromStriker, 'product_id')
    .dataAggregate(aggregator)
    .render()
  e.stopPropagation()
