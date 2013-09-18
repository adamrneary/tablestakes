availableTimeFrame = [new Date(2013, i, 2).getTime() for i in [0..11]][0]

dataFromStriker = []
_.each ["hash_key_1","hash_key_2","hash_key_3","hash_key_4","hash_key_5","hash_key_6","hash_key_7"], (rowLabel, i) ->
  _.each _.range(72), (month, j) ->
    dataFromStriker.push
      product_id: rowLabel  # TODO: temporary solution. hash value should be
      period_id: month      # TODO: temporary solution. hash value should be
      periodUnix: new Date(2010, 0+month, 2).getTime()
      actual: if i*12 <= j < (i+1)*12 then 0 else (i+1) + (j+1)

columns = [
  id: "product_id"
  label: "Name"
  classes: "row-heading"
,
  id: "period"
  timeSeries: availableTimeFrame
  format: (d, column) -> '$'+d.dataValue
,
  # Total column - sum of column values per row
  id: "total"   # totalColumn.id shouldn't be one of data's fields
                # for this exmaple it couldn't be 'actual'
  type: "total" # key argument for "total" column

  label: "Total"
  related: "period" # pointer to coulum(s).id we want to sum
  format: (d, column) ->
    numeral(d[column.id] || 0).format('$0.[00]a')
  classes: "total"
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .headRows("secondary")
  .parseFlatData(dataFromStriker, "product_id")
  .dataAggregate("sum")
  .render(200)

sliders = $('<div id="sliders" class="ui-horizontal-slider"></div>').appendTo("#temp")

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
      .dataAggregate('sum')
      .render()