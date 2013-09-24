### Columns

Function and array of objects to define relation between [dataArray](data-manipulating.md) and corresponding table columns.
```coffeescript
grid = new window.TableStakes()
  .el("#example")
  .columns(columnsArray)
  .render()
```

Where *columnsArray* is array of objects ```{key: value}```. Possible variation of **key**:
* [*id*](#id) - pointer to **key** attribute of [dataArray](data-manipulating.md)
* [*label*](#label) - name of column
* [*classes*](#classes) - specific column class
  * [*columnClassFunction*](#columnclassfunction)
* [*format*](#format) - apply style formatting to output
  * [*formatFunction*](#formatfunction)
* [*isSortable*](#issortable) - allow to sort table rows in ascending (descending) order
* [*isNested*](#isnested) - allow to build table with [nested data](data-manipulating.md#nested-data-expandablecollapsible-rows)
* [*isEditable*](#iseditable) - add special classes and event listeners to allow editing of table's cell
  * [*editableCellResolver*](#editablecellresolver)
  * [*onEdit*](#onedit) - editHandler apply changes to [dataArray](data-manipulating.md)
* *timeSeries* - some specific methods for columns and data gouped by time factor.

Additional option
* *custom editors* - additional option for *select*, *date*, *boolean* editors
* *total column* - the sum of several columns


#### id

*Required field*  
```{id: valueSelector}``` **valueSelector** should be on of keys from items of [dataArray](data-manipulating.md)

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

```columnClassFunction(dataItem, columnItem)``` function takes two optional arguments; should return *String* value. **dataItem** - selected from [dataArray](data-manipulating.md) item; **columnItem** - selected from columnsArray item.

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

```formatFunction(dataItem, columnItem)``` function takes two optional arguments; should return *String* or *Number* value. **dataItem** - selected from [dataArray](data-manipulating.md) item; **columnItem** - selected from columnsArray item.

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

```isNested: true``` **isSortable** key takes *true* or *false* statement. This option modifies table rows generating and adds event listener to expand (collapse) nested data. Should be used together with [nested data](data-manipulating.md#nested-data-expandablecollapsible-rows).  
To create table with expandale/collapsible rows. [dataArray](data-manipulating.md) should cointain a specific pair ```{key: value}``` **key** can have one of two values: *values* or *_values*. **value** should be array of objects, related to *columnsArray*  
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

```editableCellResolver(dataItem, columnItem)``` function takes two optional arguments; should return *true* or *false* statement. **dataItem** - selected from [dataArray](data-manipulating.md) item; **columnItem** - selected from columnsArray item.

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

Coming soon


#### timeSeries

Coming soon


#### Custom Editors

Coming soon


##### Select

Coming soon


##### Date

Coming soon


##### Boolean

Coming soon


#### Total Column

Coming soon

