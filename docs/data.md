### Data manipulating

#### data()

Set data to table.
```data``` - array, that describes table's data. Each element of ```data``` describes a row.
Every array's item (row) should be JavaScript object.
Every array's item (row) could contain any quantity of pairs {key: value}, but only these will be used which have reference from colums array.
*For example*: ```columns``` array defines to use values from a row by keys **id** and **label**

```coffeescript
data = [
  id: "nerds for good"  # will be used
  label: "LOL"          # will not be used
  type: "ahaha"         # will be used
,
  id: "Simple Line"
  type: "Historical"
  reference: null       # will not be used
]

columns = [
  id: "id"
  label: "Name"
,
  id: "type"
  label: "Type"
]

new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()
```

#### Nested data, expandable/collapsible rows

To create table with expandale/collapsible rows. One of the [columns](columns.md) should contain the pair ```{isNested: true}```. [dataArray](data-manipulating.md) should cointain a specific pair ```{key: value}``` **key** can have one of two values: *values* or *_values*. **value** should be array of objects, related to *columns*
*values* - for expanded of nested rows; *_values* - for collapsed of nested rows.

```coffeescript
data = [
  id: "NVD3"
  type: "ahaha"
  values: [
    id: "Charts"
    _values: [
      id: "Simple Line"
      type: "Historical"
    ,
      id: "Scatter / Bubble"
      type: "Snapshot"
    ,
      id: "Stacked / Stream / Expanded Area"
      type: "Historical"
    ]
  ,
    id: "Chart Components"
    values: [
      id: "Legend"
      type: "Universal"
    ,
      id: "Line with View Finder"
      type: "Historical"
    ]
  ]
,
  id: "New Root"
  type: "tatata"
  values: [
    id: "1"
    type: "123"
  ]
]

columns = [
  id: "id"
  label: "Name"
  isNested: true
,
  id: "type"
  label: "Type"
]

new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()
```

### timeSeries option

