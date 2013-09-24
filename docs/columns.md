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
  * [*columnClassFunction()*](#columnclassfunction)
* *format* - apply style formatting to output
* *isSortable* - allow to sort table rows in ascending (descending) order
* *isNested* - allow to build table with [nested data](data-manipulating.md#nested-data-expandablecollapsible-rows)
* *editable* - add special classes and event listeners to allow editing of table's cell
  * *onEdit* - editHandler apply changes to [dataArray](data-manipulating.md)
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

Display name of the column. Will be capitalized.

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

```classes: classesValue``` Add a specific class to whole column of selected cell. **classesValue** could be a string value or pointer to [columnClassFunction].

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
columnsArray = [
  id: "id"
  label: "Name"
  classes: "row-heading"
,
  id: "type"
  label: "Type"
  classes: (d, column) ->
    "total" if d[column.id] is "Historical"
]
```


#### format

Coming soon


#### isSortable

Coming soon


#### isNested

Coming soon


#### editable

Coming soon


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

