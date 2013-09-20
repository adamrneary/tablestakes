# Tablestakes Common API

![GitHub Logo](/docs/common/common_1.png)

### Creating instance of tablestakes

```coffeescript
new window.TableStakes()
```

### Options

* [el()](#placement) - element to render table
* [columns()](columns.md) - list of columns
* [data()](#data-manipulating) - data manipulating
  * [timeSeries](#timeseries) - specific data manipulating methods
* [rowClasses()](#row-classes) - adding specific class custom row



##### Placement

```coffeescript
new window.TableStakes()
  .el("#example")
  .render()
```
Will create new instance of table placed inside of ```#example```
```html
<div id="example">
  <div>
    <table class="tablestakes">
    </table>
  </div>
</div>
```
  
  
  
##### Data manipulating

Set data to table. 
```data``` - array, that describes table's data. Each element of ```data``` describes row.  
Every array's item (row) should be JavaScript object.  
Every array's item (row) could contain any quantity of pairs {key: value}, but used will be only those which have reference from colums array.  
*For example*: ```columns``` array defines to use values from row by keys **id** and **label**

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

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()
```

###### timeSeries

 Tablestakes lib contains some specific methods for columns and data gouped by time factor.  
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

 Long time ranges accupies a lot of page space. To reduce timeSeries column quantity and aggregate data method ```dataAggregate(aggregator)```  could be used.  
 If time range *12 items*, or less aggregation will be applied. If time range *more that 12 and less or equal 36* - quarterly. If time range *more than 36* - by year.
 It takes on of 4 possible arguments:
 
1. **'sum'** ```dataAggregate('sum')``` for summing
2. **'first'** ```dataAggregate('first')``` to take first value from aggregated columns
3. **'last'** ```dataAggregate('last')``` to take last value from aggregated columns
4. *user defined function* ```dataAggregate(aggregator)``` for any other needs
 
```coffeescript
timeRange = [1356984000000, 1359662400000, 1362081600000, 1364760000000, 1367352000000, 1370030400000, 1372622400000, 1375300800000, 1377979200000, 1380571200000, 1383249600000, 1385841600000, 1388520000000] # [Jan 2013 ... Jan 2014]

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


##### Row Classes

*Coming Soon*