* [parseFlatData()](#parseflatdata) - consuming flat array of objects
* [dataAggragate()](#dataaggregate)
  * [external function syntax](#external-function-syntax)

Tablestakes lib contains some specific methods for [columns](columns.md) and data gouped by time factor.
First of all ```columns``` should be defined by adding key **timeSeries** with value equal to array of [UnixTimeStamps](http://www.unixtimestamp.com/index.php) which will be displayed.
```coffeescript
columns = [
  id: "id"
  label: "Name"
,
  id: 'timeSeries'
  dataValue: 'actual'
  timeSeries: [1356984000000, 1359662400000, 1362081600000, 1364760000000, 1367352000000, 1370030400000, 1372622400000, 1375300800000, 1377979200000, 1380571200000, 1383249600000, 1385841600000] # [Jan 2013 ... Dec 2013]
]
```
Then ```data``` array should contain **period** and **dataValue** keys. Which are arrays of values for whole observing period. **period** array of UnixTimeStamps, **dataValue** array of values.
Table with 13 columns: *Name, Jan, Feb, ..., Dec* and 2 rows
```coffeescript
timeRange = [new Date(2012, i, 2).getTime() for i in [0..35]][0] # [Jan 2012 ... Dec 2014]

rowData = [
  id: "First row"
  period: timeRange
  dataValue: [0..35]
,
  id: "Second row"
  period: timeRange
  dataValue: [36..71]
]

new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(rowData)
  .render()
```


#### parseFlatData()


Also we have method for consuming data from flat array of object and translate it into array of *tablestakes* timeSeries rows. Method takes 2 arguments **flatDataArray** and **rowKeyResolver**
**flatDataArray** should contain:

1. pair ```{key: value}```, where **key** is **rowKeyResolver**
2. pair ```{periodUnix: unixTimeStamp}```
3. pair ```{actual: value}```. **actual** key stores displaing value (it will be passed into **dataValue**)

```coffeescript
flatDataArray = []
_.each ["hash_key_1","hash_key_2","hash_key_3","hash_key_4","hash_key_5","hash_key_6","hash_key_7"], (rowLabel, i) ->
  _.each _.range(72), (month, j) ->
    flatDataArray.push
      product_id: rowLabel  # TODO: temporary solution. hash value should be
      periodUnix: new Date(2010, 0+month, 1).getTime()
      actual: (i+1) + (j+1)

rowKeyResolver = "product_id"

new window.TableStakes()
  .el("#example")
  .columns(columns)
  .parseFlatData(flatDataArray, rowKeyResolver)
  .render()
```


#### dataAggregate()

 Long time ranges occupy a lot of page space. To reduce timeSeries column quantity and aggregate data method ```dataAggregate(aggregator)```  could be used.
 If time range *12 items*, or less aggregation will be applied. If time range *more that 12 and less or equal 36* - quarterly. If time range *more than 36* - by year.
 It takes on of 4 possible arguments:

1. **'sum'** ```dataAggregate('sum')``` for summing
2. **'first'** ```dataAggregate('first')``` to take first value from aggregated columns
3. **'last'** ```dataAggregate('last')``` to take last value from aggregated columns
4. [*user defined function*](#external-function-syntax) ```dataAggregate(aggregator)``` for any other needs

```coffeescript
timeRange = [1357070400000, 1359748800000, 1362168000000, 1364846400000, 1367438400000, 1370116800000, 1372708800000, 1375387200000, 1378065600000, 1380657600000, 1383336000000, 1385928000000, 1388606400000] # [Jan 2013 ... Jan 2014]

columns = [
  id: "id"
  label: "Name"
,
  id: 'timeSeries'
  dataValue: 'actual'
  timeSeries: timeRange
]

rowData = [
  id: "First row"
  period: timeRange
  dataValue: [0..35]
,
  id: "Second row"
  period: timeRange
  dataValue: [36..71]
]

new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(rowData)
  .dataAggregate('sum')
  .render()
```


##### External function syntax

All aggregation logic are the same (grouping by month / quarter / year; value selecting; etc), except of applying aggregation function. External function shuld take 2 arguments: ```dataArray```, ```selectedTimeRange```
* ```dataArray``` is the same you pass into **data()** function or result of **parseFlatData()** function.
* ```selectedTimeRange``` range of unixTimeStamps


Function should return array, organized the same way as original.

```coffeescript
externalDataAggregateFunction = (dataArray, selectedTimeRange) ->
  # function return data multiplied by 2 if selectedTimeRange > 12
  _data = []

  # this is how columns.id selector creates
  if selectedTimeRange.length <= 12
    return dataArray
  else if 12 < selectedTimeRange.length <= 36
    grouper = 3
  else
    grouper = 12

  multiplier = 2

  _.each dataArray, (row, i) ->
    _period = []
    _dataValue = []

    start = _.indexOf row.period, _.first selectedTimeRange
    end = _.indexOf row.period, _.last selectedTimeRange

    unless start is -1 or end is -1
      _slicePeriod = if row.period.length then row.period.slice(start, end+1) else []
      _sliceValue = if row.dataValue.length then row.dataValue.slice(start, end+1) else []

      for val, j in _slicePeriod by grouper
        # this is how columns.id selector creates
        _period.push [val,_.last(_slicePeriod.slice(j,j+grouper))].join '-'
        _dataValue.push _.reduce _sliceValue.slice(j,j+grouper), ((memo, value)-> memo + value*multiplier), 0
    else
      for val, j in selectedTimeRange by grouper
        _period.push [val,_.last selectedTimeRange[j..j+grouper]].join '-'
        _dataValue.push '-'

    _row = _.clone(row)
    _row.period = _period
    _row.dataValue = _dataValue

    _data.push _row

  _data

new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(rowData)
  .dataAggregate(externalDataAggregateFunction)
  .render()
```
