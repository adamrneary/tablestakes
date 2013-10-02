### Columns

Function and array of objects to define relation between [dataArray](data.md) and corresponding table columns.
```coffeescript
grid = new window.TableStakes()
  .el("#example")
  .columns(columnsArray)
  .render()
```

Where *columnsArray* is array of objects ```{key: value}```. Possible variation of **key**:
* [*id*](#id) - pointer to **key** attribute of [dataArray](data.md)
* [*label*](#label) - name of column
* [*classes*](#classes) - specific column class
  * [*columnClassFunction*](#columnclassfunction)
* [*format*](#format) - apply style formatting to output
  * [*formatFunction*](#formatfunction)
* [*isSortable*](#issortable) - allow to sort table rows in ascending (descending) order
* [*isNested*](#isnested) - allow to build table with [nested data](data.md#nested-data-expandablecollapsible-rows)
* [*isEditable*](#iseditable) - add special classes and event listeners to allow editing of table's cell
  * [*editableCellResolver*](#editablecellresolver)
  * [*onEdit*](#onedit) - editHandler apply changes to [dataArray](data.md)
* [*timeSeries*](#timeseries) - some specific methods for columns and data gouped by time factor.

Additional option
* [*custom editors*](#custom-editors) - additional option for *select*, *date*, *boolean* editors
* [*total column*](#total-column) - the sum of several columns


#### id

*Required field*
```{id: valueSelector}``` **valueSelector** should be on of keys from items of [dataArray](data.md)

```coffeescript
columnsArray = [
  id: "id"    # column 1
,
  id: "type"  # column 2
]

dataArray = [
  id: "nerds for good"  # will be used, column 1
  type: "ahaha"         # will be used, column 2
  label: "LOL"          # will not be used
,
  type: "Historical"    # will be used, column 2
  id: "Simple Line"     # will be used, column 1
  port: undefined       # will not be used
]
```


#### label

```label: columnName``` **columnName** is display name of the column. Will be capitalized. Should be *String*

```coffeescript
columnsArray = [
  id: "id"
  label: "Name"
,
  id: "type"
  label: "Type"
]
```


#### classes

```classes: classesValue``` Add a specific class to whole column or selected cell. **classesValue** could be a string value or pointer to [columnClassFunction](#columnclassfunction).

```coffeescript
columnsArray = [
  id: "id"
  label: "Name"
  classes: "row-heading"
,
  id: "type"
  label: "Type"
]
```


##### columnClassFunction

```columnClassFunction(dataItem, columnItem)``` function takes two optional arguments; should return *String* value. **dataItem** - selected from [dataArray](data.md) item; **columnItem** - selected from columnsArray item.

```coffeescript
columnClassFunction = (dataItem, columnItem) ->
  "total" if dataItem[columnItem.id] is "Historical"

columnsArray = [
  id: "id"
  label: "Name"
  classes: "row-heading"
,
  id: "type"
  label: "Type"
  classes: columnClassFunction
]
```


#### format

```format: formatFunction``` Apply custom formatting to column or table cell.


##### formatFunction()

```formatFunction(dataItem, columnItem)``` function takes two optional arguments; should return *String* or *Number* value. **dataItem** - selected from [dataArray](data.md) item; **columnItem** - selected from columnsArray item.

```coffeescript
formatFunction = (dataItem, columnItem) ->
  switch dataItem[columnItem.id]
    when "ahaha" then dataItem.label
    else "default"

columnsArray = [
  id: "id"
  label: "Name"
  classes: "row-heading"
,
  id: "type"
  label: "Type"
  format: formatFunction
]
```


#### isSortable

```isSortable: true``` **isSortable** key takes *true* or *false* statement. This option modifies column's cell by adding sorting arrows and adding event listener. Click on column's (table header) cell toggles current sorting state. At first table render all rows are at unsorted state.

```coffeescript
columnsArray = [
  id: "id"
  label: "Name"
  isSortable: true
,
  id: "type"
  label: "Type"
  isSortable: true
]
```


#### isNested

```isNested: true``` **isSortable** key takes *true* or *false* statement. This option modifies table rows generating and adds event listener to expand (collapse) nested data. Should be used together with [nested data](data.md#nested-data-expandablecollapsible-rows).
To create table with expandale/collapsible rows. [dataArray](data.md) should cointain a specific pair ```{key: value}``` **key** can have one of two values: *values* or *_values*. **value** should be array of objects, related to *columnsArray*
*values* - for expanded nested rows; *_values* - for collapsed nested rows.

```coffeescript
dataArray = [
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

columnsArray = [
  id: "id"
  label: "Name"
  isNested: true
,
  id: "type"
  label: "Type"
]

new window.TableStakes()
  .el("#example")
  .columns(columnsArray)
  .data(dataArray)
  .render()
```


#### isEditable

```isEditable: editableValue``` Add a specific class to whole column or selected cell. **editableValue** could be a *true* or *false* statement; or pointer to [editableCellResolver](#editablecellresolver) function.
If **isEditable** could be set to *true* (by statement or by [editableCellResolver](#editablecellresolver) function) pair ```onEdit: editHandler``` should be [set](#onedit).

```coffeescript
editHandler = null

columns = [
  id: "id"
  label: "Name"
  classes: "row-heading"
,
  id: "type"
  label: "Type"
  isEditable: true
  onEdit: editHandler
]
```


##### editableCellResolver

```editableCellResolver(dataItem, columnItem)``` function takes two optional arguments; should return *true* or *false* statement. **dataItem** - selected from [dataArray](data.md) item; **columnItem** - selected from columnsArray item.

```coffeescript
editableCellResolver = (dataItem, columnItem) ->
  if dataItem.id is "Simple Line"
  and columnItem.id is "id"
    return true
  else
    return false

editHandler = null

columns = [
  id: "id"
  label: "Name"
  isEditable: editableCellResolver
  onEdit: editHandler
,
  id: "type"
  label: "Type"
]
```


##### onEdit

When the user attempts to edit a cell, the callback function will be called with the row's id field, column's id field and new value.

```coffeescript
editHandler = (rowId, columnId, newValue) ->
  (row[columnId] = newValue if row.id is rowId) for row in dataArray
  grid.data(dataArray).render()

columnsArray = [
  id: "id"
  label: "Name"
  classes: "row-heading"
,
  id: "type"
  label: "Type"
  isEditable: true
  onEdit: editHandler
]

dataArray = [
  id: "nerds for good"
  type: "ahaha"
,
  id: "Simple Line"
  type: "Historical"
,
  id: "Scatter / Bubble"
  type: "Snapshot"
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columnsArray)
  .data(dataArray)
  .render()
```


#### timeSeries

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

More timeSeries options described [here](data.md#parseflatdata)


#### Custom Editors

For some editors created more flexible rules. To enable one of thees option set pair ```{key: value}``` as **key** equal to *editor* and **value** to one from list

* [*select*](#select)
* [*calendar*](#calendar)
* [*boolean*](#boolean)
* [*button*](#button)

And some additional options.
Full example are available at [tablestakes-showcase](http://tablestakes-showcase.herokuapp.com/#editable)

```coffeescript
editHandler = (rowId, columnId, newValue) ->
  (row[columnId] = newValue if row.id is rowId) for row in data
  grid.data(data).render()

clickHandler = (rowId, columnId, value) ->
  if columnId is 'archive'
    data = _.without(data, _.find(data, (row) -> row.id is rowId))
    grid.data(data).render()
```


##### select

```coffeescript
isEditable: true
onEdit: editHandler
editor: 'select'
selectOptions: options
```

Where **options** is array of available select's options, like "['engineering', 'design', 'qa']"


##### calendar

```coffeescript
isEditable: true
onEdit: editHandler
editor: 'calendar'
```


##### boolean

```coffeescript
isEditable: true
onEdit: editHandler
editor: 'boolean'
```


##### button

```coffeescript
isEditable: true
editor: "button"
onClick: clickHandler
```

Where ```{editor: "button"}``` and **onClick** are bound together. Button's **value** attribute is equal to column's **label** field.


#### Total Column

Special column to sum values of different columns. To define "total Column" columnsArray should contain object with pairs ```{key: value}``` like thees

```cpffeescript
type: "total"
related: relatedColumns
```

Where **relatedColumns** is *String* or *Array* of strings equal to column's id field which will be summed. If length of **relatedColumns** is &#x2264; 1 then "total Column" will be hidden. *Exception:* if **relatedColumns** points to [timeSeries column](#timeseries) associative array will be used.
Full example are available

```coffeescript
columnsArray = [
  id: "id"
  label: "Name"
,
  id: "column_1"
  label: "Column 1"
,
  id: "column_2"
  label: "Column 2"
,
  id: "total"   # uniq column's ID
  type: "total" # key argument for "total" column

  label: "Total"
  related: ["column_1", "column_2"]
]

dataArray = [
  id: "row 1"
  column_1: 1
  column_2: 2
,
  id: "row 2"
  column_1: 3
  column_2: 4
,
  id: "row 3"
  column_1: 5
  column_2: 6
]

new window.TableStakes()
  .el("#example")
  .columns(columnsArray)
  .data(dataArray)
  .render()
```